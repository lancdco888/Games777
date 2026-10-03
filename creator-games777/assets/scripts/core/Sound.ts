/**
 * Sound facade — port of packagelua/src/base/g_sound.lua (Creator audioEngine).
 * Full AudioSource integration lands with art bundles.
 */
import { AppStorage } from './Storage';

class SoundImpl {
  private bgmId: number | null = null;
  private musicOn = true;
  private effectOn = true;

  constructor() {
    this.musicOn = AppStorage.getBool('music', true);
    this.effectOn = AppStorage.getBool('effect', true);
  }

  isMusicOn(): boolean {
    return this.musicOn;
  }

  isEffectOn(): boolean {
    return this.effectOn;
  }

  setMusicOn(on: boolean): void {
    this.musicOn = on;
    AppStorage.setBool('music', on);
    if (!on) this.stopBgm();
  }

  setEffectOn(on: boolean): void {
    this.effectOn = on;
    AppStorage.setBool('effect', on);
  }

  playBgm(_path: string): number | null {
    if (!this.musicOn) return null;
    // TODO: wire Creator AudioSource / assetManager bundles (hallsound/bg_lobby.mp3)
    this.bgmId = 1;
    return this.bgmId;
  }

  stopBgm(): void {
    this.bgmId = null;
  }

  playEffect(_path: string, _loop = false): number | null {
    if (!this.effectOn) return null;
    return Date.now() % 100000;
  }

  stopEffect(_handle: number | null): void {
    // no-op until AudioSource wired
  }

  getBgmSoundID(): number | null {
    return this.bgmId;
  }
}

export const gSound = new SoundImpl();
