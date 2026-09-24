/** AngelCode glyph. Texture y grows downward from the top of the page. */
export interface Glyph {
    x: number;
    y: number;
    w: number;
    h: number;
    xoff: number;
    yoff: number;
    adv: number;
}

export interface BitmapFont {
    id: string;
    page: string;
    lineHeight: number;
    glyphs: Record<string, Glyph>;
}

export interface PlacedGlyph {
    ch: string;
    x: number;
    y: number;
    w: number;
    h: number;
    sx: number;
    sy: number;
    sw: number;
    sh: number;
}

function g(x: number, y: number, w: number, h: number, adv: number, xoff = 0, yoff = 0): Glyph {
    return { x, y, w, h, xoff, yoff, adv };
}

/** One horizontal strip. Advance is the distance to the next glyph, which keeps the original gap. */
function strip(chars: string, cells: Array<[number, number]>, height: number): Record<string, Glyph> {
    const glyphs: Record<string, Glyph> = {};
    cells.forEach(([x, w], index) => {
        const next = cells[index + 1];
        glyphs[chars[index]] = g(x, 0, w, height, next ? next[0] - x : w);
    });
    return glyphs;
}

/** Hall digits whose .fnt xadvance is narrower than the cell pitch. */
function digits(origin: number, pitch: number, width: number, height: number, advance: number): Record<string, Glyph> {
    const glyphs: Record<string, Glyph> = {};
    for (let index = 0; index < 10; index += 1) {
        glyphs[String(index)] = g(origin + index * pitch, 0, width, height, advance);
    }
    return glyphs;
}

/**
 * Hall pages follow the original .fnt xadvance, not the transparent cell pitch.
 * Game 270 has no .fnt. fnt_8 was split on alpha columns into 0-9, comma, period.
 * caijinNum321's last cell is a comma (the bottom shifts left) then a period.
 */
const coin: Record<string, Glyph> = {
    ...digits(0, 20, 18, 26, 18),
    '.': g(200, 0, 8, 26, 8),
    ',': g(210, 0, 8, 26, 8),
};

const safebox: Record<string, Glyph> = {
    ...digits(0, 24, 22, 31, 22),
    $: g(240, 0, 23, 39, 23),
    '%': g(265, 0, 23, 39, 23),
    ',': g(290, 0, 9, 39, 9),
    '.': g(301, 0, 9, 39, 9),
    b: g(312, 0, 27, 39, 27),
    k: g(341, 0, 27, 39, 27),
    m: g(370, 0, 27, 39, 27),
    t: g(399, 0, 27, 39, 27),
};

const vip2 = digits(0, 15, 13, 19, 13);

const percent: Record<string, Glyph> = {
    ...digits(0, 12, 10, 16, 10),
    '%': g(120, 0, 16, 16, 16),
};

const hallJackpot: Record<string, Glyph> = {
    ',': g(5, 0, 24, 46, 19, 0, -4),
    '.': g(30, 0, 29, 46, 26, 0, -4),
    0: g(60, 0, 29, 46, 26, 0, -4),
    1: g(90, 0, 29, 46, 26, 0, -4),
    2: g(120, 0, 29, 46, 26, 0, -4),
    3: g(150, 0, 29, 46, 26, 0, -4),
    4: g(180, 0, 29, 46, 26, 0, -4),
    5: g(210, 0, 29, 46, 26, 0, -4),
    6: g(0, 47, 29, 46, 26, 0, -4),
    7: g(30, 47, 29, 46, 26, 0, -4),
    8: g(60, 47, 29, 46, 26, 0, -4),
    9: g(90, 47, 29, 46, 26, 0, -4),
};

/** fnt_8.png, 346×47. Closest strip to the 36px money boxes. */
const slot = strip('0123456789,.', [
    [2, 27], [36, 22], [65, 29], [97, 29], [128, 30],
    [161, 29], [193, 28], [225, 29], [257, 28], [289, 28],
    [320, 12], [334, 12],
], 47);

/** caijinNum321.png, 789×160. Last cell splits into comma then period. */
const slotJackpot = strip('0123456789,.', [
    [4, 64], [82, 50], [146, 64], [217, 64], [284, 71],
    [359, 64], [430, 64], [500, 66], [572, 64], [643, 64],
    [710, 41], [752, 37],
], 160);

export const FONTS: Record<string, BitmapFont> = {
    coin: { id: 'coin', page: 'hall/font/coin_fnt', lineHeight: 26, glyphs: coin },
    safebox: { id: 'safebox', page: 'hall/font/safebox_fnt', lineHeight: 39, glyphs: safebox },
    vip2: { id: 'vip2', page: 'hall/font/vip2', lineHeight: 19, glyphs: vip2 },
    percent: { id: 'percent', page: 'hall/font/percent_num', lineHeight: 16, glyphs: percent },
    hallJackpot: { id: 'hallJackpot', page: 'hall/font/common_font_jp_new', lineHeight: 32, glyphs: hallJackpot },
    slot: { id: 'slot', page: 'game270/art/fnt_8', lineHeight: 47, glyphs: slot },
    slotJackpot: { id: 'slotJackpot', page: 'game270/art/caijinNum321', lineHeight: 160, glyphs: slotJackpot },
};

const FILE_TO_FONT: Record<string, string> = {
    'common/coin_lobby_fnt.fnt': 'coin',
    'common/coin_fnt.fnt': 'coin',
    'common/safebox_fnt.fnt': 'safebox',
    'vip/num/vip2.fnt': 'vip2',
    'common/percent_num.fnt': 'percent',
    'caijin/new/num/common_font_jp_new.fnt': 'hallJackpot',
    slot: 'slot',
    slotJackpot: 'slotJackpot',
};

export function bitmapFont(fileOrId: string): BitmapFont | undefined {
    const id = FILE_TO_FONT[fileOrId] || fileOrId;
    return FONTS[id];
}

/** Lay glyphs out inside a node box. Local origin is the node anchor. Shrink to fit. */
export function layoutBitmap(
    font: BitmapFont,
    text: string,
    boxW: number,
    boxH: number,
    ax: number,
    ay: number,
): PlacedGlyph[] {
    const chars = [...text].filter((ch) => font.glyphs[ch]);
    if (chars.length === 0 || boxW <= 0 || boxH <= 0) {
        return [];
    }
    let textW = 0;
    for (const ch of chars) {
        textW += font.glyphs[ch].adv;
    }
    const scale = Math.min(boxW / Math.max(textW, 1), boxH / font.lineHeight);
    const contentW = textW * scale;
    const contentH = font.lineHeight * scale;
    const boxLeft = -ax * boxW;
    const boxBottom = -ay * boxH;
    const centerX = boxLeft + boxW / 2;
    const centerY = boxBottom + boxH / 2;
    const left = ax < 0.2 ? boxLeft : centerX - contentW / 2;
    const top = centerY + contentH / 2;
    let pen = 0;
    const placed: PlacedGlyph[] = [];
    for (const ch of chars) {
        const glyph = font.glyphs[ch];
        placed.push({
            ch,
            x: left + (pen + glyph.xoff + glyph.w / 2) * scale,
            y: top - (glyph.yoff + glyph.h / 2) * scale,
            w: glyph.w * scale,
            h: glyph.h * scale,
            sx: glyph.x,
            sy: glyph.y,
            sw: glyph.w,
            sh: glyph.h,
        });
        pen += glyph.adv;
    }
    return placed;
}
