import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import net from 'node:net';
import { GosClient, GosStream, packFrame, packOpen } from '../assets/scripts/GosClient.ts';
import { CLIENT_LOGIN_MD5, decodePacket, encodeAuth, encodeEnterSuccess, encodeLobbySuccess, encodeRegister } from '../assets/scripts/GosPackets.ts';
import { betSteps, coinAt, localRooms, pickRoom, shotHits } from '../assets/scripts/Fish101.ts';
import { HallState, selectLobbyGames } from '../assets/scripts/HallState.ts';
import type { ServerSettings } from '../assets/scripts/ServerSettings.ts';
import { cellsToColumns, decodePlay, encodeEnterFishLevel, encodeEnterFishSit, encodeEnterSlots, encodeNormalSpin, encodeSampleNormal, encodeSampleSeat, encodeType } from '../assets/scripts/ServerPlay.ts';
import { Slot270Session } from '../assets/scripts/Slot270.ts';
import { XxBuf } from '../assets/scripts/XxBuf.ts';

const account = {
    id: 9236,
    username: 'guest-7',
    nickname: '游客七',
    accountName: '',
    money: 88000,
    moneyGift: 10,
    moneySafe: 1200,
    moneyGiftSafe: 300,
    amountOfGift: 5,
    amountOfWashcode: 450,
    vipLevel: 2,
};

