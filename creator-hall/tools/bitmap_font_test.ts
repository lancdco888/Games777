import { readFileSync } from 'node:fs';
import { bitmapFont, FONTS, layoutBitmap } from '../assets/scripts/BitmapFont.ts';
import type { BitmapFont, Glyph } from '../assets/scripts/BitmapFont.ts';

interface Parsed {
    lineHeight: number;
    glyphs: Record<string, Glyph>;
}

function parseFnt(path: string): Parsed {
    const glyphs: Record<string, Glyph> = {};
    let lineHeight = 0;
    const text = readFileSync(path, 'utf8');
    for (const line of text.split('\n')) {
        if (line.startsWith('common ')) {
            lineHeight = number(line, 'lineHeight');
        }
        if (!line.startsWith('char id=')) {
            continue;
        }
        const id = number(line, 'id');
        glyphs[String.fromCharCode(id)] = {
            x: number(line, 'x'),
            y: number(line, 'y'),
            w: number(line, 'width'),
            h: number(line, 'height'),
            xoff: number(line, 'xoffset'),
            yoff: number(line, 'yoffset'),
            adv: number(line, 'xadvance'),
        };
    }
    return { lineHeight, glyphs };
}

function number(line: string, key: string): number {
    const match = line.match(new RegExp(`${key}=(-?\\d+)`));
    if (!match) {
        throw new Error(`missing ${key} in ${line}`);
    }
    return Number(match[1]);
}

function sameGlyph(actual: Glyph, expected: Glyph): boolean {
    return actual.x === expected.x
        && actual.y === expected.y
        && actual.w === expected.w
        && actual.h === expected.h
        && actual.xoff === expected.xoff
        && actual.yoff === expected.yoff
        && actual.adv === expected.adv;
}

function assertFont(file: string, font: BitmapFont): void {
    const parsed = parseFnt(file);
    if (parsed.lineHeight !== font.lineHeight) {
        throw new Error(`${font.id} lineHeight ${font.lineHeight} != ${parsed.lineHeight}`);
    }
    const keys = Object.keys(parsed.glyphs).sort();
    if (keys.join('') !== Object.keys(font.glyphs).sort().join('')) {
        throw new Error(`${font.id} charset ${Object.keys(font.glyphs).sort().join('')} != ${keys.join('')}`);
    }
    for (const key of keys) {
        if (!sameGlyph(font.glyphs[key], parsed.glyphs[key])) {
            throw new Error(`${font.id} glyph ${key} ${JSON.stringify(font.glyphs[key])} != ${JSON.stringify(parsed.glyphs[key])}`);
        }
    }
}

assertFont('hall/res/studio/common/coin_fnt.fnt', FONTS.coin);
assertFont('hall/res/studio/common/coin_lobby_fnt.fnt', FONTS.coin);
assertFont('hall/res/studio/common/safebox_fnt.fnt', FONTS.safebox);
assertFont('hall/res/studio/vip/num/vip2.fnt', FONTS.vip2);
assertFont('hall/res/studio/common/percent_num.fnt', FONTS.percent);
assertFont('hall/res/studio/caijin/new/num/common_font_jp_new.fnt', FONTS.hallJackpot);

const files = [
    'common/coin_lobby_fnt.fnt',
    'common/coin_fnt.fnt',
    'common/safebox_fnt.fnt',
    'vip/num/vip2.fnt',
    'common/percent_num.fnt',
    'caijin/new/num/common_font_jp_new.fnt',
    'slot',
    'slotJackpot',
];
for (const file of files) {
    if (!bitmapFont(file)) {
        throw new Error(`missing font ${file}`);
    }
}
if (bitmapFont('not-a-font')) {
    throw new Error('unknown font should be missing');
}

const sample = layoutBitmap(FONTS.coin, '1000,000', 134, 26, 0.5, 0.5);
if (sample.length !== 8) {
    throw new Error(`coin sample length ${sample.length}`);
}
if (Math.abs(sample[0].x - -58) > 0.01 || Math.abs(sample[0].y) > 0.01) {
    throw new Error(`coin sample origin ${sample[0].x},${sample[0].y}`);
}
if (sample[4].ch !== ',') {
    throw new Error(`coin comma slot ${sample[4].ch}`);
}

const vip = layoutBitmap(FONTS.vip2, '5', 13, 19, 0.5, 0.5);
if (vip.length !== 1 || vip[0].ch !== '5' || vip[0].sw !== 13) {
    throw new Error(`vip glyph ${JSON.stringify(vip[0])}`);
}

const jackpot = layoutBitmap(FONTS.slotJackpot, '1,250', 180, 40, 0.5, 0.5);
if (jackpot.map((glyph) => glyph.ch).join('') !== '1,250') {
    throw new Error(`jackpot chars ${jackpot.map((glyph) => glyph.ch).join('')}`);
}
if (jackpot[1].sx !== 710) {
    throw new Error(`jackpot comma x ${jackpot[1].sx}`);
}

const money = layoutBitmap(FONTS.slot, '99,000', 168, 36, 0.5, 0.5);
if (money.map((glyph) => glyph.ch).join('') !== '99,000') {
    throw new Error(`slot chars ${money.map((glyph) => glyph.ch).join('')}`);
}
if (money[0].h > 36.01) {
    throw new Error(`slot glyph taller than the box ${money[0].h}`);
}

console.log(JSON.stringify({
    coin: '1000,000',
    vip: '5',
    slot: '99,000',
    jackpot: '1,250',
    glyphs: sample.length + vip.length + money.length + jackpot.length,
}));
console.log('bitmap fonts match the fnt pages');
