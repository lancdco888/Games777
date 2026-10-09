/**
 * Native fish runtime bridge.
 * Lua path: Env = NewCatchFishEnv or Fish2Env (C++), script under fish2/script/.
 */
import { log, sys } from 'cc';

let active = false;
let activeGameId = -1;

export const FishBridge = {
  isAvailable(): boolean {
    // Native plugin registration will set this true
    return !!(globalThis as { Fish2Env?: unknown; NewCatchFishEnv?: unknown }).Fish2Env
      || !!(globalThis as { NewCatchFishEnv?: unknown }).NewCatchFishEnv;
  },

  async createCatchFish(gameId: number): Promise<boolean> {
    activeGameId = gameId;
    if (!this.isAvailable()) {
      log(`[fish2] native env missing on ${sys.platform} — using stub scene`);
      active = true;
      return false;
    }
    // TODO: pass main scene + NetClient into native Env like Game.lua CreateCatchFish
    active = true;
    return true;
  },

  destroyCatchFish(): void {
    active = false;
    activeGameId = -1;
  },

  isActive(): boolean {
    return active;
  },

  getGameId(): number {
    return activeGameId;
  },
};
