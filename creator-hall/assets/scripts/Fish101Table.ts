import { BlockInputEvents, Button, Color, Label, Layers, Mask, Node, Sprite, SpriteFrame, UITransform } from 'cc';
import { bindClick, loadSpriteFrame } from './CsbView';
import { FISH_KINDS, betSteps, coinAt, shotHits } from './Fish101';
import type { FishKind } from './Fish101Catalog';
import { formatMoney, HallState } from './HallState';
import type { FishLevelInfo } from './ServerPlay';

const SEATS = [
    { x: -320, y: -270, aim: 90 },
    { x: 320, y: -270, aim: 90 },
    { x: -320, y: 270, aim: -90 },
    { x: 320, y: 270, aim: -90 },
];

interface Swimmer {
    node: Node;
    sprite: Sprite;
    frames: Array<SpriteFrame | null>;
    frame: number;
    kind: FishKind;
    x: number;
    y: number;
    dir: number;
    coin: number;
}

interface Shot {
    node: Node;
    x: number;
    y: number;
    vx: number;
    vy: number;
}

interface Floater {
    node: Node;
    life: number;
}

/**
 * 大王乌贼 table drawn from the original cannon, fish, and HUD sheets.
 * Shots pay fish_info multiples on this device.
 */
export class Fish101Table {
    readonly node: Node;
    private readonly fishLayer: Node;
    private readonly cannon: Node;
    private readonly lockRing: Node;
    private readonly banner: Node;
    private readonly betNode: Node;
    private readonly moneyNode: Node;
    private readonly book: Node;
    private readonly fish: Swimmer[] = [];
    private readonly shots: Shot[] = [];
    private readonly floaters: Floater[] = [];
    private readonly steps: number[];
    private betIndex = 0;
    private cannonIndex = 0;
    private auto = false;
    private lock = false;
    private locked: Swimmer | null = null;
    private aim = 90;
    private fireWait = 0;
    private bossWait = 18;
    private specialWait = 12;
    private bannerLife = 0;
    private tipLife = 5;
    private timer = 0;
    private readonly seatIndex: number;
    private readonly originX: number;
    private readonly originY: number;
    private bookGroup: FishKind['group'] = 'general';
    private bookPage = 0;

    constructor(
        parent: Node,
        private readonly state: HallState,
        level: FishLevelInfo,
        seat: { roomId: number; sitIndex: number },
        private readonly notify: (text: string) => void,
        onLeave: () => void,
    ) {
        this.steps = betSteps(level.minBet, level.maxBet);
        this.seatIndex = Math.min(3, Math.max(0, seat.sitIndex));
        const place = SEATS[this.seatIndex];
        this.originX = place.x;
        this.originY = place.y + (place.aim > 0 ? 36 : -36);
        this.aim = place.aim;
        this.node = layerNode('table', parent, 1280, 720);
        this.picture(this.node, 'fish101/bg_1', 0, 0, 1280, 720);
        this.fishLayer = layerNode('fish', this.node, 1280, 720);
        this.spawnSchool();
        this.cannon = this.buildCannon(place.x, place.y, place.aim);
        this.lockRing = this.picture(this.fishLayer, 'fish101/ui/lock_ring', 0, 0, 90, 90);
        this.lockRing.active = false;
        const tip = this.picture(this.node, 'fish101/ui/your_seat', place.x, place.y + (place.aim > 0 ? 150 : -150), 160, 120);
        tip.name = 'seat-tip';
        this.banner = this.picture(this.node, 'fish101/ui/boss_banner', 0, 220, 460, 96);
        this.banner.active = false;
        this.caption(this.banner, '', 0, 0, 28);
        this.moneyNode = this.digits(this.node, -430, 320);
        this.betNode = this.digits(this.node, place.x, place.aim > 0 ? -332 : 332);
        this.picture(this.node, 'fish101/ui/coin_bg', place.x, place.aim > 0 ? -332 : 332, 170, 44);
        this.betNode.setSiblingIndex(this.node.children.length - 1);
        this.picture(this.node, 'fish101/ui/minus', place.x - 120, place.aim > 0 ? -332 : 332, 64, 64, () => this.stepBet(-1));
        this.picture(this.node, 'fish101/ui/plus', place.x + 120, place.aim > 0 ? -332 : 332, 64, 64, () => this.stepBet(1));
        this.picture(this.node, 'fish101/ui/auto', -90, -300, 76, 79, () => this.toggleAuto());
        this.picture(this.node, 'fish101/ui/lock', 0, -300, 76, 79, () => this.toggleLock());
        this.picture(this.node, 'fish101/ui/laser', 90, -300, 76, 79, () => this.fireLaser());
        this.picture(this.node, 'fish101/ui/tab_general', 470, 300, 180, 64, () => this.toggleBook());
        this.picture(this.node, 'game270/theme/fh', -560, 300, 140, 46, onLeave);
        this.caption(this.node, `房间 ${seat.roomId}`, 200, 320, 22);
        this.book = this.buildBook();
        this.refreshHud();
        this.node.on(Node.EventType.TOUCH_END, (event) => {
            const target = event.target as Node | null;
            if (targetHasButton(target)) {
                return;
            }
            const local = this.node.getComponent(UITransform)?.convertToNodeSpaceAR(event.getUILocation());
            if (local) {
                this.aimAt(local.x, local.y, true);
            }
        });
        this.timer = window.setInterval(() => this.tick(), 32);
    }

