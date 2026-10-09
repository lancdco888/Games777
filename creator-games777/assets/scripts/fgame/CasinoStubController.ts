/**
 * Creator stub scene for casino until FairyGUI packages are imported.
 * Shows enter packet data from PKG_Slots_Client_Enter_Success.
 */
import { _decorator, Component, Label } from 'cc';
import { DestroyCasino, GetActiveCasinoGameId, GetLastEnterData } from './RunCasino';
import { Coroutines } from '../core/Coroutine';
import { ConstGame } from '../data/ConstGame';

const { ccclass, property } = _decorator;

@ccclass('CasinoStubController')
export class CasinoStubController extends Component {
  @property(Label)
  infoLabel: Label | null = null;

  start(): void {
    this.schedule((dt: number) => Coroutines.update(dt), 0);
    const id = GetActiveCasinoGameId();
    const cfg = ConstGame.Param[id];
    const enter = GetLastEnterData() as Record<string, unknown> | null;
    if (this.infoLabel) {
      this.infoLabel.string =
        `FGame ${id} ${cfg?.Game_Name || ''}\n` +
        `Screen: ${cfg?.ScreenType === 2 ? 'Portrait' : 'Landscape'}\n` +
        `enterData: money=${enter?.money ?? '-'} bet=${enter?.bet ?? '-'}\n` +
        `FairyGUI package Game${id}/Game${id} pending\n` +
        `Tap Back to Lobby`;
    }
  }

  onClickBack(): void {
    DestroyCasino();
  }

  /** Placeholder spin — proves shell is interactive */
  onClickSpin(): void {
    if (this.infoLabel) {
      this.infoLabel.string += '\n[spin stub]';
    }
  }
}
