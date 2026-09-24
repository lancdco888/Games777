import { Reader } from './GosPackets';
import type { ServerAccount, ServerFailure, ServerPacket } from './GosPackets';
import { XxBuf } from './XxBuf';

const SUCCESS = 101;
const ENTER_GAME = 2003;
const ENTER_SLOTS = 1215;
const CHANGE_SAFE = 2019;
const SAFE_OK = 1224;
const GIFT_SAFE = 2063;
const RELIEF = 2110;
const RELIEF_OK = 1334;
const GIFT = 2034;
const GIFT_OK = 1243;
const GIFT_PASSWORD = 2033;
const NICKNAME = 2009;
const NICKNAME_OK = 1219;
const PASSWORD = 2015;
const BIND_ACCOUNT = 2053;
const SIGN_IN = 2043;
const SIGN_IN_OK = 1257;
const RECHARGE = 2029;
const RECHARGE_OK = 1239;
const WEBSITE = 2031;
const WEBSITE_OK = 1240;
const PHONE_CODE = 2111;
const PHONE_BIND = 2112;
const PHONE_OK = 1336;
const ACTIVITY = 2066;
const ACTIVITY_OK = 1294;
const ACTIVITY_ITEM = 1290;
const WASH_INFO = 2103;
const WASH_INFO_OK = 1324;
const WASH_TAKE = 2104;
const WASH_TAKE_OK = 1325;
const PLAYER = 2105;
const PLAYER_OK = 1326;
const FAQ = 2057;
const FAQ_OK = 1276;
const FAQ_ITEM = 1275;
const NOTICE = 2020;
const NOTICES = 1228;
const NOTICE_ITEM = 1227;
const SLOTS_ENTER = 30111;
const SLOTS_ENTER_OK = 30104;
const SLOTS_LEAVE = 30113;
const SLOTS_LEAVE_OK = 30102;
const SLOTS_LOCK_LEAVE_OK = 30103;
const NORMAL_SPIN = 30614;
const FREE_SPIN = 30615;
const SPECIAL_SPIN = 30616;
const NORMAL_RET = 30617;
const FREE_RET = 30618;
const SPECIAL_RET = 30619;
const RESUME = 30620;

export const REEL_COUNT = 5;
export const ROW_COUNT = 3;

export interface SlotCell {
    index: number;
    icon: number;
    symbolType: number;
    symbolValue: number;
    symbolBet: number;
    hidden: number;
}

export interface SlotLine {
    lineIndex: number;
    winCoin: number;
    icon: number;
    cells: SlotCell[];
}

export interface SlotBalances {
    money: number;
    moneySafe: number;
    gift: number;
    giftSafe: number;
}

export interface SlotBet {
    money: number;
    line: number;
    lvID: number;
}

export interface SpinBody {
    bet: number;
    winCoin: number;
    cells: SlotCell[];
    intoFree: number;
    intoSpecial: number;
    lines: SlotLine[];
    bonusWinCoin: number;
    allCount: number;
    totalCount: number;
    addTime: number;
    allWinCoin: number;
    lockStates: number;
    balances: SlotBalances;
}

export interface SlotSeat {
    kind: 'slotSeat';
    accountId: number;
    userName: string;
    nickName: string;
    moneyType: number;
    bets: SlotBet[];
    balances: SlotBalances;
    columns: number[][];
    win: number;
    mode: 'normal' | 'free' | 'special';
    note: string;
}

