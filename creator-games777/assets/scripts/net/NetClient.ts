/**
 * Network client — Creator port of packagelua Network + g_net.
 * Supports mock mode (default) and WebSocket binary transport for real servers.
 */
import { Dispatcher } from '../core/Dispatcher';
import { SettingData } from '../data/SettingData';
import { gOM, writeRoot, readRoot, type PkgInstance } from './ObjMgr';
import { registerAllProtocols } from './protocols/register';
import { PKG_Client_Login_AuthByUsername, PKG_Login_Client_Auth_Success_Lobby } from './protocols/LoginPkgs';
import {
  PKG_Client_Lobby_Enter,
  PKG_Lobby_Client_Enter_Success,
  PKG_Client_Lobby_EnterGame,
  PKG_Lobby_Client_EnterGameSlots_Success,
  PKG_Client_Slots_Enter,
  PKG_Slots_Client_Enter_Success,
  PKG_Lobby_Client_MoneyChanged,
} from './protocols/LobbyPkgs';

export type NetMessage = PkgInstance;

type Handler = (msg: NetMessage) => void;

type Pending = {
  resolve: (pkg: NetMessage | null) => void;
  timer: ReturnType<typeof setTimeout>;
};

class NetClientImpl {
  private connected = false;
  private host = '127.0.0.1';
  private port = 9000;
  private handlers = new Map<string, Array<{ key: unknown; fn: Handler }>>();
  private mockMode = true;
  private serial = 0;
  private pending = new Map<number, Pending>();
  private ws: WebSocket | null = null;
  private openedServices = new Set<number>([0, 1]);

  constructor() {
    registerAllProtocols();
  }

  SetHost(ip: string, port: number): void {
    this.host = ip;
    this.port = port;
  }

  SetMockMode(enabled: boolean): void {
    this.mockMode = enabled;
  }

  IsMockMode(): boolean {
    return this.mockMode;
  }

  IsConnected(): boolean {
    return this.connected;
  }

  Create(typeName: string, init?: Partial<PkgInstance>): PkgInstance {
    const o = gOM.Create(typeName, init);
    if (!o) throw new Error(`unknown pkg ${typeName}`);
    return o;
  }

  async ConnectServer(): Promise<boolean> {
    this.host = SettingData.GetNetworkIP();
    this.port = SettingData.GetNetworkPort();

    if (this.mockMode) {
      this.connected = true;
      this.openedServices.add(0);
      Dispatcher.Dispatch('NET_CONNECTED');
      return true;
    }

    const url = this.port === 443 || this.port === 8443
      ? `wss://${this.host}:${this.port}/ws`
      : `ws://${this.host}:${this.port}/ws`;

    return new Promise((resolve) => {
      try {
        const ws = new WebSocket(url);
        ws.binaryType = 'arraybuffer';
        this.ws = ws;
        ws.onopen = () => {
          this.connected = true;
          Dispatcher.Dispatch('NET_CONNECTED');
          resolve(true);
        };
        ws.onerror = () => {
          this.connected = false;
          resolve(false);
        };
        ws.onclose = () => {
          this.connected = false;
          this.rejectAllPending();
          Dispatcher.Dispatch('NET_DISCONNECTED');
        };
        ws.onmessage = (ev) => this.onBinary(ev.data);
      } catch {
        this.connected = false;
        resolve(false);
      }
    });
  }

  Disconnect(): void {
    this.connected = false;
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
    this.rejectAllPending();
    Dispatcher.Dispatch('NET_DISCONNECTED');
  }

  Register(msgName: string, key: unknown, fn: Handler): void {
    let list = this.handlers.get(msgName);
    if (!list) {
      list = [];
      this.handlers.set(msgName, list);
    }
    list.push({ key, fn });
  }

  UnregisterKey(key: unknown): void {
    for (const [name, list] of this.handlers) {
      this.handlers.set(
        name,
        list.filter((h) => h.key !== key),
      );
    }
  }

  async SendRequest(msg: NetMessage, timeoutMS = 10000): Promise<NetMessage | null> {
    if (!this.connected) return null;

    if (this.mockMode) {
      return this.mockResponse(msg);
    }

    const serial = ++this.serial;
    const payload = writeRoot(msg);
    const frame = this.packFrame(0, -serial, payload);

    return new Promise((resolve) => {
      const timer = setTimeout(() => {
        this.pending.delete(serial);
        resolve(null);
      }, timeoutMS);
      this.pending.set(serial, { resolve, timer });
      this.ws?.send(frame);
    });
  }

