import {
    AudioClip,
    AudioSource,
    BlockInputEvents,
    Layers,
    Mask,
    Node,
    Rect,
    resources,
    Size,
    Sprite,
    SpriteFrame,
    UITransform,
} from 'cc';
import { bindClick, BitmapReadout, loadSpriteFrame } from './CsbView';
import { rollGrid, scoreGrid } from './Game270Rules';
import { formatMoney, HallState } from './HallState';
import type { GosClient } from './GosClient';
import { Slot270Session } from './Slot270';
import type { SpinStep } from './Slot270';

const BETS = [50, 100, 500, 1000];
const SCREEN_W = 1280;
const SCREEN_H = 720;

/** Reel geometry from FGame270 Reel.lua and the Slot component. */
const SLOT_TOP = 22;
const REEL_X = 216;
const REEL_Y = SLOT_TOP + 201;
const REEL_W = 165;
const REEL_GAP = 5;
const SYMBOL_H = 415 / 3;

/** Opening board from ConstCfg.InitUIBox. Row 0 is the top row. */
const OPENING = [
    [6, 12, 9],
    [10, 5, 8],
    [10, 6, 9],
    [11, 6, 7],
    [9, 2, 8],
];

/** Static symbol pictures inside the Symbol component, not the win animation. */
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

/** Symbol component is 165x137. Each icon uses the child box from that component. */
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

/**
 * 财富之眼 laid out from the original FairyGUI Game, Slot, and Lilac bars.
 * Wins are added to the hall balance.
 */
export class Game270View {
    private readonly root: Node;
    private readonly cells: Sprite[][] = [];
    private readonly art = new Map<number, SpriteFrame>();
    private readonly clips = new Map<string, AudioClip>();
    private readonly jackpotLabels: BitmapReadout[] = [];
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
    private spinning = false;
    private winAmount = 0;
    private audio: AudioSource | null = null;
    private grid: number[][] = [];
    private rule: Node | null = null;
    private ruleClose: Node | null = null;
    private rulePage = 0;
    private ruleSprite: Sprite | null = null;

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

        for (let col = 0; col < 5; col += 1) {
            this.cells[col] = [];
            for (let row = 0; row < 3; row += 1) {
                const x = REEL_X + col * (REEL_W + REEL_GAP);
                const y = REEL_Y + row * SYMBOL_H;
                this.cells[col][row] = this.cell(x, y);
            }
        }
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

    private preload(): void {
        Object.keys(SYMBOL_ART).forEach((key) => {
            const id = Number(key);
            loadSpriteFrame(SYMBOL_ART[id], (frame) => {
                if (!frame || !this.root.isValid) {
                    return;
                }
                this.art.set(id, frame);
                if (this.grid.length) {
                    this.paint(this.grid);
                }
            });
        });
        ['reelstop', 'win', 'scatter'].forEach((name) => {
            resources.load(`game270/audio/${name}`, AudioClip, (err, clip) => {
                if (!err && clip) {
                    this.clips.set(name, clip);
                }
            });
        });
    }

