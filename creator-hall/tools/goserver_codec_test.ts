import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import net from 'node:net';
import { GosClient, GosStream, OPEN_SERIAL, packFrame } from '../assets/scripts/GosClient.ts';
import { CLIENT_LOGIN_MD5, decodePacket, encodeAuth, encodeEnterSuccess, encodeLobbySuccess, encodeRegister } from '../assets/scripts/GosPackets.ts';
import { HallState } from '../assets/scripts/HallState.ts';
import type { ServerSettings } from '../assets/scripts/ServerSettings.ts';
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
    stream.push(packFrame(0, OPEN_SERIAL, new Uint8Array()));
    assert.equal(stream.opened.has(0), true);
    assert.equal(stream.shift(), undefined);
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
    assert.deepEqual(state.serverGameIds, [270, 220]);
    state.logout();
    assert.equal(state.serverGameIds, null);
}

function startFakeServer(): Promise<{ port: number; close: () => void }> {
    const server = net.createServer((socket) => {
        socket.write(packFrame(0, OPEN_SERIAL, new Uint8Array()));
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
        console.log(JSON.stringify({
            nickname: profile.nickname,
            money: profile.money,
            gameIds: profile.gameIds,
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