  SendPush(msg: NetMessage): void {
    if (!this.connected) return;
    if (this.mockMode) return;
    const payload = writeRoot(msg);
    this.ws?.send(this.packFrame(0, 0, payload));
  }

  Update(): void {
    // inbound pumped by ws onmessage
  }

  private packFrame(serviceId: number, serial: number, payload: Uint8Array): ArrayBuffer {
    // provisional header: i32 serviceId, i32 serial, i32 len, payload
    const ab = new ArrayBuffer(12 + payload.length);
    const dv = new DataView(ab);
    dv.setInt32(0, serviceId, true);
    dv.setInt32(4, serial, true);
    dv.setInt32(8, payload.length, true);
    new Uint8Array(ab, 12).set(payload);
    return ab;
  }

  private onBinary(data: ArrayBuffer): void {
    const u8 = new Uint8Array(data);
    if (u8.length < 12) return;
    const dv = new DataView(data);
    const serial = dv.getInt32(4, true);
    const len = dv.getInt32(8, true);
    const payload = u8.slice(12, 12 + len);
    const pkg = readRoot(payload);
    if (!pkg) return;

    if (serial > 0) {
      const pending = this.pending.get(serial);
      if (pending) {
        clearTimeout(pending.timer);
        this.pending.delete(serial);
        pending.resolve(pkg);
        return;
      }
    }

    const name = String(pkg._typeName || '');
    const list = this.handlers.get(name);
    if (list) {
      for (const { fn } of [...list]) fn(pkg);
    }
    Dispatcher.Dispatch('NET_PUSH', pkg);
  }

  private rejectAllPending(): void {
    for (const [, p] of this.pending) {
      clearTimeout(p.timer);
      p.resolve(null);
    }
    this.pending.clear();
  }

  private mockResponse(msg: NetMessage): NetMessage {
    const name = String(msg._typeName || msg._name || '');

    if (name === PKG_Client_Login_AuthByUsername.typeName || name === 'PKG_Client_Login_AuthByUsername') {
      const ok = PKG_Login_Client_Auth_Success_Lobby.Create();
      ok.lobbyToken = `mock-token-${Date.now()}`;
      ok.username = String(msg.username || msg.account_name || 'guest');
      ok.accountId = 10001;
      ok.gameId = 0;
      ok.serviceId = 1;
      ok.money_exchange_coin = 1000;
      ok.self = {
        _typeName: 'selfAccount',
        money: 10000,
        money_safe: 0,
        nickname: String(ok.username),
      };
      return ok;
    }

    if (name === PKG_Client_Lobby_Enter.typeName || name === 'PKG_Client_Lobby_Enter') {
      const ok = PKG_Lobby_Client_Enter_Success.Create();
      ok.gameIds = [30, 270, 336, 341, 353, 375, 388, 465, 475, 479, 481, 482, 483, 485];
      ok.money_exchange_coin = 1000;
      ok.gameTypeSort = '123';
      ok.gameEntryConditionsList = (ok.gameIds as number[])
        .filter((id) => id > 200)
        .map((gameid) => ({
          _typeName: 'GameEntryConditions',
          gameid,
          Entrys: [
            {
              id: 1,
              desc: '普通场',
              enterMinMoney: 0,
              spinMinMoney: 1,
              spinMaxMoney: 1000,
              c_value: 1,
              c_lottery_value: 1,
            },
          ],
        }));
      ok.self = {
        _typeName: 'selfAccount',
        money: 10000,
        money_safe: 500,
        nickname: 'Guest',
      };
      return ok;
    }

    if (name === PKG_Client_Lobby_EnterGame.typeName || name === 'PKG_Client_Lobby_EnterGame') {
      const ok = PKG_Lobby_Client_EnterGameSlots_Success.Create();
      ok.GameId = Number(msg.gameId || 0);
      ok.serviceId = 1000 + Number(msg.gameId || 0);
      return ok;
    }

    if (name === PKG_Client_Slots_Enter.typeName || name === 'PKG_Client_Slots_Enter') {
      const ok = PKG_Slots_Client_Enter_Success.Create();
      ok.gameId = Number(msg.gameId || 0);
      ok.money = 10000;
      ok.bet = 1;
      return ok;
    }

    if (name === 'PKG_Lobby_Client_MoneyChanged') {
      return PKG_Lobby_Client_MoneyChanged.Create();
    }

    return { _typeName: 'PKG_Unknown', _typeId: 0, request: name };
  }
}

export const NetClient = new NetClientImpl();

export function gNet_SendRequest(msg: NetMessage): Promise<NetMessage | null> {
  return NetClient.SendRequest(msg);
}

export function gNet_SendPush(msg: NetMessage): void {
  NetClient.SendPush(msg);
}