function testCodec(): void {
    const zig = new XxBuf();
    zig.wvi32(0);
    zig.wvi32(-1);
    zig.wvi32(1);
    zig.wvi32(3);
    assert.deepEqual(Array.from(zig.toUint8Array()), [0, 1, 2, 6]);

    const text = new XxBuf();
    text.wstr('ab');
    text.wvu(1106);
    assert.deepEqual(Array.from(text.toUint8Array()), [2, 97, 98, 0xd2, 0x08]);
    const back = XxBuf.wrap(text.toUint8Array());
    assert.equal(back.rstr(), 'ab');
    assert.equal(back.rvu(), 1106);

    const number = new XxBuf();
    number.wd(128800);
    number.wnvi32(null);
    number.wnvi32(4);
    const readNumber = XxBuf.wrap(number.toUint8Array());
    assert.equal(readNumber.rd(), 128800);
    assert.equal(readNumber.rnvi32(), null);
    assert.equal(readNumber.rnvi32(), 4);

    const auth = encodeAuth({
        clientType: 'windows',
        phoneType: 3,
        version: '1.0.1',
        packageName: 'com.idh.fjd.fkjh',
        deviceId: 'device-1',
        username: '',
        accountName: 'abcd',
        password: '12345678',
    });
    assert.equal(auth[0], 0xd2);
    assert.equal(auth[1], 0x08);
    const authBuf = XxBuf.wrap(auth);
    assert.equal(authBuf.rvu(), 1106);
    assert.equal(authBuf.rstr(), 'windows');
    assert.equal(authBuf.rvi32(), 3);
    assert.equal(authBuf.rstr(), '');
    assert.equal(authBuf.rstr(), '1.0.1');
    assert.equal(authBuf.rstr(), 'com.idh.fjd.fkjh');
    assert.equal(authBuf.rstr(), 'device-1');
    assert.equal(authBuf.rstr(), '1024');
    assert.equal(authBuf.rstr(), '');
    assert.equal(authBuf.rstr(), '');
    assert.equal(authBuf.rstr(), '12345678');
    assert.equal(authBuf.rstr(), CLIENT_LOGIN_MD5);
    assert.equal(authBuf.rstr(), '');
    assert.equal(authBuf.rstr(), 'abcd');

    const register = encodeRegister({
        clientType: 'windows',
        phoneType: 3,
        version: '1.0.1',
        packageName: 'com.idh.fjd.fkjh',
        deviceId: 'device-1',
        username: '',
        accountName: 'abcd',
        password: '12345678',
    });
    assert.equal(register[0], 0xd9);
    assert.equal(register[1], 0x08);

    const lobby = decodePacket(encodeLobbySuccess({
        kind: 'lobby',
        lobbyToken: 'token-1',
        username: 'guest-7',
        accountId: 9236,
        gameId: 0,
        self: account,
    }));
    assert.equal(lobby.kind, 'lobby');
    if (lobby.kind === 'lobby') {
        assert.equal(lobby.lobbyToken, 'token-1');
        assert.equal(lobby.self?.nickname, '游客七');
        assert.equal(lobby.self?.money, 88000);
        assert.equal(lobby.self?.moneySafe, 1200);
        assert.equal(lobby.self?.vipLevel, 2);
        assert.equal(lobby.self?.amountOfWashcode, 450);
    }

    const entered = decodePacket(encodeEnterSuccess([270, 220], { ...account, money: 99000 }));
    assert.equal(entered.kind, 'enter');
    if (entered.kind === 'enter') {
        assert.deepEqual(entered.gameIds, [270, 220]);
        assert.equal(entered.self?.money, 99000);
    }

    const withCard = new XxBuf();
    withCard.wvu(1001);
    withCard.wstr('token-1');
    withCard.wstr('guest-7');
    withCard.wvi32(9236);
    withCard.wstr('');
    withCard.wstr('');
    withCard.wvi32(0);
    withCard.wvu(2);
    withCard.wvu(501);
    withCard.wvi32(account.id);
    withCard.wstr(account.username);
    withCard.wstr(account.nickname);
    withCard.wstr(account.accountName);
    withCard.wvi32(1);
    withCard.wstr('');
    withCard.wd(account.money);
    withCard.wd(account.moneyGift);
    withCard.wd(account.moneySafe);
    withCard.wd(account.moneyGiftSafe);
    withCard.wd(0);
    withCard.wd(0);
    withCard.wnvi32(null);
    for (let index = 0; index < 8; index += 1) {
        withCard.wvi32(0);
    }
    withCard.wd(0);
    withCard.wd(0);
    withCard.wd(0);
    withCard.wvi32(0);
    withCard.wvi32(1);
    withCard.wvu(1);
    withCard.wvu(3);
    withCard.wvu(502);
    withCard.wvi32(9);
    withCard.wvi32(1);
    withCard.wstr('name');
    withCard.wstr('card');
    withCard.wstr('bank');
    withCard.wd(account.amountOfGift);
    withCard.wd(account.amountOfWashcode);
    withCard.wvi32(0);
    withCard.wvi32(account.vipLevel);
    withCard.wvi32(0);
    withCard.wvi32(0);
    withCard.wstr('a@b.c');
    const cardPacket = decodePacket(withCard.toUint8Array());
    assert.equal(cardPacket.kind, 'lobby');
    if (cardPacket.kind === 'lobby') {
        assert.equal(cardPacket.self?.vipLevel, 2);
        assert.equal(cardPacket.self?.amountOfWashcode, 450);
    }

    const failure = new XxBuf();
    failure.wvu(103);
    failure.wvi64(-16666);
    failure.wstr('');
    const failed = decodePacket(failure.toUint8Array());
    assert.equal(failed.kind, 'error');
    if (failed.kind === 'error') {
        assert.equal(failed.number, -16666);
    }

    const frame = packFrame(0, -3, auth);
    const stream = new GosStream();
    stream.push(frame.slice(0, 5));
    assert.equal(stream.shift(), undefined);
    stream.push(frame.slice(5));
    const got = stream.shift();
    assert.equal(got?.serial, -3);
    assert.equal(got?.serviceId, 0);
    const open = packOpen(0);
    assert.deepEqual(Array.from(open), [0x0a, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0x04, 0x6f, 0x70, 0x65, 0x6e, 0x00]);
    stream.push(open);
    assert.equal(stream.opened.has(0), true);
    assert.equal(stream.shift(), undefined);
    const request = packFrame(0, -1, new Uint8Array([0xd2, 0x08]));
    assert.equal(request[8], 0x01);

    const spin = XxBuf.wrap(encodeNormalSpin(100, 0, 1));
    assert.equal(spin.rvu(), 30614);
    assert.equal(spin.rd(), 100);
    assert.equal(spin.rvi32(), 0);
    assert.equal(spin.rvi32(), 1);
    const normal = decodePlay(encodeSampleNormal());
    assert.equal(normal?.kind, 'normalSpin');
    if (normal?.kind === 'normalSpin') {
        assert.deepEqual(cellsToColumns(normal.spin.cells)[0], [4, 5, 6]);
        assert.equal(normal.spin.winCoin, 80);
        assert.equal(normal.spin.balances.money, 90000);
    }
    const seat = decodePlay(encodeSampleSeat());
    assert.equal(seat?.kind, 'slotSeat');
    if (seat?.kind === 'slotSeat') {
        assert.equal(seat.bets[0].money, 100);
        assert.equal(seat.bets[0].lvID, 1);
        assert.equal(seat.balances.money, 99000);
    }
    const safe = new XxBuf();
    safe.wvu(1224);
    safe.wd(10);
    safe.wd(20);
    safe.wd(3);
    safe.wd(4);
    const safePacket = decodePlay(safe.toUint8Array());
    assert.equal(safePacket?.kind, 'safe');
    if (safePacket?.kind === 'safe') {
        assert.equal(safePacket.money, 10);
        assert.equal(safePacket.moneyGiftSafe, 4);
    }
    const activity = new XxBuf();
    activity.wvu(1294);
    activity.wvu(1);
    activity.wvu(2);
    activity.wvu(1290);
    activity.wvi32(7);
    activity.wvi32(1);
    activity.wstr('cfg');
    activity.wvi32(0);
    const activityPacket = decodePlay(activity.toUint8Array());
    assert.equal(activityPacket?.kind, 'activity');
    if (activityPacket?.kind === 'activity') {
        assert.equal(activityPacket.items[0].id, 7);
        assert.equal(activityPacket.items[0].open, 1);
    }
    const levelBytes = XxBuf.wrap(encodeEnterFishLevel(3));
    assert.equal(levelBytes.rvu(), 2004);
    assert.equal(levelBytes.rvi32(), 3);
    const sitBytes = XxBuf.wrap(encodeEnterFishSit(9, -1));
    assert.equal(sitBytes.rvu(), 2005);
    assert.equal(sitBytes.rvi32(), 9);
    assert.equal(sitBytes.rvi32(), -1);
    const levels = new XxBuf();
    levels.wvu(1208);
    levels.wvu(1);
    levels.wvu(2);
    levels.wvu(1207);
    levels.wvi32(4);
    levels.wvi64(10);
    levels.wvi64(100);
    levels.wd(1000);
    levels.wvi32(1);
    const fishLevels = decodePlay(levels.toUint8Array());
    assert.equal(fishLevels?.kind, 'fishLevels');
    if (fishLevels?.kind === 'fishLevels') {
        assert.equal(fishLevels.levels[0].levelId, 4);
        assert.equal(fishLevels.levels[0].minBet, 10);
        assert.equal(fishLevels.levels[0].minMoney, 1000);
    }
    const rooms = new XxBuf();
    rooms.wvu(1213);
    rooms.wvu(1);
    rooms.wvu(2);
    rooms.wvu(1211);
    rooms.wvi32(9);
    rooms.wvu(2);
    rooms.wvu(0);
    rooms.wvu(3);
    rooms.wvu(1212);
    rooms.wvi32(7);
    rooms.wstr('甲');
    rooms.wvi32(1);
    rooms.wd(50);
    rooms.wvi32(0);
    const fishRooms = decodePlay(rooms.toUint8Array());
    assert.equal(fishRooms?.kind, 'fishRooms');
    if (fishRooms?.kind === 'fishRooms') {
        assert.equal(fishRooms.rooms[0].roomId, 9);
        assert.equal(fishRooms.rooms[0].players[0], null);
        assert.equal(fishRooms.rooms[0].players[1]?.nickname, '甲');
        assert.equal(pickRoom(fishRooms.rooms).roomId, 9);
    }
    const fishSeatBuf = new XxBuf();
    fishSeatBuf.wvu(1214);
    fishSeatBuf.wvi32(101);
    fishSeatBuf.wvi32(8);
    const fishSeat = decodePlay(fishSeatBuf.toUint8Array());
    assert.equal(fishSeat?.kind, 'fishSeat');
    if (fishSeat?.kind === 'fishSeat') {
        assert.equal(fishSeat.gameId, 101);
        assert.equal(fishSeat.serviceId, 8);
    }
    assert.equal(shotHits(0, 0, 10, 0, 80, 80), true);
    assert.equal(shotHits(0, 0, 400, 0, 80, 80), false);
    assert.deepEqual(betSteps(10, 100), [10, 20, 40, 80, 100]);
    assert.equal(coinAt({ coinMin: 250, coinMax: 550, coinStep: 10, coinList: [] }, 0), 250);
    assert.equal(coinAt({ coinMin: 250, coinMax: 550, coinStep: 10, coinList: [] }, 0.999), 550);
    assert.equal(coinAt({ coinMin: 100, coinMax: 10000, coinStep: 1, coinList: [100, 150, 10000] }, 0.9), 10000);
    assert.equal(localRooms(2).length, 3);
    assert.equal(localRooms(2)[0].players.length, 4);
    const free = new XxBuf();
    free.wvu(30618);
    free.wd(50);
    free.wd(12);
    free.wvu(1);
    free.wvi32(2);
    free.wvi32(2);
    free.wvi32(0);
    free.wd(0);
    free.wvi32(0);
    free.wvi32(0);
    free.wd(8);
    free.wvi32(6);
    free.wvi32(6);
    free.wvu(0);
    free.wvi32(0);
    free.wvi32(0);
    free.wvi32(0);
    free.wvi64(0);
    free.wvi64(0);
    free.wvi64(0);
    free.wvi64(88000);
    free.wvi64(1000);
    const freePacket = decodePlay(free.toUint8Array());
    assert.equal(freePacket?.kind, 'freeSpin');
    if (freePacket?.kind === 'freeSpin') {
        assert.equal(freePacket.spin.totalCount, 6);
        assert.equal(freePacket.spin.allCount, 6);
        assert.equal(freePacket.spin.bonusWinCoin, 8);
        assert.equal(cellsToColumns(freePacket.spin.cells)[1][0], 2);
        assert.equal(freePacket.spin.balances.money, 88000);
    }
}

