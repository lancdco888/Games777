import {
    AudioClip,
    AudioSource,
    BlockInputEvents,
    Color,
    HorizontalTextAlignment,
    Label,
    Layers,
    Mask,
    Node,
    Rect,
    resources,
    Size,
    Sprite,
    SpriteFrame,
    UITransform,
    VerticalTextAlignment,
} from 'cc';
import { bindClick, BitmapReadout, loadSpriteFrame } from './CsbView';
import { MOVIES } from './Game270Fx';
import type { MovieSheet } from './Game270Fx';
import {
    CELL_SPIN,
    FREE_STOP_DELAY,
    FX_BOX,
    LINE_BLINK,
    LINE_COLORS,
    LINE_CYCLE,
    NATIVE,
    NEED_BLINK,
    SPECIAL_ORDER,
    STOP_INTERVAL,
    SYMBOL_BLINK,
    SYMBOL_MOVIE,
    lanternReels,
    lineCenter,
    lineSegments,
    presentPlan,
    quickStop,
    requestStop,
    restingReel,
    spinReel,
    stepReel,
} from './Game270Motion';
import type { PresentPlan, ReelSim } from './Game270Motion';
import { LINES, payHits, rollGrid, scoreGrid } from './Game270Rules';
import type { PayLine } from './Game270Rules';
import { formatMoney, HallState } from './HallState';
import type { GosClient } from './GosClient';
import { Slot270Session } from './Slot270';
import type { SpinStep } from './Slot270';

const BETS = [50, 100, 500, 1000];
const SCREEN_W = 1280;
const SCREEN_H = 720;

/** Reel window from the Slot component. Row 0 is the top row. */
const SLOT_TOP = 22;
const REEL_X = 216;
const REEL_Y = SLOT_TOP + 201;
const REEL_W = 165;
const REEL_GAP = 5;
const SYMBOL_H = 415 / 3;

/** Opening board from ConstCfg.InitUIBox. */
const OPENING = [
    [6, 12, 9],
    [10, 5, 8],
    [10, 6, 9],
    [11, 6, 7],
    [9, 2, 8],
];

const SYMBOL_ART: Record<number, string> = {
    1: 'game270/art/slots_345_wild',
    2: 'game270/art/slots_345_ssc1',
    3: 'game270/art/slots_symbol_denglong',
    4: 'game270/art/slots_345_sh1',
    5: 'game270/art/slots_345_sh2',
    6: 'game270/art/slots_345_sh3',
    7: 'game270/art/slots_345_sh4',
    8: 'game270/art/slots_345_sl1',
    9: 'game270/art/slots_345_sl2',
    10: 'game270/art/slots_345_sl3',
    11: 'game270/art/slots_345_sl4',
    12: 'game270/art/slots_345_sl5',
};

const SYMBOL_W = 165;
const SYMBOL_BOX_H = 137;
const SYMBOL_BOX: Record<number, { x: number; y: number; w: number; h: number; center?: boolean }> = {
    1: { x: 83, y: 68, w: 165, h: 137, center: true },
    2: { x: 83, y: 68, w: 165, h: 137, center: true },
    3: { x: 5, y: 5, w: 155, h: 127 },
    4: { x: 82, y: 68, w: 165, h: 137, center: true },
    5: { x: 82, y: 69, w: 165, h: 137, center: true },
    6: { x: 8, y: 10, w: 147, h: 121 },
    7: { x: 6, y: -1, w: 159, h: 135 },
    8: { x: 5, y: 5, w: 155, h: 127 },
    9: { x: 5, y: 5, w: 155, h: 127 },
    10: { x: 5, y: 5, w: 155, h: 127 },
    11: { x: 5, y: 5, w: 155, h: 127 },
    12: { x: 5, y: 5, w: 155, h: 127 },
};

const JACKPOTS = [
    { name: 'grand', x: 280, mult: 200 },
    { name: 'major', x: 567, mult: 80 },
    { name: 'minor', x: 815, mult: 20 },
    { name: 'mini', x: 1041, mult: 8 },
];

const LINE_KIND = ['slots_line_flat', 'slots_line_short_down', 'slots_line_long_down', 'slots_line_short_up', 'slots_line_long_up'];
const LINE_ART: Record<number, string> = {
    0: 'slots_line_flat',
    1: 'slots_line_short_down',
    2: 'slots_line_long_down',
    [-1]: 'slots_line_short_up',
    [-2]: 'slots_line_long_up',
};

type BoardKind = 'normal' | 'free' | 'special';
type RandomKind = 'normal' | 'free-left' | 'free-mid' | 'free-right' | 'cell';
type Phase = 'idle' | 'spinning' | 'presenting' | 'showcase';

interface Strip {
    sim: ReelSim;
    root: Node;
    holders: Node[];
    sprites: Sprite[];
    fx: Sprite[];
    width: number;
    height: number;
    graphicH: number;
    randomKind: RandomKind;
    column: number;
    cellIndex: number;
    animK: number;
}

interface Board {
    kind: BoardKind;
    root: Node;
    strips: Strip[];
}

interface LinePiece {
    root: Node;
    body: Sprite;
    head: Sprite;
    tail: Sprite;
    headText: Label;
    tailText: Label;
}

interface Coin {
    node: Node;
    sprite: Sprite;
    age: number;
    duration: number;
    dx: number;
    jump: number;
    alive: boolean;
}

interface SpinVisual {
    kind: BoardKind;
    grid: number[][];
    win: number;
    bet: number;
    lines: PayLine[];
    scatters: number;
    note: string;
    jackpots: Array<number | null> | null;
}

/**
 * 财富之眼. Reels follow BaseReel.lua: scroll, minimum symbols, staggered stop, then bounce.
 * Wins blink the original payline and loop the symbol movies.
 */
