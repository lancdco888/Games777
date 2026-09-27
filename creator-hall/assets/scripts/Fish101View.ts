import { BlockInputEvents, Button, Color, Label, Layers, Mask, Node, Sprite, UITransform } from 'cc';
import { bindClick, loadSpriteFrame, mountBitmap, setBitmapText } from './CsbView';
import { FISH_KINDS, Fish101Session, LOCAL_FISH_LEVELS, shotHits } from './Fish101';
import type { FishTableSeat } from './Fish101';
import { formatMoney, HallState } from './HallState';
import type { GosClient } from './GosClient';
import type { FishLevelInfo } from './ServerPlay';

const SCREEN_W = 1280;
const SCREEN_H = 720;

interface Swimmer {
    node: Node;
    coin: number;
    x: number;
    y: number;
    speed: number;
    width: number;
    height: number;
}

interface Shot {
    node: Node;
    x: number;
    y: number;
    vx: number;
    vy: number;
}

/**
 * 大王乌贼 table. Server login sits through the lobby packets.
 * Hits pay the fish_info coin multiple on this device.
 */
export class Fish101View {
    private readonly root: Node;
    private readonly session: Fish101Session | null;
    private menu: Node | null = null;
    private table: Node | null = null;
    private moneyNode: Node | null = null;
    private betNode: Node | null = null;
    private cannon: Node | null = null;
    private fish: Swimmer[] = [];
    private shots: Shot[] = [];
    private bet = 10;
    private timer = 0;
    private leaving = false;
    private choosing = false;

    constructor(
        parent: Node,
        private readonly state: HallState,
        private readonly onExit: () => void,
        private readonly notify: (text: string) => void,
        server: GosClient | null,
    ) {
        this.root = new Node('fish101');
        this.root.layer = Layers.Enum.UI_2D;
        const transform = this.root.addComponent(UITransform);
        transform.setContentSize(SCREEN_W, SCREEN_H);
        this.root.setPosition(640, 360, 0);
        this.root.setParent(parent);
        this.root.addComponent(BlockInputEvents);
        const mask = this.root.addComponent(Mask);
        mask.type = Mask.Type.GRAPHICS_RECT;
        this.root.setSiblingIndex(parent.children.length - 1);
        this.session = server ? new Fish101Session(server) : null;
        if (this.session) {
            this.caption(this.root, '正在读取捕鱼等级', 0, 0, 28);
            void this.loadServerLevels();
        } else {
            this.showLevels(LOCAL_FISH_LEVELS);
        }
    }

    private async loadServerLevels(): Promise<void> {
        try {
            const levels = await this.session?.levels();
            if (!levels || !this.root.isValid) {
                return;
            }
            this.showLevels(levels.map((level, index) => ({ ...level, name: levelName(index) })));
        } catch (error) {
            this.notify(error instanceof Error ? error.message : '进入捕鱼失败');
            void this.exit();
        }
    }

    private showLevels(levels: Array<FishLevelInfo & { name: string }>): void {
        this.menu?.destroy();
        for (const child of [...this.root.children]) {
            if (child.name === 'caption') {
                child.destroy();
            }
        }
        const menu = new Node('levels');
        menu.layer = Layers.Enum.UI_2D;
        menu.addComponent(UITransform).setContentSize(SCREEN_W, SCREEN_H);
        menu.setParent(this.root);
        this.menu = menu;
        this.pictureOn(menu, 'fish101/bg', 0, 0, SCREEN_W, SCREEN_H);
        this.caption(menu, '大王乌贼', 0, 250, 42);
        levels.forEach((level, index) => {
            const column = index % 2;
            const row = Math.floor(index / 2);
            const x = column === 0 ? -220 : 220;
            const y = 80 - row * 150;
            this.levelButton(menu, level, x, y);
        });
        this.pictureOn(menu, 'game270/theme/fh', -560, 300, 140, 46, () => {
            void this.exit();
        });
    }

