/**
 * Creator port of FGameCommon Entry.RunCasino / DestroyCasino.
 */
import { director, log } from 'cc';
import { APIGateway } from './APIGateway';
import { CreateFairyRoot, DestroyFairyRoot } from './FairyGUIStub';
import { StopAllTimer } from './Timer';
import { sGameManager } from '../data/GameManager';

let casinoActive = false;
let activeGameId = -1;
let lastEnterData: unknown = null;

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
  lastEnterData = enterData;
  CreateFairyRoot();

  log(`[FGame] RunCasino gameId=${gameId}`, enterData, reconnectData);

  // Phase 2+: when FairyGUI-Creator + Game{id} packages exist:
  //   FairyGUI.UIPackage.AddPackage(`Game${gameId}/Game${gameId}`)
  //   instantiate FGame.Game{gameId}.Game{gameId}
  // Until then, open interactive casino shell with real enterData.
  director.loadScene('CasinoStub');
}

export function DestroyCasino(): void {
  if (!casinoActive) return;
  casinoActive = false;
  activeGameId = -1;
  lastEnterData = null;
  DestroyFairyRoot();
  StopAllTimer();
  sGameManager.isCasinoLoaded = false;
  APIGateway.EnterLobby();
}

export function IsCasinoActive(): boolean {
  return casinoActive;
}

export function GetActiveCasinoGameId(): number {
  return activeGameId;
}

export function GetLastEnterData(): unknown {
  return lastEnterData;
}
