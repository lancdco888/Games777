import { sys } from 'cc';

/**
 * Device / platform helpers — port of packagelua/src/base/Device.lua
 */
export const ScreenType = {
  Landscape: 1,
  Portrait: 2,
} as const;

export type ScreenTypeValue = (typeof ScreenType)[keyof typeof ScreenType];

class DeviceImpl {
  readonly H_Screen_Type = ScreenType.Landscape;
  readonly V_Screen_Type = ScreenType.Portrait;

  private screenType: ScreenTypeValue = ScreenType.Landscape;

  setScreenType(type: ScreenTypeValue): void {
    this.screenType = type;
    // Native orientation bridge will be wired per platform build.
  }

  getScreenType(): ScreenTypeValue {
    return this.screenType;
  }

  GetDeviceID(): string {
    const key = 'creator_device_id';
    let id = sys.localStorage.getItem(key);
    if (!id) {
      id = `creator-${Date.now()}-${Math.floor(Math.random() * 1e6)}`;
      sys.localStorage.setItem(key, id);
    }
    return id;
  }

  GetSystemModel(): string {
    return sys.os || 'unknown';
  }

  GetPhoneType(): string {
    return sys.platform || 'unknown';
  }

  GetPackageName(): string {
    return 'com.games777.creator';
  }

  IsNative(): boolean {
    return sys.isNative;
  }
}

export const Device = new DeviceImpl();