export class Game270View {
    private readonly root: Node;
    private readonly art = new Map<number, SpriteFrame>();
    private readonly clips = new Map<string, AudioClip>();
    private readonly movies = new Map<string, SpriteFrame[]>();
    private readonly lineArt = new Map<string, SpriteFrame>();
    private readonly boards = new Map<BoardKind, Board>();
    private readonly jackpotLabels: BitmapReadout[] = [];
    private readonly pieces: LinePiece[] = [];
    private readonly coins: Coin[] = [];
    private balance: BitmapReadout | null = null;
    private topBet: BitmapReadout | null = null;
    private topWin: BitmapReadout | null = null;
    private betLabel: BitmapReadout | null = null;
    private winLabel: BitmapReadout | null = null;
    private betIndex = 1;
    private betChoices = BETS;
    private session: Slot270Session | null = null;
    private ready: Promise<void> = Promise.resolve();
    private enterError = '';
    private serverPlay = false;
    private jackpotValues: Array<number | null> = [null, null, null, null];
    private winAmount = 0;
    private winShown = 0;
    private audio: AudioSource | null = null;
    private grid: number[][] = OPENING.map((column) => column.slice());
    private rule: Node | null = null;
    private ruleClose: Node | null = null;
    private rulePage = 0;
    private ruleSprite: Sprite | null = null;
    private boardKind: BoardKind = 'normal';
    private phase: Phase = 'idle';
    private busy = false;
    private latched = false;
    private spun = 0;
    private finished = 0;
    private held = new Set<number>();
    private lanterns = [false, false, false, false, false];
    private doonk = 0;
    private specialStopped = 0;
    private pendingGrid: number[][] = [];
    private visual: SpinVisual | null = null;
    private pendingChained = false;
    private plan: PresentPlan | null = null;
    private presentTime = 0;
    private winLines: PayLine[] = [];
    private animCells = new Map<number, number>();
    private tunePlayed = false;
    private scatterPlayed = false;
    private settled = false;
    private stepResolved = false;
    private stepDone: (() => void) | null = null;
    private coinTimer = 0;
    private coinFrames: SpriteFrame[] = [];
    private lineLayer: Node | null = null;
    private fxLayer: Node | null = null;
    private ticker: ReturnType<typeof setInterval> | null = null;
    private lastTick = 0;

    constructor(
        parent: Node,
        private readonly state: HallState,
        private readonly onExit: () => void,
        private readonly notify: (text: string) => void,
        server: GosClient | null = null,
    ) {
        this.root = new Node('game270');
        this.root.layer = Layers.Enum.UI_2D;
        const transform = this.root.addComponent(UITransform);
        transform.setContentSize(SCREEN_W, SCREEN_H);
        this.root.setPosition(640, 360, 0);
        this.root.setParent(parent);
        this.root.addComponent(BlockInputEvents);
        const mask = this.root.addComponent(Mask);
        mask.type = Mask.Type.GRAPHICS_RECT;
        this.audio = this.root.addComponent(AudioSource);
        this.build();
        this.preload();
        this.root.setSiblingIndex(parent.children.length - 1);
        this.lastTick = Date.now();
        this.ticker = setInterval(() => this.frame(), 16);
        if (server) {
            this.serverPlay = true;
            this.session = new Slot270Session(server, (balances) => {
                this.state.applyBalances({
                    money: balances.money,
                    moneySafe: balances.moneySafe,
                    giftSafe: balances.giftSafe,
                });
                this.refreshMoney();
            });
            this.ready = this.session.enter(270).then((opened) => {
                if (!this.root.isValid) {
                    return;
                }
                if (opened.bets.length) {
                    this.betChoices = opened.bets.map((bet) => bet.money);
                    this.betIndex = 0;
                }
                this.paint(opened.columns);
                this.winAmount = opened.win;
                this.winShown = opened.win;
                this.refreshMoney();
                if (opened.note) {
                    this.notify(opened.note);
                }
            }).catch((error: unknown) => {
                this.enterError = error instanceof Error ? error.message : '进入 270 失败';
                this.notify(this.enterError);
            });
        }
    }

    private build(): void {
        this.picture('game270/art/slots_270_background_ng', 0, 0, SCREEN_W, SCREEN_H);
        this.picture('game270/theme/henban_u3d', -360, 0, 2000, 111);
        this.picture('game270/theme/title_top_1', 375 - 77, 6, 154, 27);
        this.picture('game270/theme/title_top_2', 656 - 77, 6, 154, 27);
        this.picture('game270/theme/title_top_3', 966 - 77, 6, 154, 27);
        this.picture('game270/art/caijinbg_1', 32, 112, 1216, 90);
        this.picture('game270/art/slots_270_frame_01', 210, SLOT_TOP + 187, 858, 437);
        this.picture('game270/art/line_background_1', 186 - 33, SLOT_TOP + 404 - 68, 66, 136);
        this.picture('game270/art/line_background_1', 1090 - 33, SLOT_TOP + 404 - 68, 66, 136);
        this.picture('game270/art/50Line_en', 186 - 22, SLOT_TOP + 404 - 52, 45, 105);
        this.picture('game270/art/50Line_en', 1090 - 22, SLOT_TOP + 403 - 52, 45, 105);
        this.buildBoards();
        this.buildEffects();
        this.paint(OPENING.map((column) => column.slice()));

        this.picture('game270/theme/bg_sl', -5, 640, 1290, 84);
        this.picture('game270/theme/bg_5', 98, 652, 270, 51);
        this.picture('game270/theme/bg_fsxsb', 646 - 193, 640 + 35 - 40, 386, 80);

        this.picture('game270/theme/fh', 6, 16, 140, 46, () => this.leave());
        this.picture('game270/theme/btn_bz_1', 7, 641, 65, 72, () => this.showRule());
        this.picture('game270/theme/btn_a1_1', 80, 640, 75, 72, () => this.changeBet(-1));
        this.picture('game270/theme/btn_a2_1', 308, 640, 75, 72, () => this.changeBet(1));
        this.picture('game270/theme/btn_ii_1', 838, 640, 106, 77, () => this.changeBet(BETS.length));
        this.picture('game270/theme/max', 848, 658, 85, 37);
        const spin = this.picture('game270/theme/ksan', 1072, 632, 203, 88, () => this.spin());
        const spinLabel = this.picture('game270/theme/ks', 0, 0, 121, 55);
        spinLabel.setParent(spin);
        spinLabel.setPosition(102 - 203 / 2, 88 / 2 - 43, 0);

        this.balance = this.readout(291, 36, 168, 36, 'slot');
        this.topBet = this.readout(659 - 62, 36, 124, 36, 'slot');
        this.topWin = this.readout(966 - 120, 36, 240, 36, 'slot');
        this.betLabel = this.readout(231 - 70, 664, 140, 36, 'slot');
        this.winLabel = this.readout(648 - 150, 658, 300, 40, 'slot');
        JACKPOTS.forEach((jackpot) => {
            this.jackpotLabels.push(this.readout(jackpot.x - 90, 148, 180, 40, 'slotJackpot'));
        });
        this.refreshMoney();
    }

