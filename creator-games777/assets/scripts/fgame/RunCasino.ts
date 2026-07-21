/**
 * Creator port of FGameCommon Entry.RunCasino / DestroyCasino.
 * Phase 1: stub that logs and returns to lobby; Phase 2 loads FGUI packages.
 */
import { director, log } from 'cc';
import { APIGateway } from './APIGateway';
import { CreateFairyRoot, DestroyFairyRoot } from './FairyGUIStub';

let casinoActive = false;
let activeGameId = -1;

export async function RunCasino(
  gameId: number,
  enterData: unknown,
  reconnectData: unknown,
): Promise<void> {
  if (casinoActive) {
    log('[FGame] RunCasino ignored — already active', activeGameId);
    return;
  }

  casinoActive = true;
  activeGameId = gameId;
  CreateFairyRoot();

  log(`[FGame] RunCasino gameId=${gameId}`, enterData, reconnectData);
  // TODO Phase 2:
  // 1) load bundle FGame{id} + FGameCommon
  // 2) FairyGUI.UIPackage.AddPackage(`Game${id}/Game${id}`)
  // 3) instantiate Game{id} theme / BaseGame
  director.loadScene('CasinoStub');
}

export function DestroyCasino(): void {
  if (!casinoActive) return;
  casinoActive = false;
  activeGameId = -1;
  DestroyFairyRoot();
  APIGateway.EnterLobby();
}

export function IsCasinoActive(): boolean {
  return casinoActive;
}

export function GetActiveCasinoGameId(): number {
  return activeGameId;
}
