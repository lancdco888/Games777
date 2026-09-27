/**
 * Game 270 reel cadence from the native client, not the H5 override.
 *
 * Cfgs/Reel.lua is what CasinoContext loads when RUNTIME_IN_COCOS is set.
 * Stop stagger for a normal spin is Common.GetRellStopInterval (0.45s),
 * which NormalSlot passes into BaseReel:Stop. FreeSlot uses its own
 * delays {0, 0.8, 1}. Top-up cells use the special interval 0.25s.
 * BaseReel.lua is the scroll / bounce state machine.
 */

export type ReelPhase = 'none' | 'waiting' | 'scrolling' | 'bouncing';

export interface ReelSim {
    symbolNum: number;
    symbolHeight: number;
    scrollPx: number;
    minSymbols: number;
    bounceDuration: number;
    bounceDistance: number;
    /** Index 0 is the symbol above the window. Visible symbols are 1..symbolNum. */
    symbols: number[];
    offset: number;
    phase: ReelPhase;
    time: number;
    rollSymbolNum: number;
    showResult: boolean;
    /** Top to bottom. Popped from the end, matching Lua table.remove. */
    result: number[];
    resultDelay: number;
    quick: boolean;
    frameDt: number;
}

export interface ReelOptions {
    symbolNum: number;
    symbolHeight: number;
    /** Cfgs/Reel.lua scrollSpeed. Pixels per second are speed * symbolHeight * 60. */
    scrollSpeed: number;
    minSymbols: number;
    bounceDuration: number;
    bounceDistance: number;
    /** Visible symbols, top to bottom. */
    icons: number[];
}

export const NATIVE = {
    scrollSpeed: 0.45,
    bounceDuration: 0.4,
    bounceDistance: 30,
    minSymbols: 15,
    reelWidth: 165,
    reelHeight: 415,
    reelSpace: 5,
    symbolHeight: 415 / 3,
};

export const STOP_INTERVAL = {
    normal: 0.45,
    free: 0.45,
    special: 0.25,
};

/** FreeSlot.SetReelSymbolData delays, in reel order left / giant / right. */
export const FREE_STOP_DELAY = [0, 0.8, 1];

export const CELL_SPIN = {
    minSymbols: 5,
    bounceDuration: 0.18,
    bounceDistance: 100,
};

/** TopupBounsSlot stops by ConstCfg.AnimIndexs, one column at a time. */
export const SPECIAL_ORDER = [1, 6, 11, 2, 7, 12, 3, 8, 13, 4, 9, 14, 5, 10, 15];

export const AUTO_SPIN_GAP = 0.7;
export const LINE_BLINK = 0.5;
export const LINE_CYCLE = 2;
export const SYMBOL_BLINK = 0.5;

/** Symbols 8–12 are the only ones SymbolConfig marks needBlink. */
export const NEED_BLINK = new Set([8, 9, 10, 11, 12]);

/** Symbol component child that _PlayCommonAnim shows, and the movie sheet key. */
export const SYMBOL_MOVIE: Record<number, string> = {
    1: 'wild',
    2: 'scatter',
    4: 'pic1',
    5: 'pic2',
    6: 'pic3',
    7: 'pic4',
};

/** Placement of those children inside the 165x137 Symbol component. */
export const FX_BOX: Record<string, { x: number; y: number; w: number; h: number; center: boolean }> = {
    pic1: { x: 78, y: 71, w: 173 * 1.022, h: 144 * 0.977, center: true },
    pic2: { x: -4, y: -2, w: 172, h: 141, center: false },
    pic3: { x: 5, y: 9, w: 152, h: 124, center: false },
    pic4: { x: 0, y: 0, w: 165, h: 137, center: false },
    scatter: { x: 83, y: 68, w: 165, h: 137, center: true },
    wild: { x: 0, y: 0, w: 165, h: 137, center: false },
};