    private buildBoards(): void {
        const normal = this.makeBoard('normal');
        for (let col = 0; col < 5; col += 1) {
            normal.strips.push(this.makeStrip(normal.root, {
                x: REEL_X + col * (REEL_W + REEL_GAP),
                y: REEL_Y,
                width: REEL_W,
                height: NATIVE.reelHeight,
                symbolNum: 3,
                graphicH: SYMBOL_H,
                symbolHeight: NATIVE.symbolHeight,
                minSymbols: NATIVE.minSymbols,
                bounceDuration: NATIVE.bounceDuration,
                bounceDistance: NATIVE.bounceDistance,
                randomKind: 'normal',
                column: col,
                cellIndex: 0,
            }));
        }
        const free = this.makeBoard('free');
        free.root.active = false;
        const freeSpec = [
            { x: 0, width: REEL_W, symbolNum: 3, graphicH: SYMBOL_H, symbolHeight: NATIVE.symbolHeight, minSymbols: NATIVE.minSymbols, randomKind: 'free-left' as const, column: 0 },
            { x: 173, width: 500, symbolNum: 1, graphicH: 405, symbolHeight: NATIVE.reelHeight, minSymbols: 10, randomKind: 'free-mid' as const, column: 2 },
            { x: 684, width: REEL_W, symbolNum: 3, graphicH: SYMBOL_H, symbolHeight: NATIVE.symbolHeight, minSymbols: NATIVE.minSymbols, randomKind: 'free-right' as const, column: 4 },
        ];
        freeSpec.forEach((spec) => {
            free.strips.push(this.makeStrip(free.root, {
                ...spec,
                y: REEL_Y,
                height: NATIVE.reelHeight,
                bounceDuration: NATIVE.bounceDuration,
                bounceDistance: NATIVE.bounceDistance,
                cellIndex: spec.randomKind === 'free-mid' ? 8 : 0,
            }));
        });
        const special = this.makeBoard('special');
        special.root.active = false;
        for (let index = 1; index <= 15; index += 1) {
            const col = (index - 1) % 5;
            const row = Math.floor((index - 1) / 5);
            special.strips.push(this.makeStrip(special.root, {
                x: REEL_X + col * (REEL_W + REEL_GAP),
                y: REEL_Y + row * SYMBOL_H,
                width: REEL_W,
                height: SYMBOL_H,
                symbolNum: 1,
                graphicH: SYMBOL_H,
                symbolHeight: NATIVE.symbolHeight,
                minSymbols: CELL_SPIN.minSymbols,
                bounceDuration: CELL_SPIN.bounceDuration,
                bounceDistance: CELL_SPIN.bounceDistance,
                randomKind: 'cell',
                column: col,
                cellIndex: index,
            }));
        }
    }

    private makeBoard(kind: BoardKind): Board {
        const root = new Node(`reels-${kind}`);
        root.layer = Layers.Enum.UI_2D;
        root.addComponent(UITransform).setContentSize(SCREEN_W, SCREEN_H);
        root.setParent(this.root);
        const board = { kind, root, strips: [] as Strip[] };
        this.boards.set(kind, board);
        return board;
    }

    private makeStrip(parent: Node, spec: {
        x: number;
        y: number;
        width: number;
        height: number;
        symbolNum: number;
        graphicH: number;
        symbolHeight: number;
        minSymbols: number;
        bounceDuration: number;
        bounceDistance: number;
        randomKind: RandomKind;
        column: number;
        cellIndex: number;
    }): Strip {
        const root = new Node('reel');
        root.layer = Layers.Enum.UI_2D;
        root.addComponent(UITransform).setContentSize(spec.width, spec.height);
        const center = fguiCenter(spec.x, spec.y, spec.width, spec.height);
        root.setPosition(center.x, center.y, 0);
        root.setParent(parent);
        const mask = root.addComponent(Mask);
        mask.type = Mask.Type.GRAPHICS_RECT;
        const holders: Node[] = [];
        const sprites: Sprite[] = [];
        const fx: Sprite[] = [];
        for (let i = 0; i < spec.symbolNum + 2; i += 1) {
            const holder = new Node('sym');
            holder.layer = Layers.Enum.UI_2D;
            holder.addComponent(UITransform).setContentSize(spec.width, spec.graphicH);
            holder.setParent(root);
            holders.push(holder);
            sprites.push(this.iconSprite(holder));
            const movie = this.iconSprite(holder);
            movie.node.active = false;
            fx.push(movie);
        }
        const sim = restingReel({
            symbolNum: spec.symbolNum,
            symbolHeight: spec.symbolHeight,
            scrollSpeed: NATIVE.scrollSpeed,
            minSymbols: spec.minSymbols,
            bounceDuration: spec.bounceDuration,
            bounceDistance: spec.bounceDistance,
            icons: Array.from({ length: spec.symbolNum }, () => 8),
        }, () => this.rollIcon(spec.randomKind));
        return {
            sim,
            root,
            holders,
            sprites,
            fx,
            width: spec.width,
            height: spec.height,
            graphicH: spec.graphicH,
            randomKind: spec.randomKind,
            column: spec.column,
            cellIndex: spec.cellIndex,
            animK: 0,
        };
    }