    private levelButton(parent: Node, level: FishLevelInfo & { name: string }, x: number, y: number): void {
        const node = new Node(level.name);
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(380, 120);
        node.setPosition(x, y, 0);
        node.setParent(parent);
        this.pictureOn(node, 'fish101/base', 0, 8, 120, 90);
        this.caption(node, `${level.name}  炮 ${formatMoney(level.minBet)}-${formatMoney(level.maxBet)}`, 0, -70, 22);
        bindClick(node, () => {
            void this.choose(level);
        });
    }

    private async choose(level: FishLevelInfo): Promise<void> {
        if (this.choosing || this.table) {
            return;
        }
        if (this.state.money < level.minMoney) {
            this.notify(`需要 ${formatMoney(level.minMoney)} 金币才能进入`);
            return;
        }
        if (this.session) {
            this.choosing = true;
            try {
                const seat = await this.session.sit(level);
                if (!this.root.isValid) {
                    return;
                }
                this.openTable(level, seat);
            } catch (error) {
                this.choosing = false;
                this.notify(error instanceof Error ? error.message : '坐下失败');
            }
            return;
        }
        this.openTable(level, null);
    }

    private openTable(level: FishLevelInfo, seat: FishTableSeat | null): void {
        this.menu?.destroy();
        this.menu = null;
        this.bet = Math.max(1, level.minBet);
        const table = new Node('table');
        table.layer = Layers.Enum.UI_2D;
        table.addComponent(UITransform).setContentSize(SCREEN_W, SCREEN_H);
        table.setParent(this.root);
        this.table = table;
        this.pictureOn(table, 'fish101/bg', 0, 0, SCREEN_W, SCREEN_H);
        this.pictureOn(table, 'game270/theme/fh', -560, 300, 140, 46, () => {
            void this.exit();
        });
        this.moneyNode = this.number(table, -360, 310, 220, 32);
        this.betNode = this.number(table, 80, -310, 180, 32);
        this.caption(table, seat ? `房间 ${seat.roomId}` : '本地体验', 420, 310, 22);
        this.caption(table, '点击水面开炮', 0, 310, 22);
        const base = this.pictureOn(table, 'fish101/base', 0, -250, 130, 140);
        this.cannon = this.pictureOn(base, 'fish101/cannon', 0, 70, 120, 94);
        // pao_01.png faces +X. The original pivots at the breech and starts aimed up.
        this.cannon.getComponent(UITransform)?.setAnchorPoint(0.175, 0.5);
        this.cannon.angle = 90;
        this.spawnSchool();
        const overlay = table.children.filter((child) => child.name !== 'fish101/bg' && !this.fish.some((fish) => fish.node === child));
        for (const node of overlay) {
            node.setSiblingIndex(table.children.length - 1);
        }
        this.refreshHud();
        table.on(Node.EventType.TOUCH_END, (event) => {
            const target = event.target as Node | null;
            if (target?.getComponent(Button)) {
                return;
            }
            const point = event.getUILocation();
            const local = table.getComponent(UITransform)?.convertToNodeSpaceAR(point);
            if (local) {
                this.fire(local.x, local.y);
            }
        });
        this.timer = window.setInterval(() => this.tick(), 32);
    }

    private spawnSchool(): void {
        const table = this.table;
        if (!table) {
            return;
        }
        FISH_KINDS.forEach((kind, index) => {
            const node = this.pictureOn(table, kind.art, -400 + index * 40, 180 - index * 70, kind.width, kind.height);
            this.fish.push({
                node,
                coin: kind.coin,
                x: -520 + index * 180,
                y: 200 - (index % 4) * 90,
                speed: kind.coin >= 250 ? 70 : 120 + index * 25,
                width: kind.width,
                height: kind.height,
            });
            node.setPosition(this.fish[index].x, this.fish[index].y, 0);
        });
    }