export type PlayPacket =
    | { kind: 'ok' }
    | { kind: 'nickname'; nickname: string }
    | { kind: 'safe'; money: number; moneySafe: number; moneyGift: number; moneyGiftSafe: number }
    | { kind: 'relief'; money: number }
    | { kind: 'giftResult'; money: number; moneySafe: number }
    | { kind: 'signin'; giveMoney: number; currMoney: number }
    | { kind: 'recharge'; payUrl: string; orderNum: string }
    | { kind: 'website'; website: string; qrcode: string }
    | { kind: 'phone'; success: boolean; phone: string }
    | { kind: 'player'; self: ServerAccount | null }
    | { kind: 'activity'; items: Array<{ id: number; open: number; config: string }>; firstRecharge: number }
    | { kind: 'wash'; activityId: number; canGive: number }
    | { kind: 'washReward'; activityId: number; rewardType: number; rewardValue: number }
    | { kind: 'faq'; items: Array<{ id: number; question: string; answer: string }> }
    | { kind: 'notices'; items: Array<{ title: string; content: string }>; appUrl: string }
    | { kind: 'enterSlots'; gameId: number; serviceId: number }
    | SlotSeat
    | { kind: 'slotLeft' }
    | { kind: 'normalSpin'; spin: SpinBody }
    | { kind: 'freeSpin'; spin: SpinBody }
    | { kind: 'specialSpin'; spin: SpinBody };

export type WirePacket = ServerPacket | PlayPacket;

export function encodeType(typeId: number): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(typeId);
    return buf.toUint8Array();
}

export function encodeEnterGame(gameId: number): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(ENTER_GAME);
    buf.wvi32(gameId);
    return buf.toUint8Array();
}

export function encodeNormalSpin(betMoney: number, moneyType: number, lvID: number): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(NORMAL_SPIN);
    buf.wd(betMoney);
    buf.wvi32(moneyType);
    buf.wvi32(lvID);
    return buf.toUint8Array();
}

export function encodeFreeSpin(): Uint8Array {
    return encodeType(FREE_SPIN);
}

export function encodeSpecialSpin(): Uint8Array {
    return encodeType(SPECIAL_SPIN);
}

export function encodeSlotsEnter(): Uint8Array {
    return encodeType(SLOTS_ENTER);
}

export function encodeSlotsLeave(): Uint8Array {
    return encodeType(SLOTS_LEAVE);
}

export function encodeChangeSafe(accountId: number, money: number, wash: boolean): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(wash ? GIFT_SAFE : CHANGE_SAFE);
    buf.wvi32(accountId);
    buf.wd(money);
    return buf.toUint8Array();
}

export function encodeGift(accountId: number, money: number, password: string): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(GIFT);
    buf.wvi32(accountId);
    buf.wd(money);
    buf.wstr(password);
    return buf.toUint8Array();
}

export function encodeGiftPassword(password: string): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(GIFT_PASSWORD);
    buf.wstr(password);
    return buf.toUint8Array();
}

export function encodeNickname(nickname: string): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(NICKNAME);
    buf.wstr(nickname);
    return buf.toUint8Array();
}

export function encodePassword(oldPassword: string, newPassword: string): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(PASSWORD);
    buf.wstr(oldPassword);
    buf.wstr(newPassword);
    buf.wstr('');
    return buf.toUint8Array();
}

export function encodeBindAccount(account: string, password: string): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(BIND_ACCOUNT);
    buf.wstr(account);
    buf.wstr(password);
    return buf.toUint8Array();
}

export function encodeRecharge(money: number): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(RECHARGE);
    buf.wd(money);
    buf.wvi32(2);
    buf.wstr('');
    buf.wvi32(1);
    buf.wstr('');
    buf.wstr('');
    buf.wstr('');
    buf.wstr('');
    return buf.toUint8Array();
}

export function encodePhoneCode(phone: string): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(PHONE_CODE);
    buf.wstr(phone);
    return buf.toUint8Array();
}

export function encodePhoneBind(code: string): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(PHONE_BIND);
    buf.wstr(code);
    return buf.toUint8Array();
}

export function encodeWashInfo(activityId: number): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(WASH_INFO);
    buf.wvi32(activityId);
    return buf.toUint8Array();
}

export function encodeWashTake(activityId: number): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(WASH_TAKE);
    buf.wvi32(activityId);
    return buf.toUint8Array();
}

export function encodeRelief(): Uint8Array {
    return encodeType(RELIEF);
}

export function encodeSignIn(): Uint8Array {
    return encodeType(SIGN_IN);
}

export function encodeActivity(): Uint8Array {
    return encodeType(ACTIVITY);
}

