/**
 * Port of hall/src/common/GameInfoManager.lua (session state subset).
 */
import { ConstGame } from './ConstGame';

export class GameManagerStore {
  gameState: string = ConstGame.Lobby_State;
  isCasinoLoaded = false;
  NetRestoreCasino = false;
  NetRestoreCasinoRlt: unknown = null;
  slotEnterResult: unknown = null;
  curLevel: { c_value?: number } | null = null;
  exchangerate = 1;
  _washcode_mode = 0;
  private richGame = false;
  private myVipLevel = -1;
  private bindCodeOpen = false;
  private betLotteryMode = false;
  private casinoLevelOpen = true;

  SetRichGame(v: boolean): void {
    this.richGame = v;
  }

  IsRichGame(): boolean {
    return this.richGame;
  }

  CheckIsCasino(gameId: number): boolean {
    return gameId > 200;
  }

  GetMyVipLevel(): number {
    return this.myVipLevel;
  }

  SetMyVipLevel(level: number): void {
    this.myVipLevel = level;
  }

  IsBindCodeOpen(): boolean {
    return this.bindCodeOpen;
  }

  GetBetLotteryMode(): boolean {
    return this.betLotteryMode;
  }

  CheckNeedPopCasinoLevel(): boolean {
    return this.casinoLevelOpen;
  }

  SetBetLotteryMode(v: boolean): void {
    this.betLotteryMode = v;
  }

  SetWashCodeMode(mode: number): void {
    this._washcode_mode = mode;
  }
}

export const sGameManager = new GameManagerStore();
