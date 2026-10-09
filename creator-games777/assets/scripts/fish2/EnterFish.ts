/**
 * Port of hall enterfishlayer/EnterGame.lua contract.
 * fish2 depends on native Fish2Env / NewCatchFishEnv — bridge is Phase 3.
 */
import { director, log } from 'cc';
import { FishBridge } from './FishBridge';

export const EnterFish = {
  async start(gameId: number): Promise<void> {
    log(`[fish2] EnterFish.start ${gameId}`);
    const ok = await FishBridge.createCatchFish(gameId);
    if (!ok) {
      director.loadScene('FishStub');
      return;
    }
    director.loadScene('FishStub');
  },

  exit(): void {
    FishBridge.destroyCatchFish();
    director.loadScene('Lobby');
  },
};
