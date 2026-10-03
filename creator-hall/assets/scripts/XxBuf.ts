/** xx Data codec used by the generated Lua packages (Wvu/Wvi/Wstr/Wd/Wnvi). */

const textEncoder = new TextEncoder();
const textDecoder = new TextDecoder();

export class XxBuf {
    private bytes: number[] = [];
    private offset = 0;

    static wrap(data: Uint8Array): XxBuf {
        const buf = new XxBuf();
        buf.bytes = Array.from(data);
        return buf;
    }

    toUint8Array(): Uint8Array {
        return Uint8Array.from(this.bytes);
    }

    rest(): Uint8Array {
        return Uint8Array.from(this.bytes.slice(this.offset));
    }

    get left(): number {
        return this.bytes.length - this.offset;
    }

    wu8(value: number): void {
        this.bytes.push(value & 0xff);
    }

    wvu(value: number): void {
        let rest = value >>> 0;
        while (rest >= 0x80) {
            this.bytes.push((rest & 0x7f) | 0x80);
            rest = Math.floor(rest / 128);
        }
        this.bytes.push(rest);
    }

    wvi32(value: number): void {
        const signed = value | 0;
        this.wvu(((signed << 1) ^ (signed >> 31)) >>> 0);
    }

    wvi64(value: number): void {
        if (!Number.isSafeInteger(value)) {
            throw new Error('整数超出安全范围');
        }
        const big = BigInt(value);
        const encoded = (big << 1n) ^ (big >> 63n);
        this.writeBigVarint(encoded);
    }

    wstr(value: string): void {
        const raw = textEncoder.encode(value ?? '');
        this.wvu(raw.length);
        for (const byte of raw) {
            this.bytes.push(byte);
        }
    }

    wd(value: number): void {
        const view = new DataView(new ArrayBuffer(8));
        view.setFloat64(0, value, true);
        for (let index = 0; index < 8; index += 1) {
            this.bytes.push(view.getUint8(index));
        }
    }

    wnvi32(value: number | null): void {
        if (value === null || value === undefined) {
            this.wu8(0);
            return;
        }
        this.wu8(1);
        this.wvi32(value);
    }

    wb(value: boolean): void {
        this.wu8(value ? 1 : 0);
    }

    ru8(): number {
        this.need(1);
        const value = this.bytes[this.offset];
        this.offset += 1;
        return value;
    }

    rvu(): number {
        let value = 0;
        let shift = 0;
        for (let count = 0; count < 5; count += 1) {
            const byte = this.ru8();
            value += (byte & 0x7f) * (2 ** shift);
            if ((byte & 0x80) === 0) {
                return value;
            }
            shift += 7;
        }
        throw new Error('varint 过长');
    }

    rvi16(): number {
        const decoded = unzigzag(BigInt(this.rvu()));
        return Number(BigInt.asIntN(16, decoded));
    }

    rvi32(): number {
        const decoded = unzigzag(BigInt(this.rvu()));
        return Number(BigInt.asIntN(32, decoded));
    }

    rvi64(): number {
        const decoded = unzigzag(this.readBigVarint());
        const value = Number(decoded);
        if (!Number.isSafeInteger(value)) {
            throw new Error('整数超出安全范围');
        }
        return value;
    }

    rstr(): string {
        const length = this.rvu();
        if (length > this.left) {
            throw new Error('字符串长度超出剩余数据');
        }
        const raw = Uint8Array.from(this.bytes.slice(this.offset, this.offset + length));
        this.offset += length;
        return textDecoder.decode(raw);
    }

    rd(): number {
        this.need(8);
        const view = new DataView(Uint8Array.from(this.bytes.slice(this.offset, this.offset + 8)).buffer);
        this.offset += 8;
        return view.getFloat64(0, true);
    }

    rnvi32(): number | null {
        const flag = this.ru8();
        if (flag === 0) {
            return null;
        }
        return this.rvi32();
    }

    rb(): boolean {
        return this.ru8() !== 0;
    }

    private need(count: number): void {
        if (this.left < count) {
            throw new Error('数据包被截断');
        }
    }

    private writeBigVarint(value: bigint): void {
        let rest = value;
        while (rest >= 0x80n) {
            this.bytes.push(Number(rest & 0x7fn) | 0x80);
            rest >>= 7n;
        }
        this.bytes.push(Number(rest));
    }

    private readBigVarint(): bigint {
        let value = 0n;
        let shift = 0n;
        for (let count = 0; count < 10; count += 1) {
            const byte = this.ru8();
            value |= BigInt(byte & 0x7f) << shift;
            if ((byte & 0x80) === 0) {
                return value;
            }
            shift += 7n;
        }
        throw new Error('varint 过长');
    }
}

function unzigzag(value: bigint): bigint {
    return (value >> 1n) ^ -(value & 1n);
}