    private iconSprite(parent: Node): Sprite {
        const node = new Node('icon');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform);
        node.setParent(parent);
        const sprite = node.addComponent(Sprite);
        sprite.sizeMode = Sprite.SizeMode.CUSTOM;
        sprite.type = Sprite.Type.SIMPLE;
        sprite.trim = true;
        return sprite;
    }

    private buildEffects(): void {
        const layer = new Node('fx');
        layer.layer = Layers.Enum.UI_2D;
        layer.addComponent(UITransform).setContentSize(SCREEN_W, SCREEN_H);
        layer.setParent(this.root);
        this.fxLayer = layer;
        const lines = new Node('lines');
        lines.layer = Layers.Enum.UI_2D;
        lines.addComponent(UITransform).setContentSize(SCREEN_W, SCREEN_H);
        lines.setParent(layer);
        lines.active = false;
        this.lineLayer = lines;
        for (let i = 0; i < 6; i += 1) {
            this.pieces.push(this.makeLinePiece(lines));
        }
        for (let i = 0; i < 40; i += 1) {
            const node = new Node('coin');
            node.layer = Layers.Enum.UI_2D;
            node.addComponent(UITransform).setContentSize(69, 67);
            node.setParent(layer);
            node.active = false;
            const sprite = node.addComponent(Sprite);
            sprite.sizeMode = Sprite.SizeMode.CUSTOM;
            sprite.trim = false;
            this.coins.push({ node, sprite, age: 0, duration: 1, dx: 0, jump: -400, alive: false });
        }
    }

    private makeLinePiece(parent: Node): LinePiece {
        const root = new Node('line');
        root.layer = Layers.Enum.UI_2D;
        root.addComponent(UITransform).setContentSize(60, 20);
        root.setParent(parent);
        root.active = false;
        return {
            root,
            body: this.iconSprite(root),
            head: this.iconSprite(root),
            tail: this.iconSprite(root),
            headText: this.lineLabel(root),
            tailText: this.lineLabel(root),
        };
    }

    private lineLabel(parent: Node): Label {
        const node = new Node('num');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(40, 36);
        node.setParent(parent);
        const label = node.addComponent(Label);
        label.fontSize = 16;
        label.lineHeight = 18;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.verticalAlign = VerticalTextAlignment.CENTER;
        label.color = new Color(255, 255, 255, 255);
        label.string = '';
        return label;
    }

    private preload(): void {
        Object.keys(SYMBOL_ART).forEach((key) => {
            const id = Number(key);
            loadSpriteFrame(SYMBOL_ART[id], (frame) => {
                if (!frame || !this.root.isValid) {
                    return;
                }
                this.art.set(id, frame);
                if (this.phase === 'idle') {
                    this.paint(this.grid);
                }
            });
        });
        Object.entries(MOVIES).forEach(([key, movie]) => {
            loadSpriteFrame(movie.file, (frame) => {
                if (!frame || !this.root.isValid) {
                    return;
                }
                const frames = sliceMovie(frame, movie);
                this.movies.set(key, frames);
                if (key === 'coin') {
                    this.coinFrames = frames;
                }
            });
        });
        LINE_KIND.forEach((name) => {
            loadSpriteFrame(`game270/art/${name}`, (frame) => {
                if (frame) {
                    this.lineArt.set(name, frame);
                }
            });
        });
        const clips = ['reelstop', 'feature_bell', 'SND_Scatter', 'SND_Wild', 'SND_Pic1', 'SND_Pic2', 'SND_Pic3', 'SND_Pic4'];
        for (let i = 1; i <= 5; i += 1) {
            clips.push(`SND_JPDoonk${i}`, `SND_HandSDoonk${i}`);
        }
        for (let i = 1; i <= 16; i += 1) {
            clips.push(`wintune${String(i).padStart(2, '0')}`);
        }
        clips.forEach((name) => {
            resources.load(`game270/audio/${name}`, AudioClip, (err, clip) => {
                if (!err && clip) {
                    this.clips.set(name, clip);
                }
            });
        });
    }

    private frame(): void {
        if (!this.root.isValid) {
            this.stopTicker();
            return;
        }
        const now = Date.now();
        const dt = Math.min(0.05, Math.max(0, (now - this.lastTick) / 1000));
        this.lastTick = now;
        const board = this.boards.get(this.boardKind);
        if (!board) {
            return;
        }
        if (this.phase === 'spinning') {
            for (const strip of board.strips) {
                const event = stepReel(strip.sim, dt, () => this.rollIcon(strip.randomKind));
                if (event === 'bounce' && this.boardKind !== 'special') {
                    this.onColumnBounce(strip);
                }
                if (event === 'stop') {
                    this.finished += 1;
                    this.layoutStrip(strip);
                    if (this.boardKind === 'special') {
                        this.onCellStop(strip);
                    }
                    this.checkDone();
                }
            }
            this.layoutBoard(board);
        }
        if (this.phase === 'presenting' || this.phase === 'showcase') {
            this.presentTime += dt;
            this.tickPresentation(dt);
        }
    }

    private spin(): void {
        if (this.phase === 'spinning') {
            this.boards.get(this.boardKind)?.strips.forEach((strip) => quickStop(strip.sim));
            return;
        }
        if (this.phase === 'presenting') {
            this.skipPresentation();
            return;
        }
        this.closeRule();
        if (this.serverPlay) {
            void this.spinOnServer();
            return;
        }
        const bet = this.betChoices[this.betIndex];
        const paid = this.state.spend(bet);
        if (!paid.ok) {
            this.notify(paid.message);
            return;
        }
        const finalGrid = rollGrid();
        const scored = scoreGrid(finalGrid, bet);
        this.busy = true;
        this.winAmount = 0;
        this.winShown = 0;
        this.refreshMoney();
        this.beginSpin('normal', this.grid);
        void this.arm({
            kind: 'normal',
            grid: finalGrid,
            win: scored.win,
            bet,
            lines: payHits(finalGrid),
            scatters: countSymbol(finalGrid, 2),
            note: '',
            jackpots: null,
        }, false);
    }

    private async spinOnServer(): Promise<void> {
        const session = this.session;
        if (!session || this.busy) {
            if (!session) {
                this.notify('还没有连上 270 服务器');
            }
            return;
        }
        if (this.enterError) {
            this.notify(this.enterError);
            return;
        }
        const bet = this.betChoices[this.betIndex] ?? 0;
        this.busy = true;
        this.winAmount = 0;
        this.winShown = 0;
        this.refreshMoney();
        const mode = session.mode;
        this.beginSpin(mode, this.grid);
        try {
            await this.ready;
        } catch {
            this.abortSpin();
            return;
        }
        if (this.enterError || !this.root.isValid) {
            this.abortSpin();
            return;
        }
        let steps: SpinStep[] = [];
        try {
            steps = await session.spin(bet);
        } catch (error) {
            this.abortSpin();
            this.notify(error instanceof Error ? error.message : '开奖失败');
            return;
        }
        if (!this.root.isValid) {
            return;
        }
        for (let index = 0; index < steps.length; index += 1) {
            const step = steps[index];
            if (index > 0) {
                this.beginSpin(step.mode, this.grid);
            }
            await this.arm(visualFromStep(step, bet), index < steps.length - 1);
            if (!this.root.isValid) {
                return;
            }
        }
    }

    private beginSpin(kind: BoardKind, grid: number[][]): void {
        this.stopEffects();
        this.boardKind = kind;
        this.showOnly(kind);
        this.spun = 0;
        this.finished = 0;
        this.latched = false;
        this.doonk = 0;
        this.specialStopped = 0;
        this.held = new Set();
        const board = this.boards.get(kind);
        if (!board) {
            return;
        }
        if (kind === 'special') {
            for (let row = 0; row < 3; row += 1) {
                for (let col = 0; col < 5; col += 1) {
                    if ((grid[col]?.[row] ?? 0) === 3) {
                        this.held.add(row * 5 + col + 1);
                    }
                }
            }
        }
        for (const strip of board.strips) {
            if (kind === 'special' && this.held.has(strip.cellIndex)) {
                this.restStrip(strip, [3]);
                continue;
            }
            this.restStrip(strip, this.iconsFor(kind, strip, grid));
            spinReel(strip.sim);
            this.spun += 1;
        }
        this.phase = 'spinning';
    }

    private arm(visual: SpinVisual, chained: boolean): Promise<void> {
        this.visual = visual;
        this.pendingChained = chained;
        this.stepResolved = false;
        this.settled = false;
        this.tunePlayed = false;
        this.scatterPlayed = false;
        return new Promise((resolve) => {
            this.stepDone = resolve;
            this.latch(visual);
        });
    }

    private latch(visual: SpinVisual): void {
        const grid = visual.grid.map((column) => column.slice());
        if (visual.kind === 'special') {
            this.held.forEach((index) => {
                const col = (index - 1) % 5;
                const row = Math.floor((index - 1) / 5);
                if (grid[col]) {
                    grid[col][row] = 3;
                }
            });
        }
        this.pendingGrid = grid;
        this.lanterns = lanternReels(grid);
        if (visual.jackpots) {
            this.jackpotValues = visual.jackpots;
        }
        const board = this.boards.get(this.boardKind);
        if (!board) {
            return;
        }
        if (visual.kind === 'normal') {
            board.strips.forEach((strip, col) => {
                requestStop(strip.sim, grid[col] ?? [8, 8, 8], STOP_INTERVAL.normal * col);
            });
        } else if (visual.kind === 'free') {
            const strips = board.strips;
            requestStop(strips[0].sim, grid[0] ?? [8, 8, 8], FREE_STOP_DELAY[0]);
            requestStop(strips[1].sim, [grid[2]?.[1] ?? 8], FREE_STOP_DELAY[1]);
            requestStop(strips[2].sim, grid[4] ?? [8, 8, 8], FREE_STOP_DELAY[2]);
        } else {
            let timer = 0;
            SPECIAL_ORDER.forEach((cell, order) => {
                const strip = board.strips[cell - 1];
                strip.animK = order + 1;
                if (this.held.has(cell)) {
                    return;
                }
                timer += 1;
                const col = (cell - 1) % 5;
                const row = Math.floor((cell - 1) / 5);
                requestStop(strip.sim, [grid[col]?.[row] ?? 8], STOP_INTERVAL.special * (timer - 1));
            });
        }
        this.latched = true;
        this.checkDone();
    }

    private checkDone(): void {
        if (this.phase !== 'spinning' || !this.latched || this.finished < this.spun) {
            return;
        }
        this.beginPresentation();
    }

    private beginPresentation(): void {
        const visual = this.visual;
        if (!visual) {
            return;
        }
        this.grid = this.pendingGrid;
        this.phase = 'presenting';
        this.presentTime = 0;
        this.coinTimer = 0;
        this.winAmount = visual.win;
        this.winShown = 0;
        this.winLines = visual.lines.filter((line) => line.lineIndex >= 1 && line.lineIndex <= LINES.length);
        this.animCells = animMap(visual.lines, this.grid, visual.scatters >= 3);
        this.plan = presentPlan({
            win: visual.win,
            bet: visual.bet,
            scatters: visual.scatters,
            lines: this.winLines,
            chained: this.pendingChained,
        });
        if (this.plan.bell) {
            this.play('feature_bell');
        } else {
            const sound = leadSound(this.winLines);
            if (sound) {
                this.play(sound);
            }
        }
        if (visual.note) {
            this.notify(visual.note);
        }
        this.refreshMoney();
    }

    private tickPresentation(dt: number): void {
        const plan = this.plan;
        if (!plan) {
            return;
        }
        if (plan.bell && !this.scatterPlayed && this.presentTime >= plan.animAt) {
            this.scatterPlayed = true;
            this.play('SND_Scatter');
        }
        if (!this.tunePlayed && this.presentTime >= plan.linesAt) {
            this.tunePlayed = true;
            if (plan.tune) {
                this.playTune(plan.tune.clip);
            }
        }
        if (this.presentTime >= plan.linesAt) {
            const span = plan.tune?.time ?? 0.01;
            const t = Math.min(1, (this.presentTime - plan.linesAt) / span);
            this.winShown = this.winAmount * t;
            this.refreshMoney();
        }
        this.applyWinVisuals();
        this.stepCoins(dt);
        if (!this.settled && this.presentTime >= plan.doneAt) {
            this.settle();
        }
        if (!this.stepResolved && this.phase === 'presenting' && this.presentTime >= plan.chainAt) {
            this.finishStep();
        }
    }

    private settle(): void {
        if (this.settled) {
            return;
        }
        this.settled = true;
        this.winShown = this.winAmount;
        if (!this.serverPlay && this.winAmount > 0) {
            this.state.award(this.winAmount);
        }
        this.refreshMoney();
    }

    private finishStep(): void {
        this.stepResolved = true;
        this.settle();
        const chained = this.pendingChained;
        if (!chained) {
            this.phase = 'showcase';
            this.busy = false;
        } else {
            this.phase = 'idle';
        }
        const done = this.stepDone;
        this.stepDone = null;
        done?.();
    }

    private skipPresentation(): void {
        if (!this.plan) {
            return;
        }
        this.presentTime = this.plan.chainAt;
        this.audio?.stop();
        this.winShown = this.winAmount;
        this.coins.forEach((coin) => {
            coin.alive = false;
            coin.node.active = false;
        });
        this.finishStep();
    }

    private abortSpin(): void {
        this.busy = false;
        this.phase = 'idle';
        this.latched = false;
        this.boards.get(this.boardKind)?.strips.forEach((strip) => {
            strip.sim.phase = 'none';
            strip.sim.offset = 0;
        });
        this.layoutBoard(this.boards.get(this.boardKind));
    }

    private onColumnBounce(strip: Strip): void {
        if (this.boardKind === 'normal' && this.lanterns[strip.column]) {
            this.doonk += 1;
            this.play(`SND_JPDoonk${Math.min(5, this.doonk)}`);
        }
        this.play('reelstop');
    }

    private onCellStop(strip: Strip): void {
        this.specialStopped += 1;
        const row = Math.floor((strip.cellIndex - 1) / 5);
        const below = this.held.has(strip.cellIndex + 5);
        const below2 = this.held.has(strip.cellIndex + 10);
        const play = row === 2 || (row === 1 && below) || (row === 0 && below && below2);
        if (!play) {
            return;
        }
        this.play('reelstop');
        const icon = this.pendingGrid[strip.column]?.[row];
        if (icon === 3 && this.specialStopped < 14) {
            const n = strip.animK % 5 === 0 ? 5 : strip.animK % 5;
            this.play(`SND_HandSDoonk${n}`);
        }
    }

    private applyWinVisuals(): void {
        const board = this.boards.get(this.boardKind);
        const plan = this.plan;
        if (!board || !plan) {
            return;
        }
        for (const strip of board.strips) {
            strip.fx.forEach((sprite) => {
                sprite.node.active = false;
            });
            strip.sprites.forEach((sprite) => {
                sprite.node.active = true;
            });
        }
        if (this.presentTime >= plan.animAt) {
            this.animCells.forEach((icon, index) => {
                const movie = SYMBOL_MOVIE[icon];
                const frames = movie ? this.movies.get(movie) : undefined;
                const holder = this.holderFor(index);
                if (!movie || !frames?.length || !holder) {
                    return;
                }
                const sheet = MOVIES[movie];
                const frame = Math.floor((this.presentTime - plan.animAt) / sheet.interval) % frames.length;
                holder.sprite.node.active = false;
                this.placeFx(holder.fx, movie, holder.strip, frames[frame]);
            });
        }
        if (!this.lineLayer || this.presentTime < plan.linesAt || !this.winLines.length) {
            if (this.lineLayer) {
                this.lineLayer.active = false;
            }
            return;
        }
        const shown = Math.floor((this.presentTime - plan.linesAt) / LINE_CYCLE) % this.winLines.length;
        const line = this.winLines[shown];
        const rows = LINES[line.lineIndex - 1];
        if (rows) {
            this.showLine(line.lineIndex, rows);
            const on = Math.floor((this.presentTime - plan.linesAt) / LINE_BLINK) % 2 === 0;
            this.lineLayer.active = on;
        }
        const blinkOn = Math.floor((this.presentTime - plan.linesAt) / SYMBOL_BLINK) % 2 === 0;
        line.cells.forEach((cell) => {
            if (!NEED_BLINK.has(cell.icon)) {
                return;
            }
            const holder = this.holderFor(cell.index);
            if (holder) {
                holder.sprite.node.active = blinkOn;
            }
        });
    }

    private showLine(lineIndex: number, rows: number[]): void {
        const color = hexColor(LINE_COLORS[lineIndex - 1] ?? '#FFFFFF');
        lineSegments(rows).forEach((segment, index) => {
            const piece = this.pieces[index];
            if (!piece) {
                return;
            }
            const center = lineCenter(segment.column, segment.row);
            const pos = fguiCenter(center.x - 30, center.y - 10, 60, 20);
            piece.root.setPosition(pos.x, pos.y, 0);
            piece.root.active = true;
            const art = this.lineArt.get(LINE_ART[segment.kind] ?? 'slots_line_flat');
            if (art) {
                fitNative(piece.body, art, color);
                piece.body.node.setPosition(0, 1, 0);
            }
            const head = this.lineArt.get('slots_line_head');
            piece.head.node.active = segment.column === 0 && !!head;
            piece.tail.node.active = segment.column === 5 && !!head;
            if (head && segment.column === 0) {
                fitNative(piece.head, head, color);
                piece.head.node.setPosition(-42, 7.5, 0);
            }
            if (head && segment.column === 5) {
                fitNative(piece.tail, head, color);
                piece.tail.node.setPosition(22, 7.5, 0);
            }
            piece.headText.node.active = segment.column === 0;
            piece.tailText.node.active = segment.column === 5;
            piece.headText.string = String(lineIndex);
            piece.tailText.string = String(lineIndex);
            piece.headText.node.setPosition(-34, 2, 0);
            piece.tailText.node.setPosition(32, 1.5, 0);
        });
    }

    private stepCoins(dt: number): void {
        const plan = this.plan;
        if (plan?.tune?.fire && this.presentTime >= plan.linesAt && this.presentTime < plan.linesAt + plan.tune.time) {
            this.coinTimer += dt;
            while (this.coinTimer >= 1 / 20) {
                this.coinTimer -= 1 / 20;
                this.spawnCoin();
            }
        }
        const frames = this.coinFrames;
        this.coins.forEach((coin) => {
            if (!coin.alive) {
                return;
            }
            coin.age += dt;
            const linear = Math.min(1, coin.age / coin.duration);
            const eased = Math.sin(linear * Math.PI / 2);
            const fguiY = coin.jump * 4 * eased * (1 - eased);
            coin.node.setPosition(coin.dx * eased, -360 - fguiY, 0);
            if (frames.length) {
                const frame = frames[Math.floor(coin.age / MOVIES.coin.interval) % frames.length];
                fitFrame(coin.sprite, frame, MOVIES.coin.width, MOVIES.coin.height);
            }
            if (linear >= 1) {
                coin.alive = false;
                coin.node.active = false;
            }
        });
    }

    private spawnCoin(): void {
        const coin = this.coins.find((item) => !item.alive) ?? this.coins[0];
        if (!coin || !this.coinFrames.length) {
            return;
        }
        const height = 300 + Math.random() * 350;
        const width = 200 + Math.random() * 100;
        coin.alive = true;
        coin.age = 0;
        coin.jump = -height;
        coin.dx = (Math.random() < 0.5 ? -1 : 1) * width;
        coin.duration = height / 250;
        coin.node.active = true;
        coin.node.angle = -180 + Math.random() * 360;
        coin.node.setPosition(0, -360, 0);
    }

    private holderFor(index: number): { sprite: Sprite; fx: Sprite; strip: Strip } | null {
        const board = this.boards.get(this.boardKind);
        if (!board || index <= 0) {
            return null;
        }
        const col = (index - 1) % 5;
        const row = Math.floor((index - 1) / 5);
        let strip: Strip | undefined;
        let slot = row + 1;
        if (this.boardKind === 'normal') {
            strip = board.strips[col];
        } else if (this.boardKind === 'special') {
            strip = board.strips[index - 1];
            slot = 1;
        } else if (col === 0) {
            strip = board.strips[0];
        } else if (col === 4) {
            strip = board.strips[2];
        } else if (index === 8) {
            strip = board.strips[1];
            slot = 1;
        }
        if (!strip || !strip.sprites[slot] || !strip.fx[slot]) {
            return null;
        }
        return { sprite: strip.sprites[slot], fx: strip.fx[slot], strip };
    }

    private placeFx(sprite: Sprite, movie: string, strip: Strip, frame: SpriteFrame): void {
        const box = FX_BOX[movie];
        if (!box) {
            return;
        }
        const scaleX = strip.width / SYMBOL_W;
        const scaleY = strip.graphicH / SYMBOL_BOX_H;
        const width = box.w * scaleX;
        const height = box.h * scaleY;
        let left = box.x;
        let top = box.y;
        if (box.center) {
            left -= box.w / 2;
            top -= box.h / 2;
        }
        sprite.node.setPosition(left * scaleX + width / 2 - strip.width / 2, strip.graphicH / 2 - (top * scaleY + height / 2), 0);
        fitFrame(sprite, frame, width, height);
        sprite.node.active = true;
    }

    private iconsFor(kind: BoardKind, strip: Strip, grid: number[][]): number[] {
        if (kind === 'free' && strip.randomKind === 'free-mid') {
            return [grid[2]?.[1] ?? 8];
        }
        if (kind === 'special') {
            const row = Math.floor((strip.cellIndex - 1) / 5);
            return [grid[strip.column]?.[row] ?? 8];
        }
        return [0, 1, 2].map((row) => grid[strip.column]?.[row] ?? 8);
    }

    private restStrip(strip: Strip, icons: number[]): void {
        for (let i = 0; i < strip.sim.symbolNum; i += 1) {
            strip.sim.symbols[i + 1] = icons[i] ?? 8;
        }
        strip.sim.offset = 0;
        strip.sim.phase = 'none';
        this.layoutStrip(strip);
    }

    private layoutBoard(board: Board | undefined): void {
        board?.strips.forEach((strip) => this.layoutStrip(strip));
    }

    private layoutStrip(strip: Strip): void {
        strip.holders.forEach((holder, index) => {
            const fguiY = (index - 0.5) * strip.sim.symbolHeight + strip.sim.offset;
            holder.setPosition(0, strip.height / 2 - fguiY, 0);
            this.placeIcon(strip.sprites[index], strip.sim.symbols[index] ?? 8, strip.width, strip.graphicH);
        });
    }

    private placeIcon(sprite: Sprite, id: number, cellW: number, cellH: number): void {
        const box = SYMBOL_BOX[id] ?? SYMBOL_BOX[8];
        const scaleX = cellW / SYMBOL_W;
        const scaleY = cellH / SYMBOL_BOX_H;
        let left = box.x;
        let top = box.y;
        if (box.center) {
            left -= box.w / 2;
            top -= box.h / 2;
        }
        const width = box.w * scaleX;
        const height = box.h * scaleY;
        sprite.node.setPosition(left * scaleX + width / 2 - cellW / 2, cellH / 2 - (top * scaleY + height / 2), 0);
        const frame = this.art.get(SYMBOL_BOX[id] ? id : 8);
        if (frame) {
            fitSprite(sprite, frame, width, height);
        }
    }

    private showOnly(kind: BoardKind): void {
        this.boards.forEach((board) => {
            board.root.active = board.kind === kind;
        });
    }

    private rollIcon(kind: RandomKind): number {
        let pool = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        if (kind === 'free-left') {
            pool = [4, 5, 6, 7, 8, 9, 10, 11, 12];
        } else if (kind === 'free-right') {
            pool = [1, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        }
        return pool[Math.floor(Math.random() * pool.length)];
    }

    private stopEffects(): void {
        if (this.lineLayer) {
            this.lineLayer.active = false;
        }
        this.winLines = [];
        this.animCells.clear();
        this.plan = null;
        this.boards.forEach((board) => {
            board.strips.forEach((strip) => {
                strip.fx.forEach((sprite) => {
                    sprite.node.active = false;
                });
                strip.sprites.forEach((sprite) => {
                    sprite.node.active = true;
                });
            });
        });
        this.coins.forEach((coin) => {
            coin.alive = false;
            coin.node.active = false;
        });
        this.audio?.stop();
    }

    private changeBet(step: number): void {
        if (this.phase === 'spinning' || this.phase === 'presenting') {
            return;
        }
        this.betIndex = Math.max(0, Math.min(this.betChoices.length - 1, this.betIndex + step));
        this.refreshMoney();
    }

    private refreshMoney(): void {
        const bet = formatMoney(this.betChoices[this.betIndex] ?? 0);
        const win = formatMoney(Math.floor(this.winShown));
        const money = formatMoney(this.state.money);
        if (this.balance) {
            this.balance.string = money;
        }
        if (this.topBet) {
            this.topBet.string = bet;
        }
        if (this.topWin) {
            this.topWin.string = win;
        }
        if (this.betLabel) {
            this.betLabel.string = bet;
        }
        if (this.winLabel) {
            this.winLabel.string = win;
        }
        JACKPOTS.forEach((jackpot, index) => {
            const label = this.jackpotLabels[index];
            if (label) {
                const serverValue = this.jackpotValues[index];
                label.string = formatMoney(serverValue ?? (this.betChoices[this.betIndex] ?? 0) * jackpot.mult);
            }
        });
    }

    private paint(grid: number[][]): void {
        this.grid = grid.map((column) => column.slice());
        if (this.phase !== 'idle' && this.phase !== 'showcase') {
            return;
        }
        this.boardKind = 'normal';
        this.showOnly('normal');
        this.boards.get('normal')?.strips.forEach((strip) => {
            this.restStrip(strip, this.grid[strip.column] ?? [8, 8, 8]);
        });
    }

    private showRule(): void {
        if (this.phase === 'spinning' || this.phase === 'presenting') {
            return;
        }
        if (this.rule) {
            this.rulePage = (this.rulePage + 1) % 9;
            this.loadRulePage();
            return;
        }
        this.rulePage = 0;
        const node = new Node('rule');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(900, 460);
        node.setPosition(0, 20, 0);
        node.setParent(this.root);
        const sprite = node.addComponent(Sprite);
        sprite.sizeMode = Sprite.SizeMode.CUSTOM;
        sprite.trim = true;
        this.ruleSprite = sprite;
        this.rule = node;
        this.loadRulePage();
        bindClick(node, () => this.showRule());
        this.ruleClose = this.picture('game270/theme/fh', 1080, 120, 80, 64, () => this.closeRule());
    }

    private loadRulePage(): void {
        const page = this.rulePage + 1;
        loadSpriteFrame(`game270/art/slots_270_info_${page}`, (frame) => {
            if (frame && this.ruleSprite?.isValid) {
                fitSprite(this.ruleSprite, frame, 900, 460);
            }
        });
    }

    private closeRule(): void {
        this.rule?.destroy();
        this.ruleClose?.destroy();
        this.rule = null;
        this.ruleClose = null;
        this.ruleSprite = null;
    }

    private leave(): void {
        if (this.phase === 'spinning' || this.phase === 'presenting') {
            return;
        }
        this.stopTicker();
        this.busy = true;
        const session = this.session;
        const finish = () => {
            if (this.root.isValid) {
                this.root.destroy();
            }
            this.onExit();
        };
        if (!session) {
            finish();
            return;
        }
        void session.leave().finally(finish);
    }

    private stopTicker(): void {
        if (this.ticker !== null) {
            clearInterval(this.ticker);
            this.ticker = null;
        }
    }

    private picture(path: string, x: number, y: number, width: number, height: number, onClick?: () => void): Node {
        const node = new Node(path);
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(width, height);
        const center = fguiCenter(x, y, width, height);
        node.setPosition(center.x, center.y, 0);
        node.setParent(this.root);
        const sprite = node.addComponent(Sprite);
        sprite.sizeMode = Sprite.SizeMode.CUSTOM;
        sprite.type = Sprite.Type.SIMPLE;
        sprite.trim = true;
        loadSpriteFrame(path, (frame) => {
            if (frame && sprite.isValid) {
                fitSprite(sprite, frame, width, height);
            }
        });
        if (onClick) {
            bindClick(node, onClick);
        }
        return node;
    }

    private readout(x: number, y: number, width: number, height: number, fontId: string): BitmapReadout {
        const node = new Node('readout');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(width, height);
        const center = fguiCenter(x, y, width, height);
        node.setPosition(center.x, center.y, 0);
        node.setParent(this.root);
        return new BitmapReadout(node, fontId);
    }

    private play(name: string): void {
        const clip = this.clips.get(name);
        if (clip && this.audio) {
            this.audio.playOneShot(clip, 1);
        }
    }

    private playTune(name: string): void {
        const clip = this.clips.get(name);
        if (!clip || !this.audio) {
            return;
        }
        this.audio.stop();
        this.audio.clip = clip;
        this.audio.loop = false;
        this.audio.play();
    }
}

