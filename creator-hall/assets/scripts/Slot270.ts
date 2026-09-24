import type { GosClient } from './GosClient';
import {
    cellsToColumns,
    encodeEnterGame,
    encodeFreeSpin,
    encodeNormalSpin,
    encodeSlotsEnter,
    encodeSlotsLeave,
    encodeSpecialSpin,
    explain,
} from './ServerPlay';
import type { SlotBalances, SlotBet, SlotCell, SpinBody, WirePacket } from './ServerPlay';

export interface SpinStep {
    columns: number[][];
    win: number;
    note: string;
    balances: SlotBalances;
    jackpots: Array<number | null>;
}

export interface OpenedSlot {
    bets: SlotBet[];
    moneyType: number;
    columns: number[][];
    win: number;
    note: string;
    balances: SlotBalances;
}

/**
 * Game 270 on the slots service: EnterGame, Slots_Enter, then normal / free / special spins.
 * Results come from the server. Local reels are only the animation.
 */
export class Slot270Session {
    serviceId = 0;
    moneyType = 0;
    lvID = 1;
    bets: SlotBet[] = [];
    mode: 'normal' | 'free' | 'special' = 'normal';
    private readonly client: GosClient;
    private readonly onMoney: (balances: SlotBalances) => void;

    constructor(client: GosClient, onMoney: (balances: SlotBalances) => void) {
        this.client = client;
        this.onMoney = onMoney;
    }

    async enter(gameId: number): Promise<OpenedSlot> {
        const opened = await this.client.request(0, encodeEnterGame(gameId));
        const refused = explain(opened);
        if (refused) {
            throw new Error(refused);
        }
        if (opened.kind !== 'enterSlots') {
            throw new Error(unexpected(opened));
        }
        this.serviceId = opened.serviceId;
        const seat = await this.client.request(this.serviceId, encodeSlotsEnter());
        const seatError = explain(seat);
        if (seatError) {
            throw new Error(seatError);
        }
        if (seat.kind !== 'slotSeat') {
            throw new Error(unexpected(seat));
        }
        this.moneyType = seat.moneyType;
        this.bets = seat.bets;
        this.lvID = seat.bets[0]?.lvID ?? 1;
        this.mode = seat.mode;
        this.onMoney(seat.balances);
        return {
            bets: seat.bets,
            moneyType: seat.moneyType,
            columns: seat.columns,
            win: seat.win,
            note: seat.note,
            balances: seat.balances,
        };
    }

    async spin(betMoney: number): Promise<SpinStep[]> {
        if (!this.serviceId) {
            throw new Error('还没有进入 270');
        }
        const steps: SpinStep[] = [];
        if (this.mode === 'normal') {
            const bet = this.bets.find((item) => item.money === betMoney) ?? this.bets[0];
            const lvID = bet?.lvID ?? this.lvID;
            this.lvID = lvID;
            const packet = await this.client.request(this.serviceId, encodeNormalSpin(betMoney, this.moneyType, lvID));
            const spin = takeSpin(packet, 'normalSpin');
            steps.push(this.step(spin, spin.winCoin, spin.intoFree === 1 ? '进入免费游戏' : spin.intoSpecial === 1 ? '进入特别游戏' : ''));
            if (spin.intoFree === 1) {
                this.mode = 'free';
            } else if (spin.intoSpecial === 1) {
                this.mode = 'special';
            }
        }
        let freeGuard = 0;
        while (this.mode === 'free' && freeGuard < 24) {
            freeGuard += 1;
            const packet = await this.client.request(this.serviceId, encodeFreeSpin());
            const spin = takeSpin(packet, 'freeSpin');
            const ended = spin.totalCount >= spin.allCount;
            const win = ended ? spin.winCoin + spin.bonusWinCoin : spin.winCoin;
            steps.push(this.step(spin, win, `免费 ${spin.totalCount}/${spin.allCount}`));
            if (spin.intoSpecial === 1) {
                this.mode = 'special';
                break;
            }
            if (ended) {
                this.mode = 'normal';
                break;
            }
        }
        let specialGuard = 0;
        while (this.mode === 'special' && specialGuard < 24) {
            specialGuard += 1;
            const packet = await this.client.request(this.serviceId, encodeSpecialSpin());
            const spin = takeSpin(packet, 'specialSpin');
            const win = spin.totalCount <= 0 && spin.allWinCoin > spin.winCoin ? spin.allWinCoin : spin.winCoin;
            steps.push(this.step(spin, win, spin.totalCount > 0 ? `特别游戏 剩余 ${spin.totalCount}` : '特别游戏结束'));
            if (spin.totalCount <= 0) {
                this.mode = 'normal';
                break;
            }
        }
        if (!steps.length) {
            throw new Error('服务器没有返回开奖');
        }
        return steps;
    }

    async leave(): Promise<void> {
        if (!this.serviceId) {
            return;
        }
        const serviceId = this.serviceId;
        this.serviceId = 0;
        try {
            await this.client.request(serviceId, encodeSlotsLeave());
        } catch {
            // Leaving the table still returns the player to the hall.
        }
    }

    private step(spin: SpinBody, win: number, note: string): SpinStep {
        this.onMoney(spin.balances);
        return {
            columns: cellsToColumns(spin.cells),
            win,
            note,
            balances: spin.balances,
            jackpots: jackpotsFrom(spin.cells),
        };
    }
}

function takeSpin(packet: WirePacket, kind: 'normalSpin' | 'freeSpin' | 'specialSpin'): SpinBody {
    const refused = explain(packet);
    if (refused) {
        throw new Error(refused);
    }
    if (packet.kind !== kind) {
        throw new Error(unexpected(packet));
    }
    return packet.spin;
}

function unexpected(packet: WirePacket): string {
    if (packet.kind === 'unknown') {
        return `服务器返回了未识别的包 ${packet.typeId}`;
    }
    return `服务器返回了未识别的包 ${packet.kind}`;
}

function jackpotsFrom(cells: SlotCell[]): Array<number | null> {
    const values: Array<number | null> = [null, null, null, null];
    cells.forEach((cell) => {
        const slot = cell.symbolType === 5 ? 0 : cell.symbolType === 4 ? 1 : cell.symbolType === 3 ? 2 : cell.symbolType === 2 ? 3 : -1;
        if (slot >= 0 && cell.symbolValue > 0) {
            values[slot] = Math.max(values[slot] ?? 0, cell.symbolValue);
        }
    });
    return values;
}
