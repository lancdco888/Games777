/**
 * Creator stub scene controller for casino until FGUI games are ported.
 */
import { _decorator, Component, Label } from 'cc';
import { DestroyCasino, GetActiveCasinoGameId } from './RunCasino';
import { Coroutines } from '../core/Coroutine';

const { ccclass, property } = _decorator;

@ccclass('CasinoStubController')
export class CasinoStubController extends Component {
  @property(Label)
  infoLabel: Label | null = null;

  start(): void {
    this.schedule((dt: number) => Coroutines.update(dt), 0);
    if (this.infoLabel) {
      this.infoLabel.string = `FGame ${GetActiveCasinoGameId()} (Creator stub)\nTap Back to Lobby`;
    }
  }

  onClickBack(): void {
    DestroyCasino();
  }
}
