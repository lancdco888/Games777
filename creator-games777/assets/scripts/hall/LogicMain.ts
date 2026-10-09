/**
 * Port of hall/src/logic.lua — Auth → EnterLobby → reconnect game.
 */
import { director } from 'cc';
import { go } from '../core/Coroutine';
import { TR } from '../core/i18n';
import { Device } from '../core/Device';
import { AppStorage } from '../core/Storage';
import { LoginData, LoginType } from '../data/LoginData';
import { UserData } from '../data/UserData';
import { GameData } from '../data/GameData';
import { sGameManager } from '../data/GameManager';
import { SettingData } from '../data/SettingData';
import { ConstGame } from '../data/ConstGame';
import { NetClient, type NetMessage } from '../net/NetClient';
import { UIManager } from './UIManager';
import { launchCasino, launchFish } from './GameLauncher';
import { Dispatcher } from '../core/Dispatcher';
import { PKG_Lobby_Client_MoneyChanged } from '../net/protocols/LobbyPkgs';

function CheckIsFirstLogin(): boolean {
  const data = AppStorage.getString('Account', '');
  return !data;
}

function applySelfAccount(self: Record<string, unknown> | null | undefined): void {
  if (!self) return;
  if (self.money != null) UserData.money = Number(self.money);
  if (self.money_safe != null) UserData.money_safe = Number(self.money_safe);
  if (self.money_gift != null) UserData.money_gift = Number(self.money_gift);
  if (self.nickname != null) UserData.nickname = String(self.nickname);
}

async function SendAuth(): Promise<number> {
  const loginType = LoginData.GetType();
  let username = '';
  let facebook = '';
  let accountName = '';
  let password = '';

  if (loginType === LoginType.PWD) {
    accountName = LoginData.GetAccount();
    password = LoginData.GetPassword();
  } else if (loginType === LoginType.GUEST) {
    username = LoginData.EnsureGuestAccount();
  } else if (loginType === LoginType.FACEBOOK) {
    facebook = LoginData.GetAccount();
  }

  const req = NetClient.Create('PKG_Client_Login_AuthByUsername', {
    username,
    facebook,
    createIp: '',
    clientType: Device.GetSystemModel(),
    device_id: Device.GetDeviceID(),
    phoneType: 1,
    version: '1.0.1',
    packageName: Device.GetPackageName(),
    promotion_code: '',
    account_name: accountName,
    password,
    ram: '1024',
    pkgGenMd5: '',
    code: '',
    google: '',
    apple: '',
  });

  const rlt = await NetClient.SendRequest(req);
  if (!rlt) return -3;

  if (rlt._typeName === 'PKG_Login_Client_Auth_Success_Lobby') {
    UserData.is_first_login = CheckIsFirstLogin();
    UserData.username = String(rlt.username || '');
    UserData.id = Number(rlt.accountId || 0);
    applySelfAccount(rlt.self as Record<string, unknown>);
    GameData.lobbyToken = String(rlt.lobbyToken || '');
    GameData.serverID = Number(rlt.serviceId || 0);
    sGameManager.SetBetLotteryMode(Number(rlt.slots_bet_lottery_mode || 0) !== 0);
    sGameManager.SetWashCodeMode(Number(rlt.washcode_mode || 0));
    if (loginType === LoginType.PWD || loginType === LoginType.GUEST) {
      LoginData.SetAccount(UserData.username || accountName);
    }
    return Number(rlt.gameId ?? 0);
  }

  UIManager.ShowToast(TR('网络连接失败，请重试'));
  return -1;
}

/**
 * Aligns with logic.lua EnterLobbyPanel — token enter + game list + casino levels.
 */
export async function EnterLobbyPanel(): Promise<boolean> {
  const data = NetClient.Create('PKG_Client_Lobby_Enter', {
    token: GameData.lobbyToken || '',
  });

  UIManager.ShowWaiting();
  const rlt = await NetClient.SendRequest(data);
  UIManager.HideWaiting();

  if (!rlt || rlt._typeName !== 'PKG_Lobby_Client_Enter_Success') {
    UIManager.ShowToast(TR('网络连接失败，请重试'));
    return false;
  }

  const gameIds = (rlt.gameIds as number[]) || [];
  GameData.SetGameList(gameIds, true);
  applySelfAccount(rlt.self as Record<string, unknown>);

  const casinoInfos: Record<number, unknown[]> = {};
  const list = (rlt.gameEntryConditionsList as Array<{ gameid: number; Entrys: unknown[] }>) || [];
  for (const configs of list) {
    const tabs: unknown[] = [];
    const entrys = configs.Entrys || [];
    for (let j = entrys.length - 1; j >= 0; j--) {
      tabs.push(entrys[j]);
    }
    casinoInfos[configs.gameid] = tabs;
  }
  GameData.casinoLevelTabs = casinoInfos;

  sGameManager.gameState = ConstGame.Lobby_State;
  sGameManager.isCasinoLoaded = false;

  // Money push
  NetClient.Register(PKG_Lobby_Client_MoneyChanged.typeName, 'lobby', (msg: NetMessage) => {
    UserData.money = Number(msg.money || 0);
    UserData.money_safe = Number(msg.money_safe || 0);
    UserData.money_gift = Number(msg.money_gift || 0);
    UserData.money_gift_safe = Number(msg.money_gift_safe || 0);
    Dispatcher.Dispatch('MONEY_CHANGED');
  });

  director.loadScene('Lobby');
  return true;
}

async function EnterCasinoGame(gameId: number): Promise<boolean> {
  GameData.game_id = gameId;
  GameData.entergame_id = gameId;
  return launchCasino(gameId);
}

async function StartGameByGameId(gameId: number): Promise<boolean> {
  GameData.game_id = gameId;
  return launchFish(gameId);
}

export async function LogicMain(): Promise<void> {
  const ip = SettingData.GetNetworkIP();
  const port = SettingData.GetNetworkPort();
  NetClient.SetHost(ip, port);

  UIManager.ShowWaiting();
  const connected = await NetClient.ConnectServer();
  UIManager.HideWaiting();

  if (!connected) {
    go(function* () {
      yield 0.5;
      void LogicMain();
    });
    return;
  }

  UIManager.ShowWaiting();
  const gameId = await SendAuth();
  UIManager.HideWaiting();

  if (gameId === -1) return;

  if (gameId === -2 || gameId === -3) {
    UIManager.ShowMsgBox(TR('网络连接失败，请重试'), () => {
      void LogicMain();
    });
    return;
  }

  UIManager.ShowWaiting();
  if (gameId === 0) {
    const ok = await EnterLobbyPanel();
    if (!ok) {
      UIManager.HideWaiting();
      return;
    }
  } else {
    sGameManager.SetRichGame(GameData.IsRichGameID(gameId));
    if (gameId > 200) {
      const ok = await EnterCasinoGame(gameId);
      if (!ok) {
        UIManager.HideWaiting();
        void LogicMain();
        return;
      }
    } else {
      const ok = await StartGameByGameId(gameId);
      if (!ok) {
        UIManager.HideWaiting();
        void LogicMain();
        return;
      }
    }
  }
  UIManager.HideWaiting();
}
