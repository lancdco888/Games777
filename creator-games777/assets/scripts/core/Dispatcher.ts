/**
 * Event dispatcher — port of packagelua/src/base/Dispatcher.lua
 */
type Handler = (...args: unknown[]) => void;

class DispatcherImpl {
  private listeners = new Map<string, Array<{ target: unknown; handler: Handler }>>();

  Add(event: string, target: unknown, handler: Handler): void {
    let list = this.listeners.get(event);
    if (!list) {
      list = [];
      this.listeners.set(event, list);
    }
    list.push({ target, handler });
  }

  Remove(target: unknown, event?: string): void {
    if (event) {
      const list = this.listeners.get(event);
      if (!list) return;
      this.listeners.set(
        event,
        list.filter((e) => e.target !== target),
      );
      return;
    }
    for (const [key, list] of this.listeners) {
      this.listeners.set(
        key,
        list.filter((e) => e.target !== target),
      );
    }
  }

  Dispatch(event: string, ...args: unknown[]): void {
    const list = this.listeners.get(event);
    if (!list) return;
    for (const { handler } of [...list]) {
      handler(...args);
    }
  }

  Clear(): void {
    this.listeners.clear();
  }
}

export const Dispatcher = new DispatcherImpl();