function visualFromStep(step: SpinStep, bet: number): SpinVisual {
    const lines: PayLine[] = step.lines.map((line) => ({
        lineIndex: line.lineIndex,
        cells: line.cells.map((cell) => ({ index: cell.index, icon: cell.icon })),
    }));
    const scatters = step.intoFree ? Math.max(3, countSymbol(step.columns, 2)) : countSymbol(step.columns, 2);
    return {
        kind: step.mode,
        grid: step.columns,
        win: step.win,
        bet,
        lines,
        scatters,
        note: step.note,
        jackpots: step.jackpots,
    };
}

function leadSound(lines: PayLine[]): string | null {
    for (const line of lines) {
        if (line.lineIndex <= 0 || line.lineIndex > 50) {
            continue;
        }
        if (line.cells.some((cell) => cell.icon === 1)) {
            return 'SND_Wild';
        }
        if (line.cells.length >= 4) {
            const icon = line.cells[0]?.icon ?? 0;
            if (icon >= 4 && icon <= 7) {
                return `SND_Pic${icon - 3}`;
            }
        }
    }
    return null;
}

function animMap(lines: PayLine[], grid: number[][], scatters: boolean): Map<number, number> {
    const cells = new Map<number, number>();
    lines.forEach((line) => {
        line.cells.forEach((cell) => {
            if (cell.index > 0) {
                cells.set(cell.index, cell.icon);
            }
        });
    });
    if (scatters) {
        grid.forEach((column, col) => {
            column.forEach((icon, row) => {
                if (icon === 2) {
                    cells.set(row * 5 + col + 1, 2);
                }
            });
        });
    }
    return cells;
}