function testHallState(): void {
    const state = new HallState();
    const result = state.applyServer({
        username: 'guest-7',
        accountId: 9236,
        nickname: '游客七',
        money: 99000,
        moneySafe: 1200,
        washCode: 450,
        giftSafe: 300,
        vipLevel: 2,
        gameIds: [270, 220],
    }, '');
    assert.equal(result.ok, true);
    assert.equal(state.nickname, '游客七');
    assert.equal(state.userId, '9236');
    assert.equal(state.money, 99000);
    assert.equal(state.vipLevel, 2);
    assert.equal(state.online, true);
    assert.deepEqual(state.serverGameIds, [270, 220]);
    state.logout();
    assert.equal(state.serverGameIds, null);
    assert.equal(state.online, false);
    const catalog = [
        { id: 270 },
        { id: 336 },
        { id: 341 },
    ];
    assert.deepEqual(selectLobbyGames(catalog, [336, 341]).map((game) => game.id), [270, 336, 341]);
    assert.deepEqual(selectLobbyGames(catalog, [2270, 336]).map((game) => game.id), [270, 336]);
    assert.deepEqual(selectLobbyGames(catalog, null).map((game) => game.id), [270, 336, 341]);
    assert.deepEqual(selectLobbyGames([{ id: 270 }, { id: 101 }, { id: 336 }], [336]).map((game) => game.id), [270, 101, 336]);
}

