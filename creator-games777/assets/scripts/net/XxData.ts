/**
 * XxData — port of native NewXxData variable-length binary buffer.
 * Matches Lua d:Wvu16/Rvu16, Wvi32/Rvi32, Wstr/Rstr, Wd/Rd, Wu8/Ru8, Wvu32/Rvu32.
 */
export class XxData {
  private buf: number[] = [];
  private offset = 0;

  Clear(): void {
    this.buf = [];
    this.offset = 0;
  }

  GetLeft(): number {
    return this.buf.length - this.offset;
  }

  Size(): number {
    return this.buf.length;
  }

  ToUint8Array(): Uint8Array {
    return Uint8Array.from(this.buf);
  }

  FromUint8Array(data: Uint8Array): void {
    this.buf = Array.from(data);
    this.offset = 0;
  }

  Wu8(v: number): void {
    this.buf.push(v & 0xff);
  }

  Ru8(): [number, number] {
    if (this.offset >= this.buf.length) return [1, 0];
    return [0, this.buf[this.offset++]];
  }

  /** unsigned varint 16-bit range (actually varint like protobuf) */
  Wvu16(v: number): void {
    this.writeVarint(v >>> 0);
  }

  Rvu16(): [number, number] {
    return this.readVarint();
  }

  Wvu32(v: number): void {
    this.writeVarint(v >>> 0);
  }

  Rvu32(): [number, number] {
    return this.readVarint();
  }

  /** signed zig-zag int32 */
  Wvi32(v: number): void {
    const zz = (v << 1) ^ (v >> 31);
    this.writeVarint(zz >>> 0);
  }

  Rvi32(): [number, number] {
    const [r, n] = this.readVarint();
    if (r !== 0) return [r, 0];
    const v = ((n >>> 1) ^ -(n & 1)) | 0;
    return [0, v];
  }

  Wstr(s: string): void {
    const bytes = this.utf8Encode(s || '');
    this.Wvu32(bytes.length);
    for (const b of bytes) this.Wu8(b);
  }

  Rstr(): [number, string] {
    const [r, len] = this.Rvu32();
    if (r !== 0) return [r, ''];
    if (len > this.GetLeft()) return [-1, ''];
    const slice = this.buf.slice(this.offset, this.offset + len);
    this.offset += len;
    return [0, this.utf8Decode(slice)];
  }

  Wd(v: number): void {
    const ab = new ArrayBuffer(8);
    new DataView(ab).setFloat64(0, v, true);
    const u8 = new Uint8Array(ab);
    for (let i = 0; i < 8; i++) this.Wu8(u8[i]);
  }

  Rd(): [number, number] {
    if (this.GetLeft() < 8) return [1, 0];
    const ab = new ArrayBuffer(8);
    const u8 = new Uint8Array(ab);
    for (let i = 0; i < 8; i++) u8[i] = this.buf[this.offset++];
    return [0, new DataView(ab).getFloat64(0, true)];
  }

  private writeVarint(v: number): void {
    let n = v >>> 0;
    while (n >= 0x80) {
      this.Wu8((n & 0x7f) | 0x80);
      n >>>= 7;
    }
    this.Wu8(n);
  }

  private readVarint(): [number, number] {
    let result = 0;
    let shift = 0;
    for (;;) {
      if (this.offset >= this.buf.length) return [1, 0];
      const b = this.buf[this.offset++];
      result |= (b & 0x7f) << shift;
      if ((b & 0x80) === 0) return [0, result >>> 0];
      shift += 7;
      if (shift > 35) return [2, 0];
    }
  }

  private utf8Encode(s: string): number[] {
    const out: number[] = [];
    for (let i = 0; i < s.length; i++) {
      let c = s.charCodeAt(i);
      if (c < 0x80) out.push(c);
      else if (c < 0x800) {
        out.push(0xc0 | (c >> 6), 0x80 | (c & 0x3f));
      } else if (c >= 0xd800 && c <= 0xdbff) {
        const c2 = s.charCodeAt(++i);
        const cp = 0x10000 + ((c & 0x3ff) << 10) + (c2 & 0x3ff);
        out.push(
          0xf0 | (cp >> 18),
          0x80 | ((cp >> 12) & 0x3f),
          0x80 | ((cp >> 6) & 0x3f),
          0x80 | (cp & 0x3f),
        );
      } else {
        out.push(0xe0 | (c >> 12), 0x80 | ((c >> 6) & 0x3f), 0x80 | (c & 0x3f));
      }
    }
    return out;
  }

  private utf8Decode(bytes: number[]): string {
    let out = '';
    let i = 0;
    while (i < bytes.length) {
      const b = bytes[i++];
      if (b < 0x80) out += String.fromCharCode(b);
      else if (b < 0xe0) {
        const b2 = bytes[i++];
        out += String.fromCharCode(((b & 0x1f) << 6) | (b2 & 0x3f));
      } else if (b < 0xf0) {
        const b2 = bytes[i++];
        const b3 = bytes[i++];
        out += String.fromCharCode(((b & 0x0f) << 12) | ((b2 & 0x3f) << 6) | (b3 & 0x3f));
      } else {
        const b2 = bytes[i++];
        const b3 = bytes[i++];
        const b4 = bytes[i++];
        let cp = ((b & 0x07) << 18) | ((b2 & 0x3f) << 12) | ((b3 & 0x3f) << 6) | (b4 & 0x3f);
        cp -= 0x10000;
        out += String.fromCharCode(0xd800 + (cp >> 10), 0xdc00 + (cp & 0x3ff));
      }
    }
    return out;
  }
}
