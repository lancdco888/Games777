import { XxBuf } from './XxBuf';

/** Marker written by the generated client_login package. */
export const CLIENT_LOGIN_MD5 = '#*MD5<7303ea307c6f011669b18297404b5e45>*#';

const AUTH_BY_USERNAME = 1106;
const REGISTER_ACCOUNT = 1113;
const AUTH_SUCCESS_LOBBY = 1001;
const AUTH_SUCCESS_GAME = 1002;
const REROUTE = 1010;
const REGISTER_INFO = 1012;
const GENERIC_FAIL = 102;
const GENERIC_ERROR = 103;
const ENTER_LOBBY = 2002;
const ENTER_SUCCESS = 1202;
const SELF_ACCOUNT = 501;
const PAY_CHANNEL_ACCOUNT = 502;

export interface AuthFields {
    clientType: string;
    phoneType: number;
    version: string;
    packageName: string;
    deviceId: string;
    username: string;
    accountName: string;
    password: string;
}

export interface ServerAccount {
    id: number;
    username: string;
    nickname: string;
    accountName: string;
    money: number;
    moneyGift: number;
    moneySafe: number;
    moneyGiftSafe: number;
    amountOfGift: number;
    amountOfWashcode: number;
    vipLevel: number;
}

export interface LobbyAuth {
    kind: 'lobby';
    lobbyToken: string;
    username: string;
    accountId: number;
    gameId: number;
    self: ServerAccount | null;
}

export interface GameAuth {
    kind: 'game';
    gameId: number;
    gameIp: string;
    gamePort: number;
    username: string;
    accountId: number;
}

export interface ServerFailure {
    kind: 'error';
    number: number;
    message: string;
}

export interface RegisterInfo {
    kind: 'register';
    accountId: number;
    username: string;
    accountName: string;
}

export interface Reroute {
    kind: 'reroute';
    host: string;
    port: number;
}

export interface EnterLobbyResult {
    kind: 'enter';
    gameIds: number[];
    self: ServerAccount | null;
}

export type ServerPacket = LobbyAuth | GameAuth | ServerFailure | RegisterInfo | Reroute | EnterLobbyResult | { kind: 'unknown'; typeId: number };

export function encodeAuth(fields: AuthFields): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(AUTH_BY_USERNAME);
    writeClientType(buf, fields);
    buf.wstr(CLIENT_LOGIN_MD5);
    buf.wstr(fields.username);
    buf.wstr(fields.accountName);
    buf.wstr('');
    buf.wstr('');
    return buf.toUint8Array();
}

export function encodeRegister(fields: AuthFields): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(REGISTER_ACCOUNT);
    buf.wstr(fields.packageName);
    buf.wstr(fields.clientType);
    buf.wvi32(fields.phoneType);
    buf.wstr(fields.deviceId);
    buf.wstr(fields.accountName);
    buf.wstr(fields.password);
    return buf.toUint8Array();
}

export function encodeEnter(token: string): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(ENTER_LOBBY);
    buf.wstr(token);
    return buf.toUint8Array();
}

export function decodePacket(data: Uint8Array): ServerPacket {
    const reader = new Reader(XxBuf.wrap(data));
    const typeId = reader.buf.rvu();
    reader.keep(typeId);
    if (typeId === AUTH_SUCCESS_LOBBY) {
        return readLobby(reader);
    }
    if (typeId === AUTH_SUCCESS_GAME) {
        return readGame(reader);
    }
    if (typeId === GENERIC_ERROR || typeId === GENERIC_FAIL) {
        return { kind: 'error', number: reader.buf.rvi64(), message: reader.buf.rstr() };
    }
    if (typeId === REGISTER_INFO) {
        return {
            kind: 'register',
            accountId: reader.buf.rvi32(),
            username: reader.buf.rstr(),
            accountName: reader.buf.rstr(),
        };
    }
    if (typeId === REROUTE) {
        return { kind: 'reroute', host: reader.buf.rstr(), port: reader.buf.rvi32() };
    }
    if (typeId === ENTER_SUCCESS) {
        return readEnter(reader);
    }
    return { kind: 'unknown', typeId };
}

export function encodeLobbySuccess(auth: LobbyAuth): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(AUTH_SUCCESS_LOBBY);
    buf.wstr(auth.lobbyToken);
    buf.wstr(auth.username);
    buf.wvi32(auth.accountId);
    buf.wstr('');
    buf.wstr('');
    buf.wvi32(auth.gameId);
    writeAccountRef(buf, auth.self, 2);
    return buf.toUint8Array();
}

export function encodeEnterSuccess(gameIds: number[], self: ServerAccount | null): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(ENTER_SUCCESS);
    buf.wvu(gameIds.length);
    gameIds.forEach((id) => buf.wvi32(id));
    writeAccountRef(buf, self, 2);
    return buf.toUint8Array();
}

function writeClientType(buf: XxBuf, fields: AuthFields): void {
    buf.wstr(fields.clientType);
    buf.wvi32(fields.phoneType);
    buf.wstr('');
    buf.wstr(fields.version);
    buf.wstr(fields.packageName);
    buf.wstr(fields.deviceId);
    buf.wstr('1024');
    buf.wstr('');
    buf.wstr('');
    buf.wstr(fields.password);
}

