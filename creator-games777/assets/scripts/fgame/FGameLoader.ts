/**
 * FGame Asset Bundle loader — Creator equivalent of FGCasinoLoading download modules.
 * Bundle names: FGameCommon, FGame{id}
 */
import { assetManager, log } from 'cc';

export function loadFGameBundle(gameId: number): Promise<boolean> {
  return new Promise((resolve) => {
    let pending = 2;
    let ok = true;

    const done = () => {
      pending -= 1;
      if (pending <= 0) resolve(ok);
    };

    assetManager.loadBundle('FGameCommon', (err) => {
      if (err) {
        log('[FGameLoader] FGameCommon missing:', err.message);
        ok = false;
      }
      done();
    });

    assetManager.loadBundle(`FGame${gameId}`, (err) => {
      if (err) {
        log(`[FGameLoader] FGame${gameId} missing:`, err.message);
        ok = false;
      }
      done();
    });
  });
}
