import { BlockInputEvents, Color, Graphics, HorizontalTextAlignment, Label, Layers, Node, UITransform, VerticalTextAlignment } from 'cc';
import { bindClick } from './CsbView';
import { rollGrid, scoreGrid, symbolById } from './Game270Rules';
import { formatMoney, HallState } from './HallState';

const BETS = [50, 100, 500, 1000];
const CELL_W = 132;
const CELL_H = 118;

/**
 * 财富之眼. Five reels, three rows, and the original 50 paylines.
 * Wins are added to the hall balance.
 */
export class Game270View {
    private readonly root: Node;
    private readonly cells: Label[][] = [];
    private balance: Label | null = null;
    private result: Label | null = null;
    private betIndex = 1;
    private betLabel: Label | null = null;
    private spinning = false;

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
        board.fillColor = new Color(18, 10, 28, 255);
        board.rect(-640, -360, 1280, 720);
        board.fill();
        this.build();
        this.root.setSiblingIndex(parent.children.length - 1);
    }

    private build(): void {
        this.caption('财富之眼', 0, 300, 40);
        this.caption('270   50 线', 0, 252, 22);
        this.balance = this.caption(`金币 ${formatMoney(this.state.money)}`, -360, 300, 26);
        this.button('返回大厅', 460, 300, 180, 52, () => {
            if (this.spinning) {
                return;
            }
            this.root.destroy();
            this.onExit();
        });

        for (let col = 0; col < 5; col += 1) {
            this.cells[col] = [];
            for (let row = 0; row < 3; row += 1) {
                const x = (col - 2) * (CELL_W + 8);
                const y = (1 - row) * (CELL_H + 8);
                this.cells[col][row] = this.cell(x, y, 8);
            }
        }
        this.paint(rollGrid(() => 0.2));

        this.button('减注', -220, -280, 120, 56, () => this.changeBet(-1));
        this.betLabel = this.caption(this.betText(), 0, -280, 28);
        this.button('加注', 220, -280, 120, 56, () => this.changeBet(1));
        this.button('旋转', 0, -200, 220, 64, () => this.spin());
        this.result = this.caption('点击旋转', 0, -340, 24);
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
        for (let col = 0; col < 5; col += 1) {
            for (let row = 0; row < 3; row += 1) {
                const symbol = symbolById(grid[col][row]);
                const label = this.cells[col][row];
                label.string = symbol.name;
                label.color = colorFrom(symbol.color);
            }
        }
    }

    private cell(x: number, y: number, id: number): Label {
        const node = new Node('cell');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(CELL_W, CELL_H);
        node.setPosition(x, y, 0);
        node.setParent(this.root);
        const graphics = node.addComponent(Graphics);
        graphics.fillColor = new Color(36, 22, 48, 255);
        graphics.roundRect(-CELL_W / 2, -CELL_H / 2, CELL_W, CELL_H, 10);
        graphics.fill();
        const label = node.addComponent(Label);
        label.string = symbolById(id).name;
        label.fontSize = 32;
        label.lineHeight = 40;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.verticalAlign = VerticalTextAlignment.CENTER;
        label.color = new Color(255, 236, 190, 255);
        return label;
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
}

function colorFrom(hex: string): Color {
    const value = hex.replace('#', '');
    return new Color(parseInt(value.slice(0, 2), 16), parseInt(value.slice(2, 4), 16), parseInt(value.slice(4, 6), 16), 255);
}
