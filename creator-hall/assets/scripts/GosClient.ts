import { decodePacket, encodeAuth, encodeEnter, encodeRegister } from './GosPackets';
import type { ServerAccount, ServerPacket } from './GosPackets';
import type { ServerSettings } from './ServerSettings';

/** Empty body, or this serial, tells the client that a service is open. */
export const OPEN_SERIAL = 0x7fffffff;
const CLOSE_SERIAL = 0x7ffffffe;
const MAX_FRAME = 2_000_000;

export interface GosFrame {
    serviceId: number;
    serial: number;
    body: Uint8Array;
}

export interface ServerProfile {
    username: string;
    accountId: number;
    nickname: string;
    money: number;
    moneySafe: number;
    washCode: number;
    giftSafe: number;
    vipLevel: number;
    gameIds: number[];
    lobbyToken: string;
}

interface SocketLike {
    binaryType: string;
    onopen: (() => void) | null;
    onmessage: ((event: { data: unknown }) => void) | null;
    onerror: (() => void) | null;
    onclose: (() => void) | null;
    send(data: string | ArrayBuffer | Uint8Array): void;
    close(): void;
}

/**
 * Speaks the hall login protocol over a local WebSocket-to-TCP bridge.
 * Each TCP frame is little-endian length (not counting itself), serviceId, and serial, then the xx body.
 */
export class GosClient {
    private socket: SocketLike | null = null;
    private readonly stream = new GosStream();
    private readonly inbox: GosFrame[] = [];
    private readonly waiters: Array<(frame: GosFrame | null) => void> = [];
    private linked = false;
    private readonly early: Uint8Array[] = [];
    private serial = 0;
    private generation = 0;
    private failed: Error | null = null;
    private textInbox: string | null = null;

    async loginGuest(settings: ServerSettings): Promise<ServerProfile> {
        return this.login(settings, {
            username: settings.guestUsername,
            accountName: '',
            password: '',
        });
    }

    async loginPassword(settings: ServerSettings, account: string, password: string): Promise<ServerProfile> {
        return this.login(settings, { username: '', accountName: account, password });
    }

    async register(settings: ServerSettings, account: string, password: string): Promise<void> {
        await this.ensure(settings);
        const packet = await this.roundTrip(encodeRegister(this.fields(settings, '', account, password)));
        if (packet.kind === 'error') {
            throw new Error(failureText(packet.number, packet.message));
        }
        if (packet.kind !== 'register') {
            throw new Error(packet.kind === 'unknown' ? `注册返回了未识别的包 ${packet.typeId}` : '注册没有成功');
        }
    }

    close(): void {
        this.generation += 1;
        const socket = this.socket;
        this.socket = null;
        this.linked = false;
        this.stream.reset();
        this.inbox.length = 0;
        this.early.length = 0;
        this.textInbox = null;
        this.textWaiter = null;
        this.fail(new Error('连接已断开'));
        socket?.close();
    }

    private async login(settings: ServerSettings, identity: { username: string; accountName: string; password: string }): Promise<ServerProfile> {
        await this.ensure(settings);
        let packet = await this.roundTrip(encodeAuth(this.fields(settings, identity.username, identity.accountName, identity.password)));
        if (packet.kind === 'reroute') {
            this.close();
            settings.host = packet.host;
            settings.port = String(packet.port);
            await this.ensure(settings);
            packet = await this.roundTrip(encodeAuth(this.fields(settings, identity.username, identity.accountName, identity.password)));
        }
        if (packet.kind === 'error') {
            throw new Error(failureText(packet.number, packet.message));
        }
        if (packet.kind === 'game') {
            throw new Error(`账号还在 ${packet.gameId} 游戏里，请先从原版客户端退出`);
        }
        if (packet.kind !== 'lobby') {
            throw new Error(packet.kind === 'unknown' ? `登录返回了未识别的包 ${packet.typeId}` : '登录没有成功');
        }
        if (packet.gameId !== 0) {
            throw new Error(`账号还在 ${packet.gameId} 游戏里，请先从原版客户端退出`);
        }
        const profile = profileFrom(packet.username, packet.accountId, packet.lobbyToken, packet.self);
        try {
            const entered = await this.roundTrip(encodeEnter(packet.lobbyToken));
            if (entered.kind === 'enter') {
                profile.gameIds = entered.gameIds;
                if (entered.self) {
                    copyAccount(profile, entered.self);
                }
            }
        } catch (error) {
            profile.gameIds = [];
            console.warn(error);
        }
        return profile;
    }

    private fields(settings: ServerSettings, username: string, accountName: string, password: string) {
        return {
            clientType: 'windows',
            phoneType: 3,
            version: settings.version || '1.0.1',
            packageName: settings.packageName || 'com.idh.fjd.fkjh',
            deviceId: settings.deviceId,
            username,
            accountName,
            password,
        };
    }