    destroy(): void {
        if (this.timer) {
            window.clearInterval(this.timer);
            this.timer = 0;
        }
        if (this.node.isValid) {
            this.node.destroy();
        }
    }

    private buildCannon(x: number, y: number, aim: number): Node {
        const base = this.picture(this.node, 'fish101/ui/base', x, y, 130, 140, () => this.cycleCannon());
        const cannon = this.picture(base, 'fish101/ui/pao_01', 0, 0, 120, 94, () => this.cycleCannon());
        cannon.getComponent(UITransform)?.setAnchorPoint(0.175, 0.5);
        cannon.angle = aim;
        return cannon;
    }

    private cycleCannon(): void {
        this.cannonIndex = (this.cannonIndex + 1) % 7;
        const sprite = this.cannon.getComponent(Sprite);
        loadSpriteFrame(`fish101/ui/pao_0${this.cannonIndex + 1}`, (frame) => {
            if (frame && sprite?.isValid) {
                sprite.spriteFrame = frame;
            }
        });
    }

    private spawnSchool(): void {
        FISH_KINDS.filter((kind) => kind.typeId <= 18).forEach((kind, index) => {
            this.spawn(kind, -640 + (index % 8) * 150, 180 - Math.floor(index / 8) * 120, index % 2 === 0 ? 1 : -1);
        });
    }

    private spawn(kind: FishKind, x: number, y: number, dir: number): Swimmer | null {
        if (this.fish.length >= 28) {
            return null;
        }
        const node = this.picture(this.fishLayer, `${kind.art}_0`, x, y, kind.width, kind.height);
        const sprite = node.getComponent(Sprite);
        if (!sprite) {
            return null;
        }
        const swimmer: Swimmer = {
            node,
            sprite,
            frames: new Array(kind.frames).fill(null),
            frame: 0,
            kind,
            x,
            y,
            dir,
            coin: coinAt(kind, Math.random()),
        };
        for (let index = 0; index < kind.frames; index += 1) {
            loadSpriteFrame(`${kind.art}_${index}`, (frame) => {
                swimmer.frames[index] = frame;
            });
        }
        node.angle = kind.upright ? 0 : dir > 0 ? 0 : 180;
        this.fish.push(swimmer);
        return swimmer;
    }

    private stepBet(delta: number): void {
        this.betIndex = (this.betIndex + delta + this.steps.length) % this.steps.length;
        this.refreshHud();
    }

    private toggleAuto(): void {
        this.auto = !this.auto;
        this.notify(this.auto ? '自动开炮' : '关闭自动开炮');
    }

    private toggleLock(): void {
        this.lock = !this.lock;
        this.locked = null;
        this.lockRing.active = false;
        this.notify(this.lock ? '锁定开炮' : '关闭锁定');
    }

    private toggleBook(): void {
        this.book.active = !this.book.active;
        if (this.book.active) {
            this.fillBook();
        }
    }

    private aimAt(x: number, y: number, shoot: boolean): void {
        const dx = x - this.originX;
        const dy = y - this.originY;
        if (Math.hypot(dx, dy) < 8) {
            return;
        }
        let angle = Math.atan2(dy, dx) * 180 / Math.PI;
        angle = clampAim(this.seatIndex < 2, angle);
        this.aim = angle;
        this.cannon.angle = angle;
        if (this.lock) {
            this.locked = nearest(this.fish, x, y, 120);
            this.lockRing.active = !!this.locked;
        }
        if (shoot) {
            this.fire(angle);
        }
    }

