import { _decorator, Component, Label } from 'cc';
import { EnterFish } from './EnterFish';
import { FishBridge } from './FishBridge';
import { Coroutines } from '../core/Coroutine';

const { ccclass, property } = _decorator;

@ccclass('FishStubController')
export class FishStubController extends Component {
  @property(Label)
  infoLabel: Label | null = null;

  start(): void {
    this.schedule((dt: number) => Coroutines.update(dt), 0);
    if (this.infoLabel) {
      this.infoLabel.string =
        `fish2 game ${FishBridge.getGameId()} (Creator stub)\n` +
        `native: ${FishBridge.isAvailable() ? 'yes' : 'no'}\nTap Back to Lobby`;
    }
  }

  onClickBack(): void {
    EnterFish.exit();
  }
}