export function encodeWebsite(): Uint8Array {
    return encodeType(WEBSITE);
}

export function encodePlayer(): Uint8Array {
    return encodeType(PLAYER);
}

export function encodeFaq(): Uint8Array {
    return encodeType(FAQ);
}

export function encodeNotice(): Uint8Array {
    return encodeType(NOTICE);
}

export function decodePlay(data: Uint8Array): PlayPacket | null {
    const reader = new Reader(XxBuf.wrap(data));
    const typeId = reader.buf.rvu();
    reader.keep(typeId);
    return readPlay(typeId, reader);
}

/** 1-based index, five columns, row 0 at the top. Matches BaseSlot.GetReelIndex / GetCellIndex. */
export function cellsToColumns(cells: SlotCell[], rows = ROW_COUNT): number[][] {
    const columns = Array.from({ length: REEL_COUNT }, () => Array.from({ length: rows }, () => 8));
    cells.forEach((cell) => {
        if (cell.index <= 0 || cell.hidden) {
            return;
        }
        const column = (cell.index - 1) % REEL_COUNT;
        const row = Math.floor((cell.index - 1) / REEL_COUNT);
        if (row >= 0 && row < rows) {
            columns[column][row] = cell.icon > 0 ? cell.icon : 8;
        }
    });
    return columns;
}

export function explain(packet: WirePacket): string | null {
    if (packet.kind === 'error') {
        return failureText(packet);
    }
    return null;
}

export function failureText(packet: ServerFailure): string {
    if (packet.message.trim()) {
        return packet.message;
    }
    return `服务器拒绝了操作（${packet.number}）`;
}

export function encodeSampleSeat(): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(SLOTS_ENTER_OK);
    buf.wvi32(9236);
    buf.wstr('guest-7');
    buf.wstr('游客七');
    buf.wvi32(1);
    buf.wd(99000);
    buf.wd(1200);
    buf.wd(0);
    buf.wd(0);
    buf.wvu(1);
    buf.wd(100);
    buf.wvi32(50);
    buf.wvi32(1);
    buf.wvu(0);
    buf.wvi32(0);
    buf.wvi32(0);
    buf.wvi32(0);
    buf.wvi32(0);
    buf.wvu(0);
    writeBalances(buf, { money: 99000, moneySafe: 1200, gift: 0, giftSafe: 0 });
    buf.wvi32(0);
    return buf.toUint8Array();
}

export function encodeSampleNormal(): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(NORMAL_RET);
    buf.wd(100);
    buf.wd(80);
    buf.wvu(3);
    writeCell(buf, { index: 1, icon: 4, symbolType: 0, symbolValue: 0, symbolBet: 0, hidden: 0 });
    writeCell(buf, { index: 6, icon: 5, symbolType: 2, symbolValue: 400, symbolBet: 0, hidden: 0 });
    writeCell(buf, { index: 11, icon: 6, symbolType: 0, symbolValue: 0, symbolBet: 0, hidden: 0 });
    buf.wvi32(0);
    buf.wvi32(0);
    buf.wvu(0);
    writeBalances(buf, { money: 90000, moneySafe: 1200, gift: 0, giftSafe: 0 });
    buf.wvi64(0);
    buf.wvu(0);
    return buf.toUint8Array();
}

export function encodeEnterSlots(gameId: number, serviceId: number): Uint8Array {
    const buf = new XxBuf();
    buf.wvu(ENTER_SLOTS);
    buf.wvi32(gameId);
    buf.wvi32(serviceId);
    return buf.toUint8Array();
}

