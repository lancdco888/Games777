import {
    AudioClip,
    AudioSource,
    BlockInputEvents,
    Color,
    Graphics,
    HorizontalTextAlignment,
    Label,
    Layers,
    Node,
    resources,
    Sprite,
    SpriteFrame,
    UITransform,
    VerticalTextAlignment,
} from 'cc';
import { bindClick, loadSpriteFrame } from './CsbView';
import { rollGrid, scoreGrid, symbolById } from './Game270Rules';
import { formatMoney, HallState } from './HallState';

const BETS = [50, 100, 500, 1000];
const CELL_W = 148;
const CELL_H = 118;
const BOARD_Y = 28;

/** Cropped from FGame270/res/Game270/Game270.fui. Ids match SymbolConfig. */
const SYMBOL_ART: Record<number, string> = {
    1: 'game270/wild',
    2: 'game270/scatter',
    3: 'game270/lantern',
    4: 'game270/pic1',
    5: 'game270/pic2',
    6: 'game270/pic3',
    7: 'game270/pic4',
    8: 'game270/sl1',
    9: 'game270/sl2',
    10: 'game270/sl3',
    11: 'game270/sl4',
    12: 'game270/sl5',
};

/**
 * 财富之眼. Five reels, three rows, and the original 50 paylines.
 * Symbol, frame, and background art come from the Game270 FairyGUI package.
 * Wins are added to the hall balance.
 */
export class Game270View {
    private readonly root: Node;
    private readonly cells: Sprite[][] = [];
    private readonly captions: Label[][] = [];
    private readonly art = new Map<number, SpriteFrame>();
    private readonly clips = new Map<string, AudioClip>();
    private balance: Label | null = null;
    private result: Label | null = null;
    private betIndex = 1;
    private betLabel: Label | null = null;
    private spinning = false;
    private audio: AudioSource | null = null;
    private grid: number[][] = [];

    constructor(
        parent: Node,
        private readonly state: HallState,
        private readonly onExit: () => void,
        private readonly notify: (text: string) => void,
    ) {
        this.root = new Node('game270');
        this.root.layer = Layers.Enum.UI_2D;
        const transform = this.root.addComponent(UITransform);
        transform.setContentSize(1280, 720);
        this.root.setPosition(640, 360, 0);
        this.root.setParent(parent);
        this.root.addComponent(BlockInputEvents);
        const board = this.root.addComponent(Graphics);
        board.fillColor = new Color(8, 16, 12, 255);
        board.rect(-640, -360, 1280, 720);
        board.fill();
        this.audio = this.root.addComponent(AudioSource);
        this.build();
        this.preload();
        this.root.setSiblingIndex(parent.children.length - 1);
    }

    private build(): void {
        this.picture('game270/bg', 0, 0, 1280, 720);
        this.picture('game270/frame', 0, BOARD_Y, 836, 416);
        this.caption('财富之眼', 0, 312, 36);
        this.balance = this.caption(`金币 ${formatMoney(this.state.money)}`, -380, 312, 24);
        this.button('返回大厅', 470, 312, 180, 52, () => {
            if (this.spinning) {
                return;
            }
            this.root.destroy();
            this.onExit();
        });

        for (let col = 0; col < 5; col += 1) {
            this.cells[col] = [];
            this.captions[col] = [];
            for (let row = 0; row < 3; row += 1) {
                const x = (col - 2) * (CELL_W + 6);
                const y = BOARD_Y + (1 - row) * (CELL_H + 4);
                const cell = this.cell(x, y);
                this.cells[col][row] = cell.sprite;
                this.captions[col][row] = cell.caption;
            }
        }
        this.paint(rollGrid(() => 0.2));

        this.button('减注', -220, -286, 120, 56, () => this.changeBet(-1));
        this.betLabel = this.caption(this.betText(), 0, -286, 28);
        this.button('加注', 220, -286, 120, 56, () => this.changeBet(1));
        this.button('旋转', 0, -210, 220, 64, () => this.spin());
        this.result = this.caption('点击旋转', 0, -340, 24);
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
        const bet = BETS[this.betIndex];
        const paid = this.state.spend(bet);
        if (!paid.ok) {
            this.notify(paid.message);
            return;
        }
        this.spinning = true;
        this.refreshMoney();
        if (this.result) {
            this.result.string = '旋转中';
        }
        const finalGrid = rollGrid();
        let frame = 0;
        const timer = setInterval(() => {
            if (!this.root.isValid) {
                clearInterval(timer);
                return;
            }
            frame += 1;
            if (frame < 10) {
                this.paint(rollGrid());
                return;
            }
            const locked = Math.min(5, Math.floor((frame - 10) / 2) + 1);
            const shown = rollGrid();
            for (let col = 0; col < locked; col += 1) {
                shown[col] = finalGrid[col];
            }
            this.paint(shown);
            if (locked >= 5) {
                clearInterval(timer);
                const scored = scoreGrid(finalGrid, bet);
                this.state.award(scored.win);
                this.refreshMoney();
                if (this.result) {
                    this.result.string = scored.win > 0 ? `赢得 ${formatMoney(scored.win)}   ${scored.hits} 条线` : '未中奖';
                }
                this.play(scored.win > 0 ? 'win' : 'reelstop');
                if (countSymbol(finalGrid, 2) >= 3) {
                    this.play('scatter');
                }
                this.spinning = false;
            }
        }, 90);
    }

