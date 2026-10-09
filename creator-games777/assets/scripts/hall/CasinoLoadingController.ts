import { _decorator, Component, Label } from 'cc';
import { Coroutines } from '../core/Coroutine';
import { GameData } from '../data/GameData';
import { ConstGame } from '../data/ConstGame';

const { ccclass, property } = _decorator;

/**
 * Loading scene while FGame bundles / enter packets run (csb/lobby/GameLoadingLayer stand-in).
 */
@ccclass('CasinoLoadingController')
export class CasinoLoadingController extends Component {
  @property(Label)
  progressLabel: Label | null = null;

  start(): void {
    this.schedule((dt: number) => Coroutines.update(dt), 0);
    const id = GameData.GetGameID(GameData.game_id);
    const name = ConstGame.Param[id]?.Game_Name || String(id);
    if (this.progressLabel) {
      this.progressLabel.string = `Loading ${name} (FGame${id})...`;
    }
  }
}