    private spin(): void {
        if (this.spinning) {
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
        this.spinning = true;
        this.winAmount = 0;
        this.refreshMoney();
        const finalGrid = rollGrid();
        let frame = 0;
        const timer = setInterval(() => {
            if (!this.root.isValid) {
                clearInterval(timer);
                return;
            }
            frame += 1;
            if (frame < 12) {
                this.paint(rollGrid());
                return;
            }
            const locked = Math.min(5, Math.floor((frame - 12) / 3) + 1);
            const shown = rollGrid();
            for (let col = 0; col < locked; col += 1) {
                shown[col] = finalGrid[col];
            }
            this.paint(shown);
            if (locked >= 5) {
                clearInterval(timer);
                const scored = scoreGrid(finalGrid, bet);
                this.winAmount = scored.win;
                this.state.award(scored.win);
                this.refreshMoney();
                this.play(scored.win > 0 ? 'win' : 'reelstop');
                if (countSymbol(finalGrid, 2) >= 3) {
                    this.play('scatter');
                }
                this.spinning = false;
            }
        }, 80);
    }

    private changeBet(step: number): void {
        if (this.spinning) {
            return;
        }
        this.betIndex = Math.max(0, Math.min(this.betChoices.length - 1, this.betIndex + step));
        this.refreshMoney();
    }

    private refreshMoney(): void {
        const bet = formatMoney(this.betChoices[this.betIndex] ?? 0);
        const win = formatMoney(this.winAmount);
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
        this.grid = grid;
        const scaleX = REEL_W / SYMBOL_W;
        const scaleY = SYMBOL_H / SYMBOL_BOX_H;
        for (let col = 0; col < 5; col += 1) {
            for (let row = 0; row < 3; row += 1) {
                const raw = grid[col]?.[row] ?? 8;
                const id = SYMBOL_BOX[raw] ? raw : 8;
                const box = SYMBOL_BOX[id];
                let left = box.x;
                let top = box.y;
                if (box.center) {
                    left -= box.w / 2;
                    top -= box.h / 2;
                }
                const width = box.w * scaleX;
                const height = box.h * scaleY;
                const x = REEL_X + col * (REEL_W + REEL_GAP) + left * scaleX;
                const y = REEL_Y + row * SYMBOL_H + top * scaleY;
                const sprite = this.cells[col][row];
                const center = fguiCenter(x, y, width, height);
                sprite.node.setPosition(center.x, center.y, 0);
                const frame = this.art.get(id);
                if (frame) {
                    fitSprite(sprite, frame, width, height);
                }
            }
        }
    }

    private showRule(): void {
        if (this.spinning) {
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
        if (this.spinning) {
            return;
        }
        this.spinning = true;
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

    private async spinOnServer(): Promise<void> {
        const session = this.session;
        if (!session) {
            this.notify('还没有连上 270 服务器');
            return;
        }
        if (this.enterError) {
            this.notify(this.enterError);
            return;
        }
        const bet = this.betChoices[this.betIndex] ?? 0;
        this.spinning = true;
        try {
            await this.ready;
        } catch {
            this.spinning = false;
            return;
        }
        if (this.enterError || !this.root.isValid) {
            this.spinning = false;
            return;
        }
        this.winAmount = 0;
        this.refreshMoney();
        let steps: SpinStep[] = [];
        try {
            steps = await session.spin(bet);
        } catch (error) {
            this.spinning = false;
            this.notify(error instanceof Error ? error.message : '开奖失败');
            return;
        }
        if (!this.root.isValid) {
            return;
        }
        for (let index = 0; index < steps.length; index += 1) {
            const step = steps[index];
            await this.rollTo(step.columns, index === 0 ? 12 : 6);
            if (!this.root.isValid) {
                return;
            }
            this.winAmount = step.win;
            this.jackpotValues = step.jackpots;
            this.refreshMoney();
            this.play(step.win > 0 ? 'win' : 'reelstop');
            if (countSymbol(step.columns, 2) >= 3) {
                this.play('scatter');
            }
            if (step.note) {
                this.notify(step.note);
            }
        }
        this.spinning = false;
    }

    private rollTo(finalGrid: number[][], frames: number): Promise<void> {
        return new Promise((resolve) => {
            let frame = 0;
            const timer = setInterval(() => {
                if (!this.root.isValid) {
                    clearInterval(timer);
                    resolve();
                    return;
                }
                frame += 1;
                if (frame < frames) {
                    this.paint(rollGrid());
                    return;
                }
                const locked = Math.min(5, Math.floor((frame - frames) / 2) + 1);
                const shown = rollGrid();
                for (let col = 0; col < locked; col += 1) {
                    shown[col] = finalGrid[col];
                }
                this.paint(shown);
                if (locked >= 5) {
                    clearInterval(timer);
                    resolve();
                }
            }, 70);
        });
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

    private cell(x: number, y: number): Sprite {
        const node = new Node('cell');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(REEL_W - 4, SYMBOL_H - 4);
        const center = fguiCenter(x + 2, y + 2, REEL_W - 4, SYMBOL_H - 4);
        node.setPosition(center.x, center.y, 0);
        node.setParent(this.root);
        const sprite = node.addComponent(Sprite);
        sprite.sizeMode = Sprite.SizeMode.CUSTOM;
        sprite.type = Sprite.Type.SIMPLE;
        sprite.trim = true;
        return sprite;
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
}

/** Draw the whole exported picture inside the node box, including its transparent margin. */
const fullFrames = new WeakMap<SpriteFrame, SpriteFrame>();

function fitSprite(sprite: Sprite, frame: SpriteFrame, width: number, height: number): void {
    sprite.sizeMode = Sprite.SizeMode.CUSTOM;
    sprite.trim = true;
    sprite.spriteFrame = fullFrame(frame);
    const transform = sprite.node.getComponent(UITransform);
    transform?.setAnchorPoint(0.5, 0.5);
    transform?.setContentSize(width, height);
}

/** Keep the whole exported picture, including its transparent margin. */
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