const FOUR_SOUND: Record<number, string> = {
    4: 'SND_Pic1',
    5: 'SND_Pic2',
    6: 'SND_Pic3',
    7: 'SND_Pic4',
};

/** WinLines parent is Slot child WinLines at (215, 199), and the slot top is 22. */
export const LINE_ORIGIN = { x: 215, y: 221 };
export const LINE_PITCH_X = 170;
export const LINE_PITCH_Y = 415 / 6;

/** Colors from Game270 WinLineConfigs, line 1 first. */
export const LINE_COLORS = [
    '#00ACEE', '#ED008A', '#EA1C24', '#00A550', '#303093', '#A56B08', '#F5921F', '#008FD1', '#5C1254', '#8BC541',
    '#BE198D', '#00A3BB', '#F06422', '#0071BB', '#F7947B', '#E90A6D', '#672D90', '#E91A3B', '#008A82', '#C9DA2C',
    '#F5E500', '#F8A1A4', '#E21355', '#0053A5', '#D15EA0', '#00ACEE', '#ED008A', '#EA1C24', '#00A550', '#303093',
    '#FFC20D', '#F5921F', '#008FD1', '#8D278D', '#8BC541', '#BE198D', '#02A7BF', '#F06422', '#0071BB', '#F6937B',
    '#EF0873', '#662C8F', '#E51740', '#00A898', '#C9DA2C', '#FFF102', '#37B348', '#EA1456', '#0053A5', '#D562A4',
];

/** Common.FaFaFaAudioData. ShowBottomWin plays this, not the win1–win16 chip table. */
export const WIN_TUNES = [
    { ratio: 0.0001, time: 0.1, fire: false, clip: 'wintune01' },
    { ratio: 0.2, time: 0.2, fire: false, clip: 'wintune02' },
    { ratio: 0.4, time: 0.3, fire: false, clip: 'wintune03' },
    { ratio: 0.6, time: 0.4, fire: false, clip: 'wintune04' },
    { ratio: 0.8, time: 0.5, fire: false, clip: 'wintune05' },
    { ratio: 1, time: 0.6, fire: false, clip: 'wintune06' },
    { ratio: 2, time: 0.7, fire: false, clip: 'wintune07' },
    { ratio: 3, time: 0.8, fire: false, clip: 'wintune08' },
    { ratio: 4, time: 0.9, fire: false, clip: 'wintune09' },
    { ratio: 5, time: 1.25, fire: false, clip: 'wintune10' },
    { ratio: 8, time: 1.5, fire: true, clip: 'wintune12' },
    { ratio: 15, time: 1.9, fire: true, clip: 'wintune13' },
    { ratio: 30, time: 2.25, fire: true, clip: 'wintune11' },
    { ratio: 40, time: 2.25, fire: true, clip: 'wintune14' },
    { ratio: 50, time: 4.1, fire: true, clip: 'wintune15' },
    { ratio: 100, time: 4.05, fire: true, clip: 'wintune16' },
];

export interface WinTune {
    ratio: number;
    time: number;
    fire: boolean;
    clip: string;
}

export interface WinCell {
    index: number;
    icon: number;
}

export interface PresentPlan {
    bell: boolean;
    animAt: number;
    linesAt: number;
    tune: WinTune | null;
    doneAt: number;
    chainAt: number;
}

export function winTune(win: number, bet: number): WinTune | null {
    if (win <= 0 || bet <= 0) {
        return null;
    }
    const ratio = win / bet;
    for (let i = 0; i < WIN_TUNES.length - 1; i += 1) {
        const current = WIN_TUNES[i];
        const next = WIN_TUNES[i + 1];
        if (ratio >= current.ratio && ratio < next.ratio) {
            return current;
        }
    }
    return WIN_TUNES[WIN_TUNES.length - 1];
}

