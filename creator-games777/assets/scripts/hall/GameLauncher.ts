/**
 * Routes lobby enter → FGame (slots) or fish2.
 * Mirrors Panel_Lobby.SendEnterRoomLevel + CasinoLoading / EnterFishLayer.
 */
import { GameData } from '../data/GameData';
import { sGameManager } from '../data/GameManager';
import { ConstGame } from '../data/ConstGame';
import { UIManager } from './UIManager';
import { enterFGUICasino } from './CasinoEnterFlow';
import { EnterFish } from '../fish2/EnterFish';

export async function launchCasino(gameId: number): Promise<boolean> {
  const resId = GameData.GetGameID(gameId);
  const cfg = ConstGame.Param[resId];
  if (!cfg) {
    UIManager.ShowToast(`no ConstGame.Param[ ${resId} ]`);
    return false;
  }

  if (GameData.IsFGUIReleaseGame(gameId) || GameData.IsFGUIReleaseGame(resId)) {
    return enterFGUICasino(gameId);
  }

  // Legacy cocos casino path (casino221 etc.) — not ported; show toast
  UIManager.ShowToast(`legacy casino ${resId} not in Creator yet`);
  return false;
}

export async function launchFish(gameId: number): Promise<boolean> {
  const resId = GameData.GetGameID(gameId);
  sGameManager.gameState = ConstGame.Game_State;
  await EnterFish.start(resId);
  return true;
}

export async function SendEnterRoomLevel(gameId: number): Promise<void> {
  GameData.game_id = gameId;
  GameData.entergame_id = gameId;

  if (sGameManager.CheckIsCasino(gameId) || GameData.IsCasino(gameId)) {
    await launchCasino(gameId);
    return;
  }

  if (GameData.IsFish(gameId)) {
    await launchFish(gameId);
    return;
  }

  UIManager.ShowToast(`Unsupported game: ${gameId}`);
}
