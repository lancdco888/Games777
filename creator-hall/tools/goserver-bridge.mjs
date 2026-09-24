/**
 * WebSocket to TCP bridge for the Creator hall preview.
 *
 * Creator's browser preview cannot open the goserver TCP port directly.
 * Run this on the same machine as goserver, then fill the login screen:
 *
 *   node creator-hall/tools/goserver-bridge.mjs 17901
 *
 * On Windows, double-click creator-hall/open-bridge.bat instead.
 * The page connects to ws://127.0.0.1:17901 and sends
 * {"host":"127.0.0.1","port":20000}. Later messages are raw TCP bytes.
 */
import crypto from 'node:crypto';
import net from 'node:net';

const listenPort = Number(process.argv[2] || process.env.GOS_BRIDGE_PORT || 17901);
const GUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';

const server = net.createServer((socket) => {
    socket.setNoDelay(true);
    let header = Buffer.alloc(0);
    let upgraded = false;
    let tcp = null;
    let ready = false;
    const pending = [];
    let cache = Buffer.alloc(0);

    socket.on('data', (chunk) => {
        if (!upgraded) {
            header = Buffer.concat([header, chunk]);
            const end = header.indexOf('\r\n\r\n');
            if (end < 0) {
                return;
            }
            const text = header.subarray(0, end).toString('utf8');
            const rest = header.subarray(end + 4);
            header = Buffer.alloc(0);
            if (!acceptUpgrade(socket, text)) {
                socket.destroy();
                return;
            }
            upgraded = true;
            if (rest.length) {
                onFrameBytes(rest);
            }
            return;
        }
        onFrameBytes(chunk);
    });

    socket.on('close', () => tcp?.destroy());
    socket.on('error', () => tcp?.destroy());

    function onFrameBytes(chunk) {
        cache = Buffer.concat([cache, chunk]);
        while (cache.length >= 2) {
            const length = frameLength(cache);
            if (length === -2) {
                socket.destroy();
                tcp?.destroy();
                return;
            }
            if (length < 0) {
                return;
            }
            if (cache.length < length) {
                return;
            }
            const packet = cache.subarray(0, length);
            cache = cache.subarray(length);
            const message = decodeFrame(packet);
            if (!message) {
                continue;
            }
            if (message.opcode === 0x8) {
                socket.end(encodeFrame(0x8, Buffer.alloc(0)));
                tcp?.destroy();
                return;
            }
            if (message.opcode === 0x9) {
                socket.write(encodeFrame(0xa, message.payload));
                continue;
            }
            if (message.opcode === 0x1) {
                openTcp(message.payload.toString('utf8'));
                continue;
            }
            if (message.opcode === 0x2 && tcp && ready) {
                tcp.write(message.payload);
            }
        }
    }

    function openTcp(text) {
        let request;
        try {
            request = JSON.parse(text);
        } catch {
            sendText({ ok: false, error: '桥接请求不是 JSON' });
            return;
        }
        const host = String(request.host || '').trim();
        const port = Number(request.port);
        if (!host || !Number.isInteger(port) || port <= 0 || port > 65535) {
            sendText({ ok: false, error: '桥接地址或端口不正确' });
            return;
        }
        tcp = net.connect({ host, port }, () => {
            ready = true;
            sendText({ ok: true });
            while (pending.length) {
                sendBinary(pending.shift());
            }
        });
        tcp.setNoDelay(true);
        tcp.on('data', (data) => {
            if (!ready) {
                pending.push(data);
                return;
            }
            sendBinary(data);
        });
        tcp.on('error', (error) => {
            if (!ready) {
                sendText({ ok: false, error: `连不上 ${host}:${port}（${error.message}）` });
            }
            socket.end(encodeFrame(0x8, Buffer.alloc(0)));
        });
        tcp.on('close', () => {
            socket.end(encodeFrame(0x8, Buffer.alloc(0)));
        });
    }

    function sendText(value) {
        if (!socket.destroyed) {
            socket.write(encodeFrame(0x1, Buffer.from(JSON.stringify(value))));
        }
    }

    function sendBinary(value) {
        if (!socket.destroyed) {
            socket.write(encodeFrame(0x2, value));
        }
    }
});

server.listen(listenPort, '127.0.0.1', () => {
    const address = server.address();
    const port = address && typeof address === 'object' ? address.port : listenPort;
    console.log(`goserver bridge listening on ws://127.0.0.1:${port}`);
});

function acceptUpgrade(socket, text) {
    const key = /Sec-WebSocket-Key:\s*(.+)/i.exec(text)?.[1]?.trim();
    if (!key || !/Upgrade:\s*websocket/i.test(text)) {
        socket.write('HTTP/1.1 400 Bad Request\r\nConnection: close\r\n\r\n');
        return false;
    }
    const accept = crypto.createHash('sha1').update(key + GUID).digest('base64');
    socket.write(
        'HTTP/1.1 101 Switching Protocols\r\n' +
            'Upgrade: websocket\r\n' +
            'Connection: Upgrade\r\n' +
            `Sec-WebSocket-Accept: ${accept}\r\n\r\n`,
    );
    return true;
}

function frameLength(buffer) {
    const bits = buffer[1] & 0x7f;
    let start = 2;
    let length = bits;
    if (bits === 126) {
        if (buffer.length < 4) {
            return -1;
        }
        length = buffer.readUInt16BE(2);
        start = 4;
    } else if (bits === 127) {
        if (buffer.length < 10) {
            return -1;
        }
        const big = buffer.readBigUInt64BE(2);
        if (big > 2_000_000n) {
            return -2;
        }
        length = Number(big);
        start = 10;
    }
    if (length > 2_000_000) {
        return -2;
    }
    const masked = (buffer[1] & 0x80) !== 0;
    return start + (masked ? 4 : 0) + length;
}

function decodeFrame(buffer) {
    const opcode = buffer[0] & 0x0f;
    const bits = buffer[1] & 0x7f;
    let start = 2;
    let length = bits;
    if (bits === 126) {
        length = buffer.readUInt16BE(2);
        start = 4;
    } else if (bits === 127) {
        length = Number(buffer.readBigUInt64BE(2));
        start = 10;
    }
    const masked = (buffer[1] & 0x80) !== 0;
    let payload = buffer.subarray(start + (masked ? 4 : 0), start + (masked ? 4 : 0) + length);
    if (masked) {
        const mask = buffer.subarray(start, start + 4);
        payload = Buffer.from(payload);
        for (let index = 0; index < payload.length; index += 1) {
            payload[index] ^= mask[index & 3];
        }
    }
    return { opcode, payload };
}

function encodeFrame(opcode, payload) {
    const length = payload.length;
    let header;
    if (length < 126) {
        header = Buffer.alloc(2);
        header[1] = length;
    } else if (length < 65536) {
        header = Buffer.alloc(4);
        header[1] = 126;
        header.writeUInt16BE(length, 2);
    } else {
        header = Buffer.alloc(10);
        header[1] = 127;
        header.writeBigUInt64BE(BigInt(length), 2);
    }
    header[0] = 0x80 | opcode;
    return Buffer.concat([header, payload]);
}
