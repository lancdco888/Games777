/**
 * Creator APIGateway — mirrors FGameCommon/Special/CocosFish2/APIGateway.lua
 */
import { gSound } from '../core/Sound';
import { go, SleepSecs } from '../core/Coroutine';
import { Device, ScreenType } from '../core/Device';
import { GameData } from '../data/GameData';
import { sGameManager } from '../data/GameManager';
import { ConstGame } from '../data/ConstGame';
import { UIManager } from '../hall/UIManager';
import { EnterLobbyPanel } from '../hall/LogicMain';
import { NetClient, type NetMessage } from '../net/NetClient';
import { TR } from '../core/i18n';

export const APIGateway = {
  PlaySound(path: string, loop = false): number | null {
    return gSound.playEffect(path, loop);
  },

  StopSound(handle: number | null): void {
    gSound.stopEffect(handle);
  },

  SetSoundVolume(_handle: number | null, _volume: number): void {
    // wire when AudioSource handles exist
  },

  PlayBGM(path: string): number | null {
    return gSound.playBgm(path);
  },

  StopBGM(): void {
    gSound.stopBgm();
  },

  IsSoundEnable(): boolean {
    return gSound.isEffectOn();
  },

  SetSoundEnable(value: boolean): void {
    gSound.setEffectOn(value);
  },

  GetLobbyData() {
    const casinoExchangeRate =
      GameData.exchangeCoinRatio ?? sGameManager.curLevel?.c_value ?? 1;
    return {
      bindGoldCoinEnabled: sGameManager.IsBindCodeOpen(),
      playerIsVIP: sGameManager.GetMyVipLevel() >= 0,
      lobbyExchangeRate: sGameManager.exchangerate,
      gameExchangeRate: casinoExchangeRate,
      isLotteryBetMode: sGameManager.GetBetLotteryMode(),
      curSlotsLevel: sGameManager.curLevel,
      isCasinoLevelOpen: sGameManager.CheckNeedPopCasinoLevel(),
      washCodeMode: sGameManager._washcode_mode,
      rawGameId: GameData.game_id,
    };
  },

  GetGameReconnectData(): unknown {
    if (sGameManager.NetRestoreCasino) {
      sGameManager.NetRestoreCasino = false;
      return sGameManager.NetRestoreCasinoRlt;
    }
    return null;
  },

  ShowMessageBox(content: string, onOk?: () => void, onCancel?: () => void): void {
    UIManager.ShowMsgBox(content, onOk, onCancel);
  },

  OpenSettingPanel(): void {
    UIManager.ShowToast('Settings (TODO)');
  },

  OpenServicePanel(): void {
    UIManager.ShowToast('Service (TODO)');
  },

  GetLangText(key: string): string {
    return TR(key);
  },

  EnterLobby(): void {
    go(function* () {
      sGameManager.isCasinoLoaded = false;
      sGameManager.gameState = ConstGame.Lobby_State;
      if (APIGateway.IsDeviceOrientationPortrait()) {
        Device.setScreenType(ScreenType.Landscape);
        yield SleepSecs(0.3);
      } else {
        yield SleepSecs(0.05);
      }
      void EnterLobbyPanel();
    });
  },

  SendPush(msg: NetMessage): void {
    NetClient.SendPush(msg);
  },

  SendRequest(msg: NetMessage, callback?: (ok: boolean, result: NetMessage | null) => void): void {
    go(function* () {
      const resultPromise = NetClient.SendRequest(msg);
      yield resultPromise;
      // result resolved asynchronously; callback via then for reliability
      void resultPromise.then((result) => {
        callback?.(result !== null, result);
      });
    });
  },

  Disconnect(): void {
    NetClient.Disconnect();
  },

  IsDeviceOrientationPortrait(): boolean {
    return Device.getScreenType() === ScreenType.Portrait;
  },

  GetCurRegion(): string {
    return 'zh';
  },

  Clear(): void {
    // optional cleanup hook
  },
};