    private async ensure(settings: ServerSettings): Promise<void> {
        if (this.socket && this.linked && !this.failed) {
            return;
        }
        this.close();
        this.failed = null;
        const generation = this.generation;
        const port = Number(settings.port);
        if (!Number.isInteger(port) || port <= 0 || port > 65535) {
            throw new Error('请填写 goserver 的端口');
        }
        if (!settings.host.trim()) {
            throw new Error('请填写 goserver 的地址');
        }
        const socket = openSocket(settings.bridgeUrl.trim());
        this.socket = socket;
        socket.binaryType = 'arraybuffer';
        socket.onmessage = (event) => {
            if (generation !== this.generation) {
                return;
            }
            void this.accept(event.data);
        };
        socket.onerror = () => {
            if (generation === this.generation) {
                this.fail(new Error(bridgeDown(settings.bridgeUrl)));
            }
        };
        socket.onclose = () => {
            if (generation === this.generation) {
                this.fail(new Error('和 goserver 的连接已断开'));
            }
        };
        await new Promise<void>((resolve, reject) => {
            const timer = setTimeout(() => reject(new Error(bridgeDown(settings.bridgeUrl))), 5000);
            const previous = socket.onerror;
            socket.onopen = () => {
                clearTimeout(timer);
                resolve();
            };
            socket.onerror = () => {
                clearTimeout(timer);
                previous?.();
                reject(new Error(bridgeDown(settings.bridgeUrl)));
            };
        });
        const replyPromise = this.nextText(5000);
        socket.send(JSON.stringify({ host: settings.host.trim(), port }));
        const reply = await replyPromise;
        if (!reply.ok) {
            throw new Error(reply.error || '桥接没有连上 goserver');
        }
        this.linked = true;
        this.early.splice(0).forEach((chunk) => this.consume(chunk));
        await this.waitOpen(5000);
    }

    private async waitOpen(timeoutMs: number): Promise<void> {
        const deadline = Date.now() + timeoutMs;
        while (Date.now() < deadline) {
            if (this.stream.opened.has(0)) {
                return;
            }
            if (this.failed) {
                throw this.failed;
            }
            await delay(20);
        }
    }

    private async roundTrip(body: Uint8Array): Promise<ServerPacket> {
        const serial = this.serial + 1;
        this.serial = serial;
        this.send(packFrame(0, -serial, body));
        const deadline = Date.now() + 10000;
        while (Date.now() < deadline) {
            const frame = await this.nextFrame(deadline - Date.now());
            if (frame.serial === serial) {
                return decodePacket(frame.body);
            }
        }
        throw new Error('服务器未响应');
    }

    private send(frame: Uint8Array): void {
        if (!this.socket || !this.linked) {
            throw new Error('还没有连上服务器');
        }
        this.socket.send(frame);
    }

    private async accept(data: unknown): Promise<void> {
        if (typeof data === 'string') {
            if (this.textWaiter) {
                const waiter = this.textWaiter;
                this.textWaiter = null;
                waiter(data);
            } else {
                this.textInbox = data;
            }
            return;
        }
        const bytes = await toBytes(data);
        if (!this.linked) {
            this.early.push(bytes);
            return;
        }
        this.consume(bytes);
    }

    private consume(chunk: Uint8Array): void {
        try {
            this.stream.push(chunk);
        } catch (error) {
            this.fail(error instanceof Error ? error : new Error('数据包无法解析'));
            return;
        }
        let frame = this.stream.shift();
        while (frame) {
            const waiter = this.waiters.shift();
            if (waiter) {
                waiter(frame);
            } else {
                this.inbox.push(frame);
            }
            frame = this.stream.shift();
        }
    }

    private textWaiter: ((value: string) => void) | null = null;

    private nextText(timeoutMs: number): Promise<{ ok: boolean; error?: string }> {
        if (this.textInbox !== null) {
            const value = this.textInbox;
            this.textInbox = null;
            return Promise.resolve(JSON.parse(value) as { ok: boolean; error?: string });
        }
        return new Promise((resolve, reject) => {
            const timer = setTimeout(() => reject(new Error('桥接没有返回结果')), timeoutMs);
            this.textWaiter = (value) => {
                clearTimeout(timer);
                try {
                    resolve(JSON.parse(value) as { ok: boolean; error?: string });
                } catch {
                    reject(new Error('桥接返回的内容无法识别'));
                }
            };
        });
    }

    private nextFrame(timeoutMs: number): Promise<GosFrame> {
        const queued = this.inbox.shift();
        if (queued) {
            return Promise.resolve(queued);
        }
        return new Promise((resolve, reject) => {
            const timer = setTimeout(() => {
                this.waiters.splice(this.waiters.indexOf(finish), 1);
                reject(new Error('服务器未响应'));
            }, Math.max(1, timeoutMs));
            const finish = (frame: GosFrame | null) => {
                clearTimeout(timer);
                if (!frame) {
                    reject(this.failed ?? new Error('连接已断开'));
                    return;
                }
                resolve(frame);
            };
            this.waiters.push(finish);
        });
    }