function hexColor(hex: string): Color {
    const value = Number.parseInt(hex.slice(1), 16);
    return new Color((value >> 16) & 255, (value >> 8) & 255, value & 255, 255);
}

const fullFrames = new WeakMap<SpriteFrame, SpriteFrame>();

function fitSprite(sprite: Sprite, frame: SpriteFrame, width: number, height: number): void {
    sprite.sizeMode = Sprite.SizeMode.CUSTOM;
    sprite.trim = true;
    sprite.spriteFrame = fullFrame(frame);
    const transform = sprite.node.getComponent(UITransform);
    transform?.setAnchorPoint(0.5, 0.5);
    transform?.setContentSize(width, height);
}

function fitFrame(sprite: Sprite, frame: SpriteFrame, width: number, height: number): void {
    sprite.sizeMode = Sprite.SizeMode.CUSTOM;
    sprite.trim = false;
    sprite.spriteFrame = frame;
    const transform = sprite.node.getComponent(UITransform);
    transform?.setAnchorPoint(0.5, 0.5);
    transform?.setContentSize(width, height);
}

function fitNative(sprite: Sprite, frame: SpriteFrame, color: Color): void {
    const full = fullFrame(frame);
    sprite.sizeMode = Sprite.SizeMode.CUSTOM;
    sprite.trim = true;
    sprite.spriteFrame = full;
    sprite.color = color;
    const transform = sprite.node.getComponent(UITransform);
    transform?.setAnchorPoint(0.5, 0.5);
    transform?.setContentSize(full.originalSize.width, full.originalSize.height);
}