export function leadWinSound(lines: { lineIndex: number; cells: { icon: number }[] }[]): { clip: string; time: number } | null {
    for (const line of lines) {
        if (line.lineIndex <= 0 || line.lineIndex > 50) {
            continue;
        }
        const hasWild = line.cells.some((cell) => cell.icon === 1);
        if (hasWild) {
            return { clip: 'SND_Wild', time: 2 };
        }
        if (line.cells.length >= 4) {
            const clip = FOUR_SOUND[line.cells[0]?.icon ?? 0];
            if (clip) {
                return { clip, time: 2.5 };
            }
        }
    }
    return null;
}

/**
 * NormalSlot anticipation: a reel with a lantern plays JP doonk when the
 * lanterns already seen plus a full remaining board can still reach 6.
 */
export function lanternReels(columns: number[][]): boolean[] {
    const flags = [false, false, false, false, false];
    let total = 0;
    for (let reel = 0; reel < 5; reel += 1) {
        const count = (columns[reel] ?? []).filter((icon) => icon === 3).length;
        const residue = Math.abs(reel + 1 - 5) * 3;
        if (count > 0 && total + count + residue >= 6) {
            total += count;
            flags[reel] = true;
        }
    }
    return flags;
}

/** WinLines.CreateLine. `rows` is the payline, top row 0. Six pieces, including the two ends. */
export function lineSegments(rows: number[]): { column: number; row: number; kind: number }[] {
    const segments = [];
    for (let i = 1; i <= 6; i += 1) {
        const current = rows[i - 1] ?? rows[i - 2] ?? 0;
        const kind = i === 1 || i === 6 ? 0 : current - (rows[i - 2] ?? current);
        segments.push({ column: i - 1, row: current * 2 - kind, kind });
    }
    return segments;
}

export function lineCenter(column: number, row: number): { x: number; y: number } {
    return {
        x: LINE_ORIGIN.x + column * LINE_PITCH_X,
        y: LINE_ORIGIN.y + (row + 1) * LINE_PITCH_Y,
    };
}

/**
 * Time from reel-stop until the next spin may start.
 * Scatter (enter free) waits 2s for the symbol anim and 6s for the lines.
 * A wild or four-of-a-kind sound holds the lines for its soundTime.
 * ShowBottomWin's tune plays during `doneAt - linesAt`. Auto spins add 0.7s.
 */
export function presentPlan(input: {
    win: number;
    bet: number;
    scatters: number;
    lines: { lineIndex: number; cells: { icon: number }[] }[];
    chained: boolean;
}): PresentPlan {
    const tune = winTune(input.win, input.bet);
    const tuneTime = tune ? tune.time : 0.01;
    const enterFree = input.scatters >= 3;
    const lead = enterFree ? null : leadWinSound(input.lines);
    const animAt = enterFree ? 2 : 0;
    const linesAt = enterFree ? 6 : (lead?.time ?? 0);
    const doneAt = linesAt + tuneTime;
    return {
        bell: enterFree,
        animAt,
        linesAt,
        tune,
        doneAt,
        chainAt: doneAt + (input.chained ? AUTO_SPIN_GAP : 0),
    };
}

export function restingReel(options: ReelOptions, randomIcon: () => number): ReelSim {
    const symbols = [randomIcon()];
    for (let i = 0; i < options.symbolNum; i += 1) {
        symbols.push(options.icons[i] ?? randomIcon());
    }
    symbols.push(randomIcon());
    return {
        symbolNum: options.symbolNum,
        symbolHeight: options.symbolHeight,
        scrollPx: options.scrollSpeed * options.symbolHeight * 60,
        minSymbols: options.minSymbols,
        bounceDuration: options.bounceDuration,
        bounceDistance: options.bounceDistance,
        symbols,
        offset: 0,
        phase: 'none',
        time: 0,
        rollSymbolNum: 0,
        showResult: false,
        result: [],
        resultDelay: 0,
        quick: false,
        frameDt: 0,
    };
}

export function spinReel(reel: ReelSim): void {
    reel.offset = 0;
    reel.rollSymbolNum = 0;
    reel.showResult = false;
    reel.result = [];
    reel.resultDelay = 0;
    reel.quick = false;
    reel.time = 0;
    reel.phase = 'waiting';
}

