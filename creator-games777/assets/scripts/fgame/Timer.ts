/**
 * Timer helpers for FGame on Creator (replaces Special/CocosFish2/Timer.lua).
 */
type TimerHandle = { id: number; cancelled: boolean };

const timers = new Set<TimerHandle>();
let nextId = 1;

export function StartTimer(delaySec: number, cb: () => void, loop = false): TimerHandle {
  const handle: TimerHandle = { id: nextId++, cancelled: false };
  timers.add(handle);

  const tick = () => {
    if (handle.cancelled) return;
    cb();
    if (loop && !handle.cancelled) {
      setTimeout(tick, delaySec * 1000);
    } else {
      timers.delete(handle);
    }
  };
  setTimeout(tick, delaySec * 1000);
  return handle;
}

export function StopTimer(handle: TimerHandle | null): void {
  if (!handle) return;
  handle.cancelled = true;
  timers.delete(handle);
}

export function StopAllTimer(): void {
  for (const t of timers) t.cancelled = true;
  timers.clear();
}
