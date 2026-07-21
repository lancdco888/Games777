/**
 * Port of hall/src/common/GameData.lua (core routing helpers).
 */
import { ConstGame } from './ConstGame';

const mapGame: Record<number, number> = {
  235: 221, 236: 221, 237: 221, 238: 221, 239: 221,
  240: 221, 241: 221, 242: 221, 243: 221, 244: 221,
  245: 221, 246: 221, 247: 221, 248: 221, 249: 221,
  420: 320, 701: 320, 702: 320, 703: 320, 704: 320,
  421: 321, 711: 321, 712: 321, 713: 321, 714: 321,
  422: 322, 721: 322, 722: 322, 723: 322, 724: 322,
  448: 348, 449: 349,
};

export class GameDataStore {
  game_id = -1;
  real_game_id = -1;
  level_id = -1;
  game_ids: number[] = [];
  levels: unknown[] = [];
  rooms: unknown[] = [];
  vipInfo: unknown[] = [];
  casinoLevelTabs: Record<number, unknown[]> = {};
  entergame_id = -1;
  exchangeCoinRatio: number | null = null;

  GetGameID(gameId: number): number {
    let id = gameId;
    if (id > 3000) id -= 3000;
    else if (id > 2000) id -= 2000;
    return mapGame[id] ?? id;
  }

  IsRichGameID(gameId: number): boolean {
    return gameId >= 2000 && gameId < 3000;
  }

  IsRichThreeThousandsGameID(gameId: number): boolean {
    return gameId >= 3000;
  }

  IsCasino(gameId: number): boolean {
    const cfg = ConstGame.Param[this.GetGameID(gameId)];
    return !!cfg && cfg.Game_type === 'casino';
  }

  IsFish(gameId: number): boolean {
    const cfg = ConstGame.Param[this.GetGameID(gameId)];
    if (!cfg) return false;
    return cfg.Game_type === 'haiwang' || cfg.Game_type === 'changsheng';
  }

  IsFGUIReleaseGame(gameId: number): boolean {
    const cfg = ConstGame.Param[this.GetGameID(gameId)];
    return !!(cfg && cfg.FGUI_Support && cfg.FGUI_Release);
  }

  IsCocosSupportGame(gameId: number): boolean {
    const cfg = ConstGame.Param[this.GetGameID(gameId)];
    return !!(cfg && cfg.Cocos_Support);
  }

  SetGameList(gameIds: number[], fishRuntimeAvailable = true): void {
    const list: number[] = [];
    for (const id of gameIds) {
      if (this.IsCasino(id)) {
        if (this.IsFGUIReleaseGame(id) || this.IsCocosSupportGame(id)) {
          list.push(id);
        }
      } else if (fishRuntimeAvailable) {
        list.push(id);
      }
    }
    this.game_ids = list;
  }
}

export const GameData = new GameDataStore();
