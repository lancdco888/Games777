/**
 * FairyGUI bridge stub for Creator.
 * Integrate official FairyGUI-Creator runtime in Phase 2.
 */
import { log } from 'cc';

let rootCreated = false;

export function CreateFairyRoot(): void {
  rootCreated = true;
  log('[FairyGUI] CreateFairyRoot');
}

export function DestroyFairyRoot(): void {
  rootCreated = false;
  log('[FairyGUI] DestroyFairyRoot');
}

export const FairyGUI = {
  UIPackage: {
    AddPackage(path: string): void {
      log(`[FairyGUI] AddPackage ${path}`);
    },
    RemovePackage(path: string): void {
      log(`[FairyGUI] RemovePackage ${path}`);
    },
    CreateObject(pkg: string, res: string): unknown {
      log(`[FairyGUI] CreateObject ${pkg}/${res}`);
      return null;
    },
  },
  IsReady(): boolean {
    return rootCreated;
  },
};