function readPlay(typeId: number, reader: Reader): PlayPacket | null {
    const buf = reader.buf;
    if (typeId === SUCCESS || typeId === SLOTS_LEAVE_OK || typeId === SLOTS_LOCK_LEAVE_OK) {
        return typeId === SUCCESS ? { kind: 'ok' } : { kind: 'slotLeft' };
    }
    if (typeId === NICKNAME_OK) {
        return { kind: 'nickname', nickname: buf.rstr() };
    }
    if (typeId === SAFE_OK) {
        return {
            kind: 'safe',
            money: buf.rd(),
            moneySafe: buf.rd(),
            moneyGift: buf.rd(),
            moneyGiftSafe: buf.rd(),
        };
    }
    if (typeId === RELIEF_OK) {
        return { kind: 'relief', money: buf.rd() };
    }
    if (typeId === GIFT_OK) {
        return { kind: 'giftResult', money: buf.rd(), moneySafe: buf.rd() };
    }
    if (typeId === SIGN_IN_OK) {
        return { kind: 'signin', giveMoney: buf.rd(), currMoney: buf.rd() };
    }
    if (typeId === RECHARGE_OK) {
        return { kind: 'recharge', payUrl: buf.rstr(), orderNum: buf.rstr() };
    }
    if (typeId === WEBSITE_OK) {
        return { kind: 'website', website: buf.rstr(), qrcode: buf.rstr() };
    }
    if (typeId === PHONE_OK) {
        return { kind: 'phone', success: buf.rb(), phone: buf.rstr() };
    }
    if (typeId === PLAYER_OK) {
        return { kind: 'player', self: reader.readRef() };
    }
    if (typeId === ACTIVITY_OK) {
        return readActivity(reader);
    }
    if (typeId === WASH_INFO_OK) {
        return { kind: 'wash', activityId: buf.rvi32(), canGive: buf.rvi32() };
    }
    if (typeId === WASH_TAKE_OK) {
        return { kind: 'washReward', activityId: buf.rvi32(), rewardType: buf.rvi32(), rewardValue: buf.rvi64() };
    }
    if (typeId === FAQ_OK) {
        return readFaq(reader);
    }
    if (typeId === NOTICES) {
        return readNotices(reader);
    }
    if (typeId === ENTER_SLOTS) {
        return { kind: 'enterSlots', gameId: buf.rvi32(), serviceId: buf.rvi32() };
    }
    if (typeId === SLOTS_ENTER_OK) {
        return readSeat(reader, 'normal', 0, '');
    }
    if (typeId === RESUME) {
        return readResume(reader);
    }
    if (typeId === NORMAL_RET) {
        return { kind: 'normalSpin', spin: readNormal(reader) };
    }
    if (typeId === FREE_RET) {
        return { kind: 'freeSpin', spin: readFree(reader) };
    }
    if (typeId === SPECIAL_RET) {
        return { kind: 'specialSpin', spin: readSpecial(reader) };
    }
    return null;
}

function readActivity(reader: Reader): PlayPacket {
    const count = readCount(reader.buf);
    const items: Array<{ id: number; open: number; config: string }> = [];
    for (let index = 0; index < count; index += 1) {
        const item = reader.readObject((typeId, buf) => {
            if (typeId !== ACTIVITY_ITEM) {
                throw new Error(`活动对象类型不是 1290（${typeId}）`);
            }
            return { id: buf.rvi32(), open: buf.rvi32(), config: buf.rstr() };
        }) as { id: number; open: number; config: string } | null;
        if (item) {
            items.push(item);
        }
    }
    return { kind: 'activity', items, firstRecharge: reader.buf.rvi32() };
}

function readFaq(reader: Reader): PlayPacket {
    const count = readCount(reader.buf);
    const items: Array<{ id: number; question: string; answer: string }> = [];
    for (let index = 0; index < count; index += 1) {
        const item = reader.readObject((typeId, buf) => {
            if (typeId !== FAQ_ITEM) {
                throw new Error(`客服问题类型不是 1275（${typeId}）`);
            }
            return { id: buf.rvi32(), question: buf.rstr(), answer: buf.rstr(), images: buf.rstr() };
        }) as { id: number; question: string; answer: string } | null;
        if (item) {
            items.push({ id: item.id, question: item.question, answer: item.answer });
        }
    }
    return { kind: 'faq', items };
}

