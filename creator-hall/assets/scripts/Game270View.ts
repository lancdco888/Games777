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
    resources,
    Sprite,
    SpriteFrame,
    UITransform,
    VerticalTextAlignment,
} from 'cc';
import { bindClick, loadSpriteFrame } from './CsbView';
import { rollGrid, scoreGrid } from './Game270Rules';
import { formatMoney, HallState } from './HallState';

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
    private readonly jackpotLabels: Label[] = [];
    private balance: Label | null = null;
    private topBet: Label | null = null;
    private topWin: Label | null = null;
    private betLabel: Label | null = null;
    private winLabel: Label | null = null;
    private betIndex = 1;
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
        this.picture('game270/theme/ksan', 1072, 632, 203, 88, () => this.spin());

        this.balance = this.readout(291, 36, 168, 36, 26);
        this.topBet = this.readout(659 - 62, 36, 124, 36, 26);
        this.topWin = this.readout(966 - 120, 36, 240, 36, 26);
        this.betLabel = this.readout(231 - 70, 664, 140, 36, 24);
        this.winLabel = this.readout(648 - 150, 658, 300, 40, 28);
        JACKPOTS.forEach((jackpot) => {
            this.jackpotLabels.push(this.readout(jackpot.x - 90, 148, 180, 40, 26));
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
        const bet = BETS[this.betIndex];
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
        this.betIndex = Math.max(0, Math.min(BETS.length - 1, this.betIndex + step));
        this.refreshMoney();
    }

    private refreshMoney(): void {
        const bet = formatMoney(BETS[this.betIndex]);
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
                label.string = formatMoney(BETS[this.betIndex] * jackpot.mult);
            }
        });
    }

    private paint(grid: number[][]): void {
        this.grid = grid;
        for (let col = 0; col < 5; col += 1) {
            for (let row = 0; row < 3; row += 1) {
                const frame = this.art.get(grid[col][row]);
                if (frame) {
                    this.cells[col][row].spriteFrame = frame;
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
        sprite.trim = false;
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
                this.ruleSprite.spriteFrame = frame;
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
        this.root.destroy();
        this.onExit();
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
        sprite.trim = false;
        loadSpriteFrame(path, (frame) => {
            if (frame && sprite.isValid) {
                sprite.spriteFrame = frame;
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
        sprite.trim = false;
        return sprite;
    }

    private readout(x: number, y: number, width: number, height: number, size: number): Label {
        const node = new Node('readout');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(width, height);
        const center = fguiCenter(x, y, width, height);
        node.setPosition(center.x, center.y, 0);
        node.setParent(this.root);
        const label = node.addComponent(Label);
        label.fontSize = size;
        label.lineHeight = size + 4;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.verticalAlign = VerticalTextAlignment.CENTER;
        label.color = new Color(255, 236, 170, 255);
        return label;
    }

    private play(name: string): void {
        const clip = this.clips.get(name);
        if (clip && this.audio) {
            this.audio.playOneShot(clip, 1);
        }
    }
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
