import { _decorator, Component, director } from 'cc';
import { Coroutines } from '../core/Coroutine';
import { Device } from '../core/Device';
import { SetLang } from '../core/i18n';
import { NetClient } from '../net/NetClient';
import { APIGateway } from '../fgame/APIGateway';

const { ccclass } = _decorator;

/**
 * Boot entry — Creator replacement for bootstrap/src/main.lua → PackageEntry.
 * Flow: Boot → Login → (LogicMain) → Lobby / FGame / fish2
 */
@ccclass('BootApp')
export class BootApp extends Component {
  start(): void {
    // Mark Creator runtime for any shared Lua/TS interop flags
    const g = globalThis as {
      CREATOR?: boolean;
      __CreatorAPIGateway?: typeof APIGateway;
    };
    g.CREATOR = true;
    g.__CreatorAPIGateway = APIGateway;

    Device.setScreenType(Device.H_Screen_Type);
    SetLang('zh');
    NetClient.SetMockMode(true);

    this.schedule((dt: number) => {
      Coroutines.update(dt);
      NetClient.Update();
    }, 0);

    this.scheduleOnce(() => {
      director.loadScene('Login');
    }, 0.1);
  }
}