function fullFrame(frame: SpriteFrame): SpriteFrame {
    const cached = fullFrames.get(frame);
    if (cached) {
        return cached;
    }
    const texture = frame.texture;
    const texW = texture?.width || frame.originalSize.width;
    const texH = texture?.height || frame.originalSize.height;
    if (!texture || texW <= 0 || texH <= 0) {
        frame.packable = false;
        return frame;
    }
    const full = new SpriteFrame();
    full.reset({
        texture,
        rect: new Rect(0, 0, texW, texH),
        originalSize: new Size(texW, texH),
    });
    full.packable = false;
    fullFrames.set(frame, full);
    return full;
}

function sliceMovie(base: SpriteFrame, movie: MovieSheet): SpriteFrame[] {
    const texture = base.texture;
    if (!texture) {
        return [];
    }
    const frames: SpriteFrame[] = [];
    for (let i = 0; i < movie.count; i += 1) {
        const col = i % movie.columns;
        const row = Math.floor(i / movie.columns);
        const frame = new SpriteFrame();
        frame.reset({
            texture,
            rect: new Rect(col * movie.width, row * movie.height, movie.width, movie.height),
            originalSize: new Size(movie.width, movie.height),
        });
        frame.packable = false;
        frames.push(frame);
    }
    return frames;
}

function fguiCenter(x: number, y: number, width: number, height: number): { x: number; y: number } {
    return {
        x: x + width / 2 - SCREEN_W / 2,
        y: SCREEN_H / 2 - (y + height / 2),
    };
}

function countSymbol(grid: number[][], id: number): number {
    let count = 0;
    for (const column of grid) {
        for (const symbol of column) {
            if (symbol === id) {
                count += 1;
            }
        }
    }
    return count;
}