function writeAccountRef(buf: XxBuf, account: ServerAccount | null, index: number): void {
    if (!account) {
        buf.wu8(0);
        return;
    }
    buf.wvu(index);
    buf.wvu(SELF_ACCOUNT);
    writeAccount(buf, account);
}

function writeAccount(buf: XxBuf, account: ServerAccount): void {
    buf.wvi32(account.id);
    buf.wstr(account.username);
    buf.wstr(account.nickname);
    buf.wstr(account.accountName);
    buf.wvi32(1);
    buf.wstr('');
    buf.wd(account.money);
    buf.wd(account.moneyGift);
    buf.wd(account.moneySafe);
    buf.wd(account.moneyGiftSafe);
    buf.wd(0);
    buf.wd(0);
    buf.wnvi32(null);
    for (let index = 0; index < 8; index += 1) {
        buf.wvi32(0);
    }
    buf.wd(0);
    buf.wd(0);
    buf.wd(0);
    buf.wvi32(0);
    buf.wvi32(0);
    buf.wvu(0);
    buf.wd(account.amountOfGift);
    buf.wd(account.amountOfWashcode);
    buf.wvi32(0);
    buf.wvi32(account.vipLevel);
    buf.wvi32(0);
    buf.wvi32(0);
    buf.wstr('');
}

class Reader {
    readonly seen: number[] = [];
    readonly buf: XxBuf;

    constructor(buf: XxBuf) {
        this.buf = buf;
    }

    keep(typeId: number): void {
        this.seen.push(typeId);
    }

    readRef(): ServerAccount | null {
        const index = this.buf.rvu();
        if (index === 0) {
            return null;
        }
        if (index === this.seen.length + 1) {
            const typeId = this.buf.rvu();
            this.seen.push(typeId);
            if (typeId !== SELF_ACCOUNT) {
                throw new Error(`账号对象类型不是 501（${typeId}）`);
            }
            return readAccount(this);
        }
        throw new Error(`对象序号无法识别（${index}）`);
    }
}

function readLobby(reader: Reader): LobbyAuth {
    const buf = reader.buf;
    const lobbyToken = buf.rstr();
    const username = buf.rstr();
    const accountId = buf.rvi32();
    buf.rstr();
    buf.rstr();
    const gameId = buf.rvi32();
    return { kind: 'lobby', lobbyToken, username, accountId, gameId, self: reader.readRef() };
}

function readGame(reader: Reader): GameAuth {
    const buf = reader.buf;
    return {
        kind: 'game',
        gameId: buf.rvi32(),
        gameIp: buf.rstr(),
        gamePort: buf.rvi16(),
        username: buf.rstr(),
        accountId: buf.rvi32(),
    };
}

function readEnter(reader: Reader): EnterLobbyResult {
    const count = reader.buf.rvu();
    if (count > 500 || count > reader.buf.left) {
        throw new Error('游戏列表长度异常');
    }
    const gameIds: number[] = [];
    for (let index = 0; index < count; index += 1) {
        gameIds.push(reader.buf.rvi32());
    }
    return { kind: 'enter', gameIds, self: reader.readRef() };
}

function readAccount(reader: Reader): ServerAccount {
    const buf = reader.buf;
    const id = buf.rvi32();
    const username = buf.rstr();
    const nickname = buf.rstr();
    const accountName = buf.rstr();
    buf.rvi32();
    buf.rstr();
    const money = buf.rd();
    const moneyGift = buf.rd();
    const moneySafe = buf.rd();
    const moneyGiftSafe = buf.rd();
    buf.rd();
    buf.rd();
    buf.rnvi32();
    for (let index = 0; index < 8; index += 1) {
        buf.rvi32();
    }
    buf.rd();
    buf.rd();
    buf.rd();
    buf.rvi32();
    buf.rvi32();
    const cards = buf.rvu();
    if (cards > 50 || cards > buf.left) {
        throw new Error('银行卡列表长度异常');
    }
    for (let index = 0; index < cards; index += 1) {
        readPayChannel(reader);
    }
    const amountOfGift = buf.rd();
    const amountOfWashcode = buf.rd();
    buf.rvi32();
    const vipLevel = buf.rvi32();
    buf.rvi32();
    buf.rvi32();
    buf.rstr();
    return {
        id,
        username,
        nickname,
        accountName,
        money,
        moneyGift,
        moneySafe,
        moneyGiftSafe,
        amountOfGift,
        amountOfWashcode,
        vipLevel,
    };
}

function readPayChannel(reader: Reader): void {
    const index = reader.buf.rvu();
    if (index === 0) {
        return;
    }
    if (index !== reader.seen.length + 1) {
        return;
    }
    const typeId = reader.buf.rvu();
    reader.seen.push(typeId);
    if (typeId !== PAY_CHANNEL_ACCOUNT) {
        throw new Error(`支付账号类型不是 502（${typeId}）`);
    }
    reader.buf.rvi32();
    reader.buf.rvi32();
    reader.buf.rstr();
    reader.buf.rstr();
    reader.buf.rstr();
}
