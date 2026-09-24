/**
 * Lightweight coroutine scheduler — replaces go() / goexec() / SleepSecs().
 */
type Task = Generator<number | Promise<unknown> | void, void, unknown>;

class CoroutineRunner {
  private tasks: Array<{ gen: Task; waitUntil: number; pending: Promise<unknown> | null }> = [];
  private now = 0;

  go(fn: () => Task | void): void {
    const result = fn();
    if (result && typeof (result as Task).next === 'function') {
      this.tasks.push({ gen: result as Task, waitUntil: 0, pending: null });
    }
  }

  sleep(seconds: number): number {
    return seconds;
  }

  update(dt: number): void {
    this.now += dt;
    const alive: typeof this.tasks = [];
    for (const task of this.tasks) {
      if (task.pending) {
        alive.push(task);
        continue;
      }
      if (this.now < task.waitUntil) {
        alive.push(task);
        continue;
      }
      const step = task.gen.next();
      if (step.done) continue;
      const value = step.value;
      if (typeof value === 'number') {
        task.waitUntil = this.now + value;
        alive.push(task);
      } else if (value && typeof (value as Promise<unknown>).then === 'function') {
        task.pending = value as Promise<unknown>;
        (value as Promise<unknown>)
          .then(() => {
            task.pending = null;
          })
          .catch(() => {
            task.pending = null;
          });
        alive.push(task);
      } else {
        alive.push(task);
      }
    }
    this.tasks = alive;
  }
}

export const Coroutines = new CoroutineRunner();

/** Lua-compatible helper */
export function go(fn: () => Generator | void): void {
  Coroutines.go(fn as () => Generator<number | Promise<unknown> | void, void, unknown> | void);
}

export function SleepSecs(seconds: number): number {
  return Coroutines.sleep(seconds);
}