    private fire(angle: number): void {
        const paid = this.state.spend(this.steps[this.betIndex]);
        if (!paid.ok) {
            this.notify(paid.message);
            this.auto = false;
            return;
        }
        this.refreshHud();
        const rad = angle * Math.PI / 180;
        const shot = this.picture(this.fishLayer, `fish101/ui/zidan_0${this.cannonIndex + 1}`, this.originX, this.originY, 70, 28);
        shot.angle = angle;
        this.shots.push({
            node: shot,
            x: this.originX,
            y: this.originY,
            vx: Math.cos(rad) * 18,
            vy: Math.sin(rad) * 18,
        });
    }

    private fireLaser(): void {
        const paid = this.state.spend(this.steps[this.betIndex]);
        if (!paid.ok) {
            this.notify(paid.message);
            return;
        }
        const rad = this.aim * Math.PI / 180;
        const x2 = this.originX + Math.cos(rad) * 900;
        const y2 = this.originY + Math.sin(rad) * 900;
        const beam = this.picture(this.fishLayer, 'fish101/ui/zidan_01', (this.originX + x2) / 2, (this.originY + y2) / 2, 900, 10);
        beam.angle = this.aim;
        this.floaters.push({ node: beam, life: 0.12 });
        const hits = this.fish
            .map((fish) => ({ fish, distance: segmentDistance(fish.x, fish.y, this.originX, this.originY, x2, y2) }))
            .filter((item) => item.distance < 28 + Math.min(item.fish.kind.width, item.fish.kind.height) * 0.2)
            .sort((a, b) => a.distance - b.distance)
            .slice(0, 4);
        let total = 0;
        for (const hit of hits) {
            total += this.catchFish(hit.fish);
        }
        this.refreshHud();
        if (total > 0) {
            this.notify(`激光 ${formatMoney(total)}`);
        }
    }

    private catchFish(fish: Swimmer): number {
        const win = this.steps[this.betIndex] * fish.coin;
        this.state.award(win);
        this.burst(fish.x, fish.y, win);
        if (this.locked === fish) {
            this.locked = null;
            this.lockRing.active = false;
        }
        fish.x = fish.dir > 0 ? -760 : 760;
        fish.y = -140 + Math.random() * 320;
        fish.coin = coinAt(fish.kind, Math.random());
        return win;
    }

    private burst(x: number, y: number, win: number): void {
        const net = this.picture(this.fishLayer, 'fish101/ui/net', x, y, 120, 120);
        this.floaters.push({ node: net, life: 0.25 });
        const score = this.digits(this.fishLayer, x, y + 40);
        this.paintDigits(score, formatMoney(win));
        this.floaters.push({ node: score, life: 0.8 });
    }