function readNotices(reader: Reader): PlayPacket {
    const count = readCount(reader.buf);
    const items: Array<{ title: string; content: string }> = [];
    for (let index = 0; index < count; index += 1) {
        const item = reader.readObject((typeId, buf) => {
            if (typeId !== NOTICE_ITEM) {
                throw new Error(`公告类型不是 1227（${typeId}）`);
            }
            const id = buf.rvi32();
            const title = buf.rstr();
            const content = buf.rstr();
            buf.rstr();
            buf.rstr();
            buf.rvi64();
            buf.rvi32();
            buf.rvi32();
            buf.rvi32();
            buf.rvi32();
            buf.rstr();
            return { id, title, content };
        }) as { title: string; content: string } | null;
        if (item) {
            items.push(item);
        }
    }
    return { kind: 'notices', items, appUrl: reader.buf.rstr() };
}

function readSeat(reader: Reader, mode: SlotSeat['mode'], win: number, note: string): SlotSeat {
    const buf = reader.buf;
    const accountId = buf.rvi32();
    const userName = buf.rstr();
    const nickName = buf.rstr();
    buf.rvi32();
    buf.rd();
    buf.rd();
    buf.rd();
    buf.rd();
    const betCount = readCount(buf);
    const bets: SlotBet[] = [];
    for (let index = 0; index < betCount; index += 1) {
        bets.push({ money: buf.rd(), line: buf.rvi32(), lvID: buf.rvi32() });
    }
    const levelCount = readCount(buf);
    for (let index = 0; index < levelCount; index += 1) {
        buf.rvi32();
        buf.rd();
        buf.rd();
        buf.rd();
        buf.rstr();
        buf.rvi32();
        buf.rvi32();
    }
    buf.rvi32();
    buf.rvi32();
    buf.rvi32();
    buf.rvi32();
    const playerCount = readCount(buf);
    for (let index = 0; index < playerCount; index += 1) {
        buf.rvi32();
        buf.rstr();
        buf.rstr();
        buf.rvi32();
        buf.rvi32();
        buf.rvi32();
    }
    const balances = readBalances(buf);
    const moneyType = buf.rvi32();
    return {
        kind: 'slotSeat',
        accountId,
        userName,
        nickName,
        moneyType,
        bets,
        balances,
        columns: cellsToColumns([]),
        win,
        mode,
        note,
    };
}

function readResume(reader: Reader): SlotSeat {
    const seat = readSeat(reader, 'normal', 0, '');
    const buf = reader.buf;
    const currentWin = buf.rd();
    buf.rd();
    const lvID = buf.rvi32();
    const type = buf.rvi32();
    const normal = readNormal(reader);
    const free = readFree(reader);
    const special = readSpecial(reader);
    if (lvID) {
        seat.bets = seat.bets.length ? seat.bets : [{ money: normal.bet || free.bet || special.bet, line: 50, lvID }];
    }
    if (type === 2 && free.totalCount < free.allCount) {
        seat.mode = 'free';
        seat.columns = cellsToColumns(free.cells);
        seat.win = currentWin || free.winCoin;
        seat.balances = free.balances.money ? free.balances : seat.balances;
        seat.note = `免费游戏 ${free.totalCount}/${free.allCount}`;
        return seat;
    }
    if (type === 3 && special.totalCount > 0) {
        seat.mode = 'special';
        seat.columns = cellsToColumns(special.cells);
        seat.win = currentWin || special.winCoin;
        seat.balances = special.balances.money ? special.balances : seat.balances;
        seat.note = `特别游戏 剩余 ${special.totalCount}`;
        return seat;
    }
    seat.columns = cellsToColumns(normal.cells);
    seat.win = currentWin || normal.winCoin;
    seat.balances = normal.balances.money ? normal.balances : seat.balances;
    seat.note = '已恢复上次牌面';
    return seat;
}

function readNormal(reader: Reader): SpinBody {
    const buf = reader.buf;
    const bet = buf.rd();
    const winCoin = buf.rd();
    const cells = readCells(buf);
    const intoFree = buf.rvi32();
    const intoSpecial = buf.rvi32();
    const lines = readLines(buf);
    const balances = readBalances(buf);
    buf.rvi64();
    const extra = readCount(buf);
    for (let index = 0; index < extra; index += 1) {
        buf.rvi64();
    }
    return emptySpin(bet, winCoin, cells, intoFree, intoSpecial, lines, balances);
}

