/**
 * Port of hall/src/logic.lua — session orchestration after package login.
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
import { NetClient, type NetMessage } from '../net/NetClient';
import { UIManager } from './UIManager';
import { launchCasino, launchFish } from './GameLauncher';

function CheckIsFirstLogin(): boolean {
  const data = AppStorage.getString('Account', '');
  return !data;
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
    username = LoginData.GetAccount();
  } else if (loginType === LoginType.FACEBOOK) {
    facebook = LoginData.GetAccount();
  }

  const req: NetMessage = {
    _name: 'PKG_Client_Login_AuthByUsername',
    username,
    facebook,
    createIp: '',
    clientType: Device.GetSystemModel(),
    device_id: Device.GetDeviceID(),
    phoneType: Device.GetPhoneType(),
    version: '1.0.1',
    packageName: Device.GetPackageName(),
    promotion_code: '',
    account_name: accountName,
    password,
    ram: '1024',
    code: '',
  };

  const rlt = await NetClient.SendRequest(req);
  if (!rlt) return -3;

  if (rlt._name === 'PKG_Login_Client_Auth_Success_Lobby') {
    UserData.is_first_login = CheckIsFirstLogin();
    UserData.username = String(rlt.username || '');
    UserData.id = Number(rlt.user_id || 0);
    UserData.money = Number(rlt.money || 0);
    if (loginType === LoginType.PWD || loginType === LoginType.GUEST) {
      LoginData.SetAccount(UserData.username || accountName);
    }
    const gameIds = (rlt.game_ids as number[]) || [];
    GameData.SetGameList(gameIds, true);
    return Number(rlt.game_id ?? 0);
  }

  UIManager.ShowToast(TR('网络连接失败，请重试'));
  return -1;
}

export async function EnterLobbyPanel(): Promise<boolean> {
  sGameManager.gameState = 'Lobby_State';
  sGameManager.isCasinoLoaded = false;
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

  if (gameId === -2) {
    go(function* () {
      yield 0.5;
      void LogicMain();
    });
    return;
  }

  if (gameId === -3) {
    UIManager.ShowMsgBox(TR('网络连接失败，请重试'), () => {
      void LogicMain();
    });
    return;
  }

  UIManager.ShowWaiting();
  if (gameId === 0) {
    await EnterLobbyPanel();
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
