export interface ServerSettings {
    host: string;
    port: string;
    packageName: string;
    version: string;
    bridgeUrl: string;
    deviceId: string;
    guestUsername: string;
}

export const DEFAULT_SERVER: ServerSettings = {
    host: '127.0.0.1',
    port: '',
    packageName: 'com.idh.fjd.fkjh',
    version: '1.0.1',
    bridgeUrl: 'ws://127.0.0.1:17901',
    deviceId: '',
    guestUsername: '',
};

const STORAGE_KEY = 'creator-hall-goserver';

export function loadServerSettings(): ServerSettings {
    const settings = { ...DEFAULT_SERVER, deviceId: createDeviceId() };
    try {
        const raw = storage()?.getItem(STORAGE_KEY);
        if (!raw) {
            return settings;
        }
        const parsed = JSON.parse(raw) as Partial<ServerSettings>;
        return {
            host: text(parsed.host, settings.host),
            port: text(parsed.port, ''),
            packageName: text(parsed.packageName, settings.packageName),
            version: text(parsed.version, settings.version),
            bridgeUrl: text(parsed.bridgeUrl, settings.bridgeUrl),
            deviceId: text(parsed.deviceId, settings.deviceId),
            guestUsername: text(parsed.guestUsername, ''),
        };
    } catch {
        return settings;
    }
}

export function saveServerSettings(settings: ServerSettings): void {
    try {
        storage()?.setItem(STORAGE_KEY, JSON.stringify(settings));
    } catch {
        // Preview without storage keeps the values on this object.
    }
}

function storage(): { getItem(key: string): string | null; setItem(key: string, value: string): void } | undefined {
    return (globalThis as {
        localStorage?: { getItem(key: string): string | null; setItem(key: string, value: string): void };
    }).localStorage;
}

function text(value: unknown, fallback: string): string {
    return typeof value === 'string' && value.trim() ? value.trim() : fallback;
}

function createDeviceId(): string {
    return `creator-${Date.now().toString(16)}-${Math.floor(Math.random() * 0xffffffff).toString(16)}`;
}