    private tick(): void {
        if (!this.node.isValid) {
            this.destroy();
            return;
        }
        const step = 0.032;
        this.fireWait = Math.max(0, this.fireWait - step);
        this.bossWait -= step;
        this.specialWait -= step;
        this.bannerLife -= step;
        this.tipLife -= step;
        if (this.bannerLife <= 0) {
            this.banner.active = false;
        }
        const tip = this.node.getChildByName('seat-tip');
        if (tip) {
            tip.active = this.tipLife > 0;
        }
        if (this.bossWait <= 0) {
            this.bossWait = 26;
            const boss = FISH_KINDS.find((kind) => kind.boss && kind.typeId === (Math.random() < 0.5 ? 305 : 306));
            if (boss) {
                this.announce(boss);
                this.spawn(boss, -760, 40, 1);
                this.swapBackground(boss.typeId === 305 ? 2 : 3);
            }
        }
        if (this.specialWait <= 0) {
            this.specialWait = 14;
            const extra = FISH_KINDS.filter((kind) => kind.typeId >= 100 && !kind.boss);
            const kind = extra[Math.floor(Math.random() * extra.length)];
            if (kind) {
                this.spawn(kind, Math.random() < 0.5 ? -760 : 760, -80 + Math.random() * 220, Math.random() < 0.5 ? 1 : -1);
            }
        }
        for (const fish of this.fish) {
            fish.x += fish.dir * fish.kind.speed * step;
            if ((fish.dir > 0 && fish.x > 780) || (fish.dir < 0 && fish.x < -780)) {
                fish.dir *= -1;
                fish.x = Math.max(-760, Math.min(760, fish.x));
                if (!fish.kind.upright) {
                    fish.node.angle = fish.dir > 0 ? 0 : 180;
                }
            }
            fish.frame = (fish.frame + 1) % Math.max(1, fish.frames.length * 4);
            const frame = fish.frames[Math.floor(fish.frame / 4) % fish.frames.length];
            if (frame) {
                fish.sprite.spriteFrame = frame;
            }
            fish.node.setPosition(fish.x, fish.y, 0);
        }
        if (this.locked) {
            this.aimAt(this.locked.x, this.locked.y, false);
            this.lockRing.setPosition(this.locked.x, this.locked.y, 0);
            this.lockRing.setSiblingIndex(this.fishLayer.children.length - 1);
        }
        if ((this.auto || this.lock) && this.fireWait <= 0) {
            this.fireWait = 0.22;
            this.fire(this.aim);
        }
        const keep: Shot[] = [];
        for (const shot of this.shots) {
            shot.x += shot.vx;
            shot.y += shot.vy;
            shot.node.setPosition(shot.x, shot.y, 0);
            const hit = this.fish.find((fish) => shotHits(shot.x, shot.y, fish.x, fish.y, fish.kind.width, fish.kind.height));
            if (hit) {
                const win = this.catchFish(hit);
                this.notify(`打中${hit.kind.name} ${formatMoney(win)}`);
                shot.node.destroy();
                continue;
            }
            if (Math.abs(shot.x) > 760 || Math.abs(shot.y) > 420) {
                shot.node.destroy();
                continue;
            }
            keep.push(shot);
        }
        this.shots.length = 0;
        this.shots.push(...keep);
        for (let index = this.floaters.length - 1; index >= 0; index -= 1) {
            const floater = this.floaters[index];
            floater.life -= step;
            floater.node.setPosition(floater.node.position.x, floater.node.position.y + 40 * step, 0);
            if (floater.life <= 0) {
                floater.node.destroy();
                this.floaters.splice(index, 1);
            }
        }
    }

    private announce(kind: FishKind): void {
        this.banner.active = true;
        this.bannerLife = 2.4;
        const label = this.banner.getComponentInChildren(Label);
        if (label) {
            label.string = `${kind.name}来了`;
        }
        this.banner.setSiblingIndex(this.node.children.length - 1);
    }

    private swapBackground(index: number): void {
        const sprite = this.node.children[0]?.getComponent(Sprite);
        loadSpriteFrame(`fish101/bg_${index}`, (frame) => {
            if (frame && sprite?.isValid) {
                sprite.spriteFrame = frame;
            }
        });
    }

    private refreshHud(): void {
        this.paintDigits(this.moneyNode, formatMoney(this.state.money));
        this.paintDigits(this.betNode, formatMoney(this.steps[this.betIndex]));
    }

    private buildBook(): Node {
        const book = layerNode('book', this.node, 1280, 720);
        book.active = false;
        const panel = layerNode('panel', book, 980, 560);
        panel.addComponent(Mask).type = Mask.Type.GRAPHICS_RECT;
        this.picture(panel, 'fish101/room/bg', 0, 0, 980, 560);
        this.picture(panel, 'fish101/ui/tab_general', -240, 220, 200, 70, () => this.showGroup('general'));
        this.picture(panel, 'fish101/ui/tab_golden', 0, 220, 200, 70, () => this.showGroup('golden'));
        this.picture(panel, 'fish101/ui/tab_special', 240, 220, 200, 70, () => this.showGroup('special'));
        this.picture(panel, 'game270/theme/fh', 400, 220, 120, 40, () => {
            book.active = false;
        });
        layerNode('grid', panel, 900, 400).setPosition(0, -40, 0);
        book.addComponent(BlockInputEvents);
        return book;
    }

    private showGroup(group: FishKind['group']): void {
        this.bookGroup = group;
        this.bookPage = 0;
        this.fillBook();
    }

