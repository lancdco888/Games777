/**
 * Casino enter chain — mirrors CasinoSitEnter → CanisoGameEnter → FGCasinoLoading → FGCasinoGame.
 */
import { director, log } from 'cc';
import { GameData } from '../data/GameData';
import { ConstGame } from '../data/ConstGame';
import { sGameManager } from '../data/GameManager';
import { NetClient } from '../net/NetClient';
import { UIManager } from './UIManager';
import { RunCasino } from '../fgame/RunCasino';
import { loadFGameBundle } from '../fgame/FGameLoader';
import { Device, ScreenType } from '../core/Device';
import { go, SleepSecs } from '../core/Coroutine';

export type CasinoEnterResult = {
  ok: boolean;
  enterData: unknown;
  serviceId: number;
};

/**
 * Full FGUI casino enter (used by GameLauncher for IsFGUIReleaseGame).
 */
export async function enterFGUICasino(gameId: number): Promise<boolean> {
  const resId = GameData.GetGameID(gameId);
  const cfg = ConstGame.Param[resId];
  if (!cfg) {
    UIManager.ShowToast(`no ConstGame.Param[ ${resId} ]`);
    return false;
  }

  // Ensure casino level tabs (mock may already have set these)
  if (!GameData.casinoLevelTabs[gameId]?.length) {
    GameData.casinoLevelTabs[gameId] = [
      {
        id: 1,
        desc: '普通场',
        enterMinMoney: 0,
        spinMinMoney: 1,
        spinMaxMoney: 1000,
        c_value: 1,
        c_lottery_value: 1,
      },
    ];
  }
  sGameManager.curLevel = GameData.casinoLevelTabs[gameId][0] as { c_value?: number };

  // Orientation for portrait games (e.g. 485)
  if (cfg.ScreenType === ConstGame.V_Screen_Type) {
    Device.setScreenType(ScreenType.Portrait);
  } else {
    Device.setScreenType(ScreenType.Landscape);
  }

  // Show loading scene while downloading / entering
  director.loadScene('CasinoLoading');
  await waitFrames(2);

  UIManager.ShowWaiting('Loading FGame' + resId);

  // 1) Lobby EnterGame → slots service id
  const enterGame = NetClient.Create('PKG_Client_Lobby_EnterGame', { gameId });
  const slotsOk = await NetClient.SendRequest(enterGame);
  if (!slotsOk || slotsOk._typeName !== 'PKG_Lobby_Client_EnterGameSlots_Success') {
    UIManager.HideWaiting();
    UIManager.ShowToast('EnterGameSlots failed');
    await EnterLobbyFallback();
    return false;
  }

  const serviceId = Number(slotsOk.serviceId || 0);
  log(`[Casino] slots serviceId=${serviceId} GameId=${slotsOk.GameId}`);

  // 2) Slots Enter
  const slotsEnter = NetClient.Create('PKG_Client_Slots_Enter', { gameId: resId });
  const enterSuccess = await NetClient.SendRequest(slotsEnter);
  if (!enterSuccess || enterSuccess._typeName !== 'PKG_Slots_Client_Enter_Success') {
    UIManager.HideWaiting();
    UIManager.ShowToast('Slots Enter failed');
    await EnterLobbyFallback();
    return false;
  }

  // 3) Load FGameCommon + FGame{id} bundles (Creator Asset Bundle names)
  const loaded = await loadFGameBundle(resId);
  if (!loaded) {
    log(`[Casino] bundle FGame${resId} not in build yet — continuing with stub runtime`);
  }

  UIManager.HideWaiting();
  sGameManager.gameState = ConstGame.Game_State;
  sGameManager.isCasinoLoaded = true;
  sGameManager.slotEnterResult = enterSuccess;

  await RunCasino(resId, enterSuccess, null);
  return true;
}

async function EnterLobbyFallback(): Promise<void> {
  Device.setScreenType(ScreenType.Landscape);
  director.loadScene('Lobby');
}

function waitFrames(n: number): Promise<void> {
  return new Promise((resolve) => {
    go(function* () {
      for (let i = 0; i < n; i++) yield SleepSecs(0.05);
      resolve();
    });
  });
}