export function requestStop(reel: ReelSim, icons: number[], delay: number): void {
    if (reel.phase === 'none' || reel.phase === 'bouncing') {
        for (let i = 0; i < reel.symbolNum; i += 1) {
            reel.symbols[i + 1] = icons[i] ?? reel.symbols[i + 1];
        }
        reel.offset = 0;
        reel.phase = 'none';
        reel.showResult = false;
        return;
    }
    reel.showResult = true;
    reel.result = icons.slice(0, reel.symbolNum);
    reel.resultDelay = delay;
}

/** BaseReel:QuickStop. Ignored until a result has been requested. */
export function quickStop(reel: ReelSim): void {
    if (!reel.showResult) {
        return;
    }
    reel.rollSymbolNum = reel.minSymbols;
    reel.resultDelay = 0;
    reel.quick = true;
}

export function visibleIcons(reel: ReelSim): number[] {
    return reel.symbols.slice(1, 1 + reel.symbolNum);
}

function quadIn(time: number, duration: number): number {
    if (duration <= 0) {
        return 1;
    }
    const t = time / duration;
    return t * t;
}

function quadOut(time: number, duration: number): number {
    if (duration <= 0) {
        return 1;
    }
    const t = time / duration;
    return -t * (t - 2);
}

function lerp(from: number, to: number, alpha: number): number {
    return from * (1 - alpha) + to * alpha;
}

/** Returns 'bounce' on the frame scrolling hands off, then 'stop' when the settle ends. */
export function stepReel(reel: ReelSim, dt: number, randomIcon: () => number): 'bounce' | 'stop' | null {
    if (reel.phase === 'none') {
        return null;
    }
    reel.frameDt = dt;
    reel.time += dt;
    if (reel.phase === 'waiting') {
        reel.phase = 'scrolling';
        reel.time = 0;
        return null;
    }
    if (reel.phase === 'scrolling') {
        return scrollBy(reel, reel.scrollPx * dt, randomIcon);
    }
    const duration = reel.quick ? 0 : reel.bounceDuration;
    const half = duration * 0.5;
    const percent = reel.time <= half
        ? quadOut(reel.time, half)
        : 1 - quadIn(reel.time - half, half);
    if (reel.time >= duration) {
        reel.offset = 0;
        reel.phase = 'none';
        reel.showResult = false;
        reel.time = 0;
        return 'stop';
    }
    reel.offset = lerp(0, reel.bounceDistance, percent);
    return null;
}

function scrollBy(reel: ReelSim, delta: number, randomIcon: () => number): 'bounce' | null {
    let value = reel.offset + delta;
    const space = reel.symbolHeight;
    let bounced = false;
    while (value >= space) {
        value -= space;
        reel.rollSymbolNum += 1;
        if (!reel.showResult && reel.rollSymbolNum >= reel.minSymbols) {
            reel.rollSymbolNum = reel.minSymbols;
        }
        for (let i = reel.symbolNum + 1; i >= 1; i -= 1) {
            reel.symbols[i] = reel.symbols[i - 1];
        }
        let needRandom = true;
        if (reel.showResult && (reel.quick || reel.rollSymbolNum >= reel.minSymbols) && (reel.resultDelay <= 0 || reel.quick)) {
            needRandom = false;
            if (reel.result.length) {
                reel.symbols[0] = reel.result.pop() ?? randomIcon();
            } else {
                reel.symbols[0] = randomIcon();
                value = 0;
                reel.phase = 'bouncing';
                reel.time = 0;
                bounced = true;
            }
        }
        if (needRandom) {
            reel.symbols[0] = randomIcon();
        }
    }
    if (reel.showResult && reel.resultDelay > 0 && (reel.quick || reel.rollSymbolNum >= reel.minSymbols)) {
        reel.resultDelay -= reel.frameDt;
    }
    reel.offset = value;
    return bounced ? 'bounce' : null;
}