    private fillBook(): void {
        const grid = this.book.getChildByName('panel')?.getChildByName('grid');
        if (!grid) {
            return;
        }
        grid.removeAllChildren();
        const kinds = FISH_KINDS.filter((kind) => kind.group === this.bookGroup);
        const page = kinds.slice(this.bookPage * 8, this.bookPage * 8 + 8);
        page.forEach((kind, index) => {
            const column = index % 4;
            const row = Math.floor(index / 4);
            const x = -330 + column * 220;
            const y = 80 - row * 180;
            this.picture(grid, `${kind.art}_0`, x, y + 30, Math.min(kind.width, 120), Math.min(kind.height, 90));
            const range = kind.coinList.length > 0
                ? `${formatMoney(kind.coinList[0])}-${formatMoney(kind.coinList[kind.coinList.length - 1])}`
                : kind.coinMin === kind.coinMax
                    ? `${kind.coinMin}倍`
                    : `${kind.coinMin}-${kind.coinMax}倍`;
            this.caption(grid, `${kind.name}  ${range}`, x, y - 50, 18);
        });
        if (kinds.length > 8) {
            this.picture(grid, 'fish101/room/arrow_l', -430, -160, 64, 72, () => {
                this.bookPage = Math.max(0, this.bookPage - 1);
                this.fillBook();
            });
            this.picture(grid, 'fish101/room/arrow_r', 430, -160, 64, 72, () => {
                if ((this.bookPage + 1) * 8 < kinds.length) {
                    this.bookPage += 1;
                    this.fillBook();
                }
            });
        }
    }

    private digits(parent: Node, x: number, y: number): Node {
        const node = layerNode('digits', parent, 220, 32);
        node.setPosition(x, y, 0);
        return node;
    }

    private paintDigits(node: Node, text: string): void {
        node.removeAllChildren();
        const chars = [...text].filter((char) => /[0-9,]/.test(char));
        const gap = 16;
        const origin = -((chars.length - 1) * gap) / 2;
        chars.forEach((char, index) => {
            const key = char === ',' ? 'd' : char;
            const digit = this.picture(node, `fish101/ui/no1_${key}`, origin + index * gap, 0, key === 'd' ? 10 : 16, key === 'd' ? 12 : 22);
            digit.name = 'digit';
        });
    }

    private picture(parent: Node, path: string, x: number, y: number, width: number, height: number, onClick?: () => void): Node {
        const node = layerNode(path, parent, width, height);
        node.setPosition(x, y, 0);
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

    private caption(parent: Node, text: string, x: number, y: number, size: number): void {
        const node = layerNode('caption', parent, 420, size + 8);
        node.setPosition(x, y, 0);
        const label = node.addComponent(Label);
        label.string = text;
        label.fontSize = size;
        label.lineHeight = size + 4;
        label.color = new Color(255, 236, 180, 255);
    }
}

function nearest(fish: Swimmer[], x: number, y: number, limit: number): Swimmer | null {
    let best: Swimmer | null = null;
    let bestDistance = limit * limit;
    for (const item of fish) {
        const dx = item.x - x;
        const dy = item.y - y;
        const distance = dx * dx + dy * dy;
        if (distance < bestDistance) {
            best = item;
            bestDistance = distance;
        }
    }
    return best;
}

function clampAim(bottom: boolean, angle: number): number {
    if (bottom) {
        if (angle < -90) {
            return 180;
        }
        if (angle < 0) {
            return 0;
        }
        return angle;
    }
    if (angle > 90) {
        return 180;
    }
    if (angle > 0) {
        return 360;
    }
    return angle;
}

function segmentDistance(px: number, py: number, x1: number, y1: number, x2: number, y2: number): number {
    const dx = x2 - x1;
    const dy = y2 - y1;
    const length = dx * dx + dy * dy || 1;
    const t = Math.max(0, Math.min(1, ((px - x1) * dx + (py - y1) * dy) / length));
    return Math.hypot(px - (x1 + t * dx), py - (y1 + t * dy));
}

function targetHasButton(node: Node | null): boolean {
    let current = node;
    while (current) {
        if (current.getComponent(Button)) {
            return true;
        }
        current = current.parent;
    }
    return false;
}

function layerNode(name: string, parent: Node, width: number, height: number): Node {
    const node = new Node(name);
    node.layer = Layers.Enum.UI_2D;
    node.addComponent(UITransform).setContentSize(width, height);
    node.setParent(parent);
    return node;
}