function readFree(reader: Reader): SpinBody {
    const buf = reader.buf;
    const bet = buf.rd();
    const winCoin = buf.rd();
    const cells = readCells(buf);
    const bonusWinCoin = buf.rd();
    const allCount = buf.rvi32();
    const totalCount = buf.rvi32();
    const lines = readLines(buf);
    const addTime = buf.rvi32();
    const intoSpecial = buf.rvi32();
    const lockStates = buf.rvi32();
    const balances = readBalances(buf);
    return {
        ...emptySpin(bet, winCoin, cells, 0, intoSpecial, lines, balances),
        bonusWinCoin,
        allCount,
        totalCount,
        addTime,
        lockStates,
    };
}

function readSpecial(reader: Reader): SpinBody {
    const buf = reader.buf;
    const bet = buf.rd();
    const winCoin = buf.rd();
    const cells = readCells(buf);
    const bonusWinCoin = buf.rd();
    const allCount = buf.rvi32();
    const totalCount = buf.rvi32();
    const lines = readLines(buf);
    const addTime = buf.rvi32();
    const allWinCoin = buf.rd();
    const lockStates = buf.rvi32();
    const balances = readBalances(buf);
    return {
        ...emptySpin(bet, winCoin, cells, 0, 0, lines, balances),
        bonusWinCoin,
        allCount,
        totalCount,
        addTime,
        allWinCoin,
        lockStates,
    };
}

function emptySpin(
    bet: number,
    winCoin: number,
    cells: SlotCell[],
    intoFree: number,
    intoSpecial: number,
    lines: SlotLine[],
    balances: SlotBalances,
): SpinBody {
    return {
        bet,
        winCoin,
        cells,
        intoFree,
        intoSpecial,
        lines,
        bonusWinCoin: 0,
        allCount: 0,
        totalCount: 0,
        addTime: 0,
        allWinCoin: 0,
        lockStates: 0,
        balances,
    };
}

function readCells(buf: XxBuf): SlotCell[] {
    const count = readCount(buf);
    const cells: SlotCell[] = [];
    for (let index = 0; index < count; index += 1) {
        cells.push({
            index: buf.rvi32(),
            icon: buf.rvi32(),
            symbolType: buf.rvi32(),
            symbolValue: buf.rd(),
            symbolBet: buf.rvi32(),
            hidden: buf.rvi32(),
        });
    }
    return cells;
}

function readLines(buf: XxBuf): SlotLine[] {
    const count = readCount(buf);
    const lines: SlotLine[] = [];
    for (let index = 0; index < count; index += 1) {
        lines.push({
            lineIndex: buf.rvi32(),
            winCoin: buf.rd(),
            icon: buf.rvi32(),
            cells: readCells(buf),
        });
    }
    return lines;
}

function readBalances(buf: XxBuf): SlotBalances {
    const gift = buf.rvi64();
    const giftSafe = buf.rvi64();
    buf.rvi64();
    return { money: buf.rvi64(), moneySafe: buf.rvi64(), gift, giftSafe };
}

function writeCell(buf: XxBuf, cell: SlotCell): void {
    buf.wvi32(cell.index);
    buf.wvi32(cell.icon);
    buf.wvi32(cell.symbolType);
    buf.wd(cell.symbolValue);
    buf.wvi32(cell.symbolBet);
    buf.wvi32(cell.hidden);
}

function writeBalances(buf: XxBuf, balances: SlotBalances): void {
    buf.wvi64(balances.gift);
    buf.wvi64(balances.giftSafe);
    buf.wvi64(0);
    buf.wvi64(balances.money);
    buf.wvi64(balances.moneySafe);
}

function readCount(buf: XxBuf): number {
    const count = buf.rvu();
    if (count > 400 || count > buf.left) {
        throw new Error('列表长度异常');
    }
    return count;
}
