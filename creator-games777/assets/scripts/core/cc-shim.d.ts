/**
 * Minimal Cocos Creator ambient stubs for typecheck outside the editor.
 * When opened in Creator 3.8+, real `cc` types from the engine override these.
 */
declare module 'cc' {
  export const _decorator: {
    ccclass: (name?: string) => ClassDecorator;
    property: (opts?: unknown) => PropertyDecorator;
  };

  export class Component {
    node: Node;
    schedule(callback: (dt: number) => void, interval?: number): void;
    scheduleOnce(callback: () => void, delay?: number): void;
    unschedule(callback: (...args: unknown[]) => void): void;
  }

  export class Node {
    name: string;
    parent: Node | null;
    addChild(child: Node): void;
    removeFromParent(): void;
    getChildByName(name: string): Node | null;
    getComponent<T extends Component>(type: { new (): T } | string): T | null;
    addComponent<T extends Component>(type: { new (): T }): T;
  }

  export class Label extends Component {
    string: string;
  }

  export class Button extends Component {
    node: Node;
  }

  export class EditBox extends Component {
    string: string;
  }

  export class Sprite extends Component {}

  export class Canvas extends Component {}

  export class UITransform extends Component {
    setContentSize(w: number, h: number): void;
  }

  export class Color {
    constructor(r?: number, g?: number, b?: number, a?: number);
    static WHITE: Color;
    static BLACK: Color;
  }

  export class Vec3 {
    constructor(x?: number, y?: number, z?: number);
    x: number;
    y: number;
    z: number;
  }

  export const director: {
    loadScene(name: string, onLaunched?: () => void): void;
    getScene(): { name: string } | null;
  };

  export const game: {
    frameRate: number;
  };

  export const sys: {
    platform: string;
    os: string;
    localStorage: {
      getItem(key: string): string | null;
      setItem(key: string, value: string): void;
      removeItem(key: string): void;
    };
    isNative: boolean;
    isBrowser: boolean;
  };

  export const audioEngine: {
    play(url: string, loop: boolean, volume?: number): number;
    stop(id: number): void;
    setVolume(id: number, volume: number): void;
  };

  export const assetManager: {
    loadBundle(name: string, cb: (err: Error | null, bundle: unknown) => void): void;
  };

  export const resources: {
    load<T>(path: string, type: unknown, cb: (err: Error | null, asset: T) => void): void;
  };

  export const log: (...args: unknown[]) => void;
  export const warn: (...args: unknown[]) => void;
  export const error: (...args: unknown[]) => void;
}

declare const CREATOR: boolean | undefined;
