import type { GosClient } from './GosClient';
import {
    encodeEnterFishLevel,
    encodeEnterFishSit,
    encodeEnterGame,
    encodeReturnUp,
    explain,
} from './ServerPlay';
import type { FishLevelInfo, FishRoomInfo, WirePacket } from './ServerPlay';

export const FISH_GAME_ID = 101;

/** Local rooms used by 本地体验. Cannon values follow the hall fish level buttons. */
export const LOCAL_FISH_LEVELS: Array<FishLevelInfo & { name: string }> = [
    { name: '体验场', levelId: 1, minBet: 10, maxBet: 100, minMoney: 0, exchangeCoinRatio: 1 },
    { name: '初级场', levelId: 2, minBet: 100, maxBet: 1000, minMoney: 1000, exchangeCoinRatio: 1 },
    { name: '中级场', levelId: 3, minBet: 1000, maxBet: 10000, minMoney: 10000, exchangeCoinRatio: 1 },
    { name: '高级场', levelId: 4, minBet: 10000, maxBet: 100000, minMoney: 100000, exchangeCoinRatio: 1 },
];

/** Coin multiples from fish2 fish_info_hw.lua. Boss is KingSquid's minimum. */
export const FISH_KINDS = [
    { art: 'fish101/fish_2', coin: 2, width: 90, height: 90 },
    { art: 'fish101/fish_3', coin: 3, width: 86, height: 82 },
    { art: 'fish101/fish_4', coin: 4, width: 120, height: 76 },
    { art: 'fish101/fish_5', coin: 5, width: 110, height: 100 },
    { art: 'fish101/boss', coin: 250, width: 280, height: 186 },
];

export interface FishTableSeat {
    gameId: number;
    serviceId: number;
    roomId: number;
    level: FishLevelInfo;
}

/**
 * Lobby path into 大王乌贼: EnterGame, level, then sit.
 * The native Fish2Env fire frames are not in the lua packages, so shots stay on the local coin table.
 */
export class Fish101Session {
    serviceId = 0;
    private enteredMenu = false;
    private readonly client: GosClient;

    constructor(client: GosClient) {
        this.client = client;
    }

    async levels(): Promise<FishLevelInfo[]> {
        const packet = await this.client.request(0, encodeEnterGame(FISH_GAME_ID));
        const refused = explain(packet);
        if (refused) {
            throw new Error(refused);
        }
        if (packet.kind !== 'fishLevels') {
            throw new Error(unexpected(packet));
        }
        this.enteredMenu = true;
        return packet.levels;
    }

    async sit(level: FishLevelInfo): Promise<FishTableSeat> {
        const roomsPacket = await this.client.request(0, encodeEnterFishLevel(level.levelId));
        const roomError = explain(roomsPacket);
        if (roomError) {
            throw new Error(roomError);
        }
        if (roomsPacket.kind !== 'fishRooms') {
            throw new Error(unexpected(roomsPacket));
        }
        const room = pickRoom(roomsPacket.rooms);
        const seatPacket = await this.client.request(0, encodeEnterFishSit(room.roomId, -1));
        const seatError = explain(seatPacket);
        if (seatError) {
            throw new Error(seatError);
        }
        if (seatPacket.kind !== 'fishSeat') {
            throw new Error(unexpected(seatPacket));
        }
        this.serviceId = seatPacket.serviceId;
        await this.client.waitUntilOpen(seatPacket.serviceId);
        return {
            gameId: seatPacket.gameId,
            serviceId: seatPacket.serviceId,
            roomId: room.roomId,
            level,
        };
    }

    async leave(): Promise<void> {
        if (!this.enteredMenu) {
            return;
        }
        this.enteredMenu = false;
        for (let step = 0; step < 3; step += 1) {
            try {
                const packet = await this.client.request(0, encodeReturnUp());
                if (packet.kind === 'enter' || packet.kind === 'error') {
                    return;
                }
            } catch {
                return;
            }
        }
    }
}

export function pickRoom(rooms: FishRoomInfo[]): FishRoomInfo {
    const open = rooms.find((room) => room.players.some((player) => player === null));
    const room = open ?? rooms[0];
    if (!room) {
        throw new Error('这个等级没有房间');
    }
    return room;
}

/** Circle overlap used by the local shot. */
export function shotHits(
    bulletX: number,
    bulletY: number,
    fishX: number,
    fishY: number,
    fishWidth: number,
    fishHeight: number,
): boolean {
    const dx = bulletX - fishX;
    const dy = bulletY - fishY;
    const limit = 18 + Math.min(fishWidth, fishHeight) * 0.35;
    return dx * dx + dy * dy <= limit * limit;
}

function unexpected(packet: WirePacket): string {
    return packet.kind === 'unknown' ? `捕鱼返回了未识别的包 ${packet.typeId}` : '捕鱼返回了意料之外的结果';
}