    private fail(error: Error): void {
        if (!this.failed) {
            this.failed = error;
        }
        this.linked = false;
        while (this.waiters.length) {
            this.waiters.shift()?.(null);
        }
    }
}

export class GosStream {
    readonly opened = new Set<number>();
    private pending = new Uint8Array(0);
    private readonly queue: GosFrame[] = [];

    reset(): void {
        this.opened.clear();
        this.pending = new Uint8Array(0);
        this.queue.length = 0;
    }

    push(chunk: Uint8Array): void {
        const merged = new Uint8Array(this.pending.length + chunk.length);
        merged.set(this.pending);
        merged.set(chunk, this.pending.length);
        this.pending = merged;
        while (this.pending.length >= 4) {
            const view = new DataView(this.pending.buffer, this.pending.byteOffset, this.pending.byteLength);
            const length = view.getUint32(0, true);
            if (length < 8 || length > MAX_FRAME) {
                const sample = Array.from(this.pending.slice(0, 16)).map((byte) => byte.toString(16).padStart(2, '0')).join(' ');
                throw new Error(`帧长度异常（${length}） ${sample}`);
            }
            if (this.pending.length < 4 + length) {
                return;
            }
            const serviceId = view.getUint32(4, true);
            const serial = view.getInt32(8, true);
            const body = this.pending.slice(12, 4 + length);
            this.pending = this.pending.slice(4 + length);
            if (serviceId === 0xffffffff) {
                continue;
            }
            if (body.length === 0 || serial === OPEN_SERIAL) {
                this.opened.add(serviceId);
                continue;
            }
            if (serial === CLOSE_SERIAL) {
                this.opened.delete(serviceId);
                continue;
            }
            this.opened.add(serviceId);
            this.queue.push({ serviceId, serial, body });
        }
    }

    shift(): GosFrame | undefined {
        return this.queue.shift();
    }
}

export function packFrame(serviceId: number, serial: number, body: Uint8Array): Uint8Array {
    const frame = new Uint8Array(12 + body.length);
    const view = new DataView(frame.buffer);
    view.setUint32(0, 8 + body.length, true);
    view.setUint32(4, serviceId >>> 0, true);
    view.setInt32(8, serial | 0, true);
    frame.set(body, 12);
    return frame;
}

function profileFrom(username: string, accountId: number, lobbyToken: string, self: ServerAccount | null): ServerProfile {
    const profile: ServerProfile = {
        username: self?.username || username,
        accountId: self?.id || accountId,
        nickname: self?.nickname || username,
        money: self?.money ?? 0,
        moneySafe: self?.moneySafe ?? 0,
        washCode: self?.amountOfWashcode ?? 0,
        giftSafe: self?.moneyGiftSafe ?? 0,
        vipLevel: self?.vipLevel ?? 0,
        gameIds: [],
        lobbyToken,
    };
    return profile;
}

function copyAccount(profile: ServerProfile, self: ServerAccount): void {
    profile.username = self.username || profile.username;
    profile.accountId = self.id || profile.accountId;
    profile.nickname = self.nickname || profile.nickname;
    profile.money = self.money;
    profile.moneySafe = self.moneySafe;
    profile.washCode = self.amountOfWashcode;
    profile.giftSafe = self.moneyGiftSafe;
    profile.vipLevel = self.vipLevel;
}

function failureText(number: number, message: string): string {
    if (message.trim()) {
        return message;
    }
    if (number === -6) {
        return '账号已被封停，请稍后再登录';
    }
    if (number === -16666) {
        return '游客登录失败，请改用账号密码';
    }
    return `服务器拒绝了登录（${number}）`;
}

function bridgeDown(url: string): string {
    return `连不上桥接 ${url}。先双击 creator-hall\\open-bridge.bat，窗口保持打开后再登录`;
}

function openSocket(url: string): SocketLike {
    const ctor = (globalThis as { WebSocket?: new (url: string) => SocketLike }).WebSocket;
    if (!ctor) {
        throw new Error('当前环境没有 WebSocket');
    }
    return new ctor(url);
}

async function toBytes(data: unknown): Promise<Uint8Array> {
    if (data instanceof Uint8Array) {
        return data;
    }
    if (data instanceof ArrayBuffer) {
        return new Uint8Array(data);
    }
    if (ArrayBuffer.isView(data)) {
        return new Uint8Array(data.buffer, data.byteOffset, data.byteLength);
    }
    const blob = data as { arrayBuffer?: () => Promise<ArrayBuffer> };
    if (blob && typeof blob.arrayBuffer === 'function') {
        return new Uint8Array(await blob.arrayBuffer());
    }
    throw new Error('收到了无法识别的数据');
}

function delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
}