    private fire(x: number, y: number): void {
        if (!this.table || !this.cannon || y < -220) {
            return;
        }
        const paid = this.state.spend(this.bet);
        if (!paid.ok) {
            this.notify(paid.message);
            return;
        }
        this.refreshHud();
        const originX = 0;
        const originY = -180;
        const dx = x - originX;
        const dy = y - originY;
        const length = Math.hypot(dx, dy) || 1;
        const angle = Math.atan2(dy, dx) * 180 / Math.PI;
        this.cannon.angle = angle;
        const shot = this.pictureOn(this.table, 'fish101/bullet', originX, originY, 70, 22);
        shot.angle = angle;
        this.shots.push({
            node: shot,
            x: originX,
            y: originY,
            vx: dx / length * 18,
            vy: dy / length * 18,
        });
    }

    private tick(): void {
        if (!this.root.isValid) {
            this.stop();
            return;
        }
        for (const fish of this.fish) {
            fish.x += fish.speed * 0.032;
            if (fish.x > 700) {
                fish.x = -700;
                fish.y = -80 + Math.random() * 280;
            }
            fish.node.setPosition(fish.x, fish.y, 0);
        }
        const keep: Shot[] = [];
        for (const shot of this.shots) {
            shot.x += shot.vx;
            shot.y += shot.vy;
            shot.node.setPosition(shot.x, shot.y, 0);
            const hit = this.fish.find((fish) => shotHits(shot.x, shot.y, fish.x, fish.y, fish.width, fish.height));
            if (hit) {
                const win = this.bet * hit.coin;
                this.state.award(win);
                this.refreshHud();
                this.notify(`打中 ${formatMoney(win)}`);
                hit.x = -700;
                hit.y = -80 + Math.random() * 280;
                shot.node.destroy();
                continue;
            }
            if (shot.y > 400 || Math.abs(shot.x) > 700) {
                shot.node.destroy();
                continue;
            }
            keep.push(shot);
        }
        this.shots = keep;
    }

    private refreshHud(): void {
        setBitmapText(this.moneyNode, formatMoney(this.state.money));
        setBitmapText(this.betNode, formatMoney(this.bet));
    }

    private number(parent: Node, x: number, y: number, width: number, height: number): Node {
        const node = new Node('num');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(width, height);
        node.setPosition(x, y, 0);
        node.setParent(parent);
        mountBitmap(node, 'coin', '');
        return node;
    }

    private caption(parent: Node, text: string, x: number, y: number, size: number): void {
        const node = new Node('caption');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(520, size + 8);
        node.setPosition(x, y, 0);
        node.setParent(parent);
        const label = node.addComponent(Label);
        label.string = text;
        label.fontSize = size;
        label.lineHeight = size + 4;
        label.color = new Color(255, 236, 180, 255);
    }

    private pictureOn(parent: Node, path: string, x: number, y: number, width: number, height: number, onClick?: () => void): Node {
        const node = new Node(path);
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(width, height);
        node.setPosition(x, y, 0);
        node.setParent(parent);
        const sprite = node.addComponent(Sprite);
        sprite.sizeMode = Sprite.SizeMode.CUSTOM;
        sprite.type = Sprite.Type.SIMPLE;
        sprite.trim = false;
        loadSpriteFrame(path, (frame) => {
            if (frame && sprite.isValid) {
                sprite.spriteFrame = frame;
                node.getComponent(UITransform)?.setContentSize(width, height);
            }
        });
        if (onClick) {
            bindClick(node, onClick);
        }
        return node;
    }

    private async exit(): Promise<void> {
        if (this.leaving) {
            return;
        }
        this.leaving = true;
        this.stop();
        try {
            await this.session?.leave();
        } catch {
            // The lobby return is best-effort after the table closes.
        }
        if (this.root.isValid) {
            this.root.destroy();
        }
        this.onExit();
    }

    private stop(): void {
        if (this.timer) {
            window.clearInterval(this.timer);
            this.timer = 0;
        }
    }
}

function levelName(index: number): string {
    return LOCAL_FISH_LEVELS[index]?.name ?? `等级 ${index + 1}`;
}