function startFakeServer(): Promise<{ port: number; close: () => void }> {
    const server = net.createServer((socket) => {
        socket.write(packOpen(0));
        const stream = new GosStream();
        socket.on('data', (chunk) => {
            stream.push(new Uint8Array(chunk));
            let frame = stream.shift();
            while (frame) {
                const packet = decodePacket(frame.body);
                const serial = -frame.serial;
                if (packet.kind === 'unknown' && packet.typeId === 1106) {
                    socket.write(packFrame(0, serial, encodeLobbySuccess({
                        kind: 'lobby',
                        lobbyToken: 'token-1',
                        username: 'guest-7',
                        accountId: 9236,
                        gameId: 0,
                        self: account,
                    })));
                } else if (packet.kind === 'unknown' && packet.typeId === 2002) {
                    socket.write(packFrame(0, serial, encodeEnterSuccess([270, 220], { ...account, money: 99000 })));
                } else if (packet.kind === 'unknown' && packet.typeId === 2003) {
                    socket.write(packFrame(0, serial, encodeEnterSlots(270, 7)));
                    socket.write(packOpen(7));
                } else if (packet.kind === 'unknown' && packet.typeId === 30111) {
                    socket.write(packFrame(frame.serviceId, serial, encodeSampleSeat()));
                } else if (packet.kind === 'unknown' && packet.typeId === 30614) {
                    socket.write(packFrame(frame.serviceId, serial, encodeSampleNormal()));
                } else if (packet.kind === 'unknown' && packet.typeId === 30113) {
                    socket.write(packFrame(frame.serviceId, serial, encodeType(30102)));
                }
                frame = stream.shift();
            }
        });
    });
    return new Promise((resolve, reject) => {
        server.once('error', reject);
        server.listen(0, '127.0.0.1', () => {
            const address = server.address();
            if (!address || typeof address === 'string') {
                reject(new Error('假的 goserver 没有端口'));
                return;
            }
            resolve({ port: address.port, close: () => server.close() });
        });
    });
}