    private changeBet(step: number): void {
        if (this.spinning) {
            return;
        }
        this.betIndex = Math.max(0, Math.min(BETS.length - 1, this.betIndex + step));
        if (this.betLabel) {
            this.betLabel.string = this.betText();
        }
    }

    private betText(): string {
        return `押注 ${formatMoney(BETS[this.betIndex])}`;
    }

    private refreshMoney(): void {
        if (this.balance) {
            this.balance.string = `金币 ${formatMoney(this.state.money)}`;
        }
    }

    private paint(grid: number[][]): void {
        this.grid = grid;
        for (let col = 0; col < 5; col += 1) {
            for (let row = 0; row < 3; row += 1) {
                const id = grid[col][row];
                const sprite = this.cells[col][row];
                const art = this.art.get(id);
                if (art) {
                    sprite.spriteFrame = art;
                    this.captions[col][row].string = '';
                } else {
                    const symbol = symbolById(id);
                    this.captions[col][row].string = symbol.name;
                    this.captions[col][row].color = colorFrom(symbol.color);
                }
            }
        }
    }

    private picture(path: string, x: number, y: number, width: number, height: number): void {
        const node = new Node(path);
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(width, height);
        node.setPosition(x, y, 0);
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
    }

    private cell(x: number, y: number): { sprite: Sprite; caption: Label } {
        const node = new Node('cell');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(CELL_W, CELL_H);
        node.setPosition(x, y, 0);
        node.setParent(this.root);
        const sprite = node.addComponent(Sprite);
        sprite.sizeMode = Sprite.SizeMode.CUSTOM;
        sprite.type = Sprite.Type.SIMPLE;
        sprite.trim = false;
        const text = new Node('caption');
        text.layer = Layers.Enum.UI_2D;
        text.addComponent(UITransform).setContentSize(CELL_W, CELL_H);
        text.setParent(node);
        const label = text.addComponent(Label);
        label.fontSize = 28;
        label.lineHeight = 34;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.verticalAlign = VerticalTextAlignment.CENTER;
        label.color = new Color(255, 236, 190, 255);
        return { sprite, caption: label };
    }

    private caption(value: string, x: number, y: number, size: number): Label {
        const node = new Node('text');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(420, size + 16);
        node.setPosition(x, y, 0);
        node.setParent(this.root);
        const label = node.addComponent(Label);
        label.string = value;
        label.fontSize = size;
        label.lineHeight = size + 6;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.verticalAlign = VerticalTextAlignment.CENTER;
        label.color = new Color(255, 236, 190, 255);
        return label;
    }

    private button(value: string, x: number, y: number, width: number, height: number, handler: () => void): void {
        const node = new Node(value);
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(width, height);
        node.setPosition(x, y, 0);
        node.setParent(this.root);
        const graphics = node.addComponent(Graphics);
        graphics.fillColor = new Color(24, 78, 128, 255);
        graphics.roundRect(-width / 2, -height / 2, width, height, 12);
        graphics.fill();
        const text = new Node('caption');
        text.layer = Layers.Enum.UI_2D;
        text.addComponent(UITransform).setContentSize(width - 12, height);
        text.setParent(node);
        const label = text.addComponent(Label);
        label.string = value;
        label.fontSize = 24;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.verticalAlign = VerticalTextAlignment.CENTER;
        label.color = new Color(255, 244, 220, 255);
        bindClick(node, handler);
    }

    private play(name: string): void {
        const clip = this.clips.get(name);
        if (clip && this.audio) {
            this.audio.playOneShot(clip, 1);
        }
    }
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

function colorFrom(hex: string): Color {
    const value = hex.replace('#', '');
    return new Color(parseInt(value.slice(0, 2), 16), parseInt(value.slice(2, 4), 16), parseInt(value.slice(4, 6), 16), 255);
}
