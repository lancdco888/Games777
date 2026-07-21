/**
 * Network client — Creator port of packagelua Network + g_net (Phase 1 stub).
 * Real binary protocol codecs will be generated from hall/src/pkgs/*.lua.
 */
import { Dispatcher } from '../core/Dispatcher';
import { SettingData } from '../data/SettingData';

export type NetMessage = {
  _name: string;
  [key: string]: unknown;
};

type Handler = (msg: NetMessage) => void;

class NetClientImpl {
  private connected = false;
  private host = '127.0.0.1';
  private port = 9000;
  private handlers = new Map<string, Array<{ key: unknown; fn: Handler }>>();
  private mockMode = true;

  SetHost(ip: string, port: number): void {
    this.host = ip;
    this.port = port;
  }

  /** Enable/disable local mock responses until real socket + codecs land. */
  SetMockMode(enabled: boolean): void {
    this.mockMode = enabled;
  }

  IsConnected(): boolean {
    return this.connected;
  }

  async ConnectServer(): Promise<boolean> {
    this.host = SettingData.GetNetworkIP();
    this.port = SettingData.GetNetworkPort();

    if (this.mockMode) {
      this.connected = true;
      Dispatcher.Dispatch('NET_CONNECTED');
      return true;
    }

    // TODO: WebSocket / native TCP bridge
    try {
      // placeholder for real transport
      this.connected = false;
      return false;
    } catch {
      this.connected = false;
      return false;
    }
  }

  Disconnect(): void {
    this.connected = false;
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

  async SendRequest(msg: NetMessage): Promise<NetMessage | null> {
    if (!this.connected) return null;

    if (this.mockMode) {
      return this.mockResponse(msg);
    }

    // TODO: encode + await matching response
    return null;
  }

  SendPush(msg: NetMessage): void {
    if (!this.connected) return;
    void msg;
  }

  Update(): void {
    // pump inbound queue when real transport exists
  }

  private mockResponse(msg: NetMessage): NetMessage {
    if (msg._name === 'PKG_Client_Login_AuthByUsername') {
      return {
        _name: 'PKG_Login_Client_Auth_Success_Lobby',
        username: String(msg.username || msg.account_name || 'guest'),
        user_id: 10001,
        money: 10000,
        game_id: 0,
        game_ids: [30, 270, 485],
      };
    }
    if (msg._name === 'PKG_Client_Lobby_EnterGame') {
      return {
        _name: 'PKG_Lobby_Client_EnterGameSlots_Success',
        game_id: msg.game_id,
      };
    }
    return { _name: 'PKG_Unknown', request: msg._name };
  }
}

export const NetClient = new NetClientImpl();

/** Lua-compatible aliases */
export function gNet_SendRequest(msg: NetMessage): Promise<NetMessage | null> {
  return NetClient.SendRequest(msg);
}

export function gNet_SendPush(msg: NetMessage): void {
  NetClient.SendPush(msg);
}
