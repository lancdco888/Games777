import { sys } from 'cc';

/**
 * Local key-value storage — replaces cc.UserDefault.
 */
class AppStorageImpl {
  getBool(key: string, defaultValue = false): boolean {
    const v = sys.localStorage.getItem(key);
    if (v === null) return defaultValue;
    return v === '1' || v === 'true';
  }

  setBool(key: string, value: boolean): void {
    sys.localStorage.setItem(key, value ? '1' : '0');
  }

  getString(key: string, defaultValue = ''): string {
    return sys.localStorage.getItem(key) ?? defaultValue;
  }

  setString(key: string, value: string): void {
    sys.localStorage.setItem(key, value);
  }

  remove(key: string): void {
    sys.localStorage.removeItem(key);
  }
}

export const AppStorage = new AppStorageImpl();
