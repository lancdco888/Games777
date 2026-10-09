const assert = require('assert');
function writeVarint(buf, v) {
  let n = v >>> 0;
  while (n >= 0x80) {
    buf.push((n & 0x7f) | 0x80);
    n >>>= 7;
  }
  buf.push(n);
}
function readVarint(buf, offset) {
  let result = 0, shift = 0, i = offset;
  for (;;) {
    const b = buf[i++];
    result |= (b & 0x7f) << shift;
    if ((b & 0x80) === 0) return [result >>> 0, i];
    shift += 7;
  }
}
const buf = [];
writeVarint(buf, 1106);
const [v, next] = readVarint(buf, 0);
assert.strictEqual(v, 1106);
assert.strictEqual(next, buf.length);
console.log('protocol-smoke: ok');
