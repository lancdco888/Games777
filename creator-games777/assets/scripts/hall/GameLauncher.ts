/**
 * Routes lobby enter → FGame (slots) or fish2.
 * Mirrors Panel_Lobby.SendEnterRoomLevel + CasinoLoading / EnterFishLayer.
 */
import { GameData } from '../data/GameData';
import { sGameManager } from '../data/GameManager';
import { ConstGame } from '../data/ConstGame';
import { UIManager } from './UIManager';
import { RunCasino } from '../fgame/RunCasino';
import { EnterFish } from '../fish2/EnterFish';

export async function launchCasino(gameId: number): Promise<boolean> {
  const resId = GameData.GetGameID(gameId);
  const cfg = ConstGame.Param[resId];
  if (!cfg) {
    UIManager.ShowToast(`no ConstGame.Param[ ${resId} ]`);
    return false;
  }

  sGameManager.gameState = ConstGame.Game_State;
  sGameManager.isCasinoLoaded = true;

  // enterData / reconnectData will come from lobby enter packets
  await RunCasino(resId, { game_id: gameId }, null);
  return true;
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