async function startBridge(): Promise<{ port: number; stop: () => void }> {
    const child = spawn(process.execPath, ['creator-hall/tools/goserver-bridge.mjs', '0'], {
        cwd: '/workspace',
        stdio: ['ignore', 'pipe', 'pipe'],
    });
    let output = '';
    const port = await new Promise<number>((resolve, reject) => {
        const timer = setTimeout(() => reject(new Error(`桥接没有启动: ${output}`)), 5000);
        const onData = (chunk: Buffer) => {
            output += chunk.toString('utf8');
            const matched = /ws:\/\/127\.0\.0\.1:(\d+)/.exec(output);
            if (matched) {
                clearTimeout(timer);
                resolve(Number(matched[1]));
            }
        };
        child.stdout?.on('data', onData);
        child.stderr?.on('data', onData);
        child.once('exit', (code) => {
            clearTimeout(timer);
            reject(new Error(`桥接退出 ${code}: ${output}`));
        });
    });
    return {
        port,
        stop: () => {
            if (!child.killed) {
                child.kill();
            }
        },
    };
}

async function testBridge(): Promise<void> {
    const fake = await startFakeServer();
    const bridge = await startBridge();
    const client = new GosClient();
    const settings: ServerSettings = {
        host: '127.0.0.1',
        port: String(fake.port),
        packageName: 'com.idh.fjd.fkjh',
        version: '1.0.1',
        bridgeUrl: `ws://127.0.0.1:${bridge.port}`,
        deviceId: 'device-1',
        guestUsername: '',
    };
    try {
        const profile = await client.loginPassword(settings, 'abcd', '12345678');
        assert.equal(profile.nickname, '游客七');
        assert.equal(profile.accountId, 9236);
        assert.equal(profile.money, 99000);
        assert.equal(profile.moneySafe, 1200);
        assert.equal(profile.washCode, 450);
        assert.equal(profile.giftSafe, 300);
        assert.equal(profile.vipLevel, 2);
        assert.deepEqual(profile.gameIds, [270, 220]);
        let money = 0;
        const session = new Slot270Session(client, (balances) => {
            money = balances.money;
        });
        const opened = await session.enter(270);
        assert.equal(opened.bets[0].money, 100);
        assert.equal(money, 99000);
        const steps = await session.spin(100);
        assert.deepEqual(steps[0].columns[0], [4, 5, 6]);
        assert.equal(steps[0].win, 80);
        assert.equal(steps[0].jackpots[3], 400);
        assert.equal(money, 90000);
        await session.leave();
        console.log(JSON.stringify({
            nickname: profile.nickname,
            money: profile.money,
            gameIds: profile.gameIds,
            slotBet: opened.bets[0].money,
            slotWin: steps[0].win,
            column: steps[0].columns[0],
            balance: money,
            bridge: bridge.port,
            server: fake.port,
        }));
    } finally {
        client.close();
        bridge.stop();
        fake.close();
    }
}

testCodec();
testHallState();
await testBridge();
console.log('goserver codec and bridge ok');
