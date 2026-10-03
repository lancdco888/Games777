import { BlockInputEvents, Color, Label, Layers, Mask, Node, Sprite, UITransform } from 'cc';
import { bindClick } from './CsbView';
import { Fish101Session, LOCAL_FISH_LEVELS, localRooms } from './Fish101';
import { Fish101Table } from './Fish101Table';
import { formatMoney, HallState } from './HallState';
import type { GosClient } from './GosClient';
import type { FishLevelInfo, FishRoomInfo, WirePacket } from './ServerPlay';

const SCREEN_W = 1280;
const SCREEN_H = 720;

/**
 * 大王乌贼: original level cards, room chairs, then the cannon table.
 * Enter, level, sit, and ReturnUp are lobby packets. Hits stay on the local coin table.
 */
export class Fish101View {
    private readonly root: Node;
    private readonly session: Fish101Session | null;
    private screen: Node | null = null;
    private table: Fish101Table | null = null;
    private level: (FishLevelInfo & { name: string }) | null = null;
    private rooms: FishRoomInfo[] = [];
    private roomPage = 0;
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
        this.root.addComponent(UITransform).setContentSize(SCREEN_W, SCREEN_H);
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
            this.showLevels(levels.map((level, index) => ({
                ...level,
                name: LOCAL_FISH_LEVELS[index]?.name ?? `等级 ${index + 1}`,
            })));
        } catch (error) {
            this.notify(error instanceof Error ? error.message : '进入捕鱼失败');
            void this.exit();
        }
    }

    private showLevels(levels: Array<FishLevelInfo & { name: string }>): void {
        this.clearScreen();
        const screen = this.screenNode();
        this.picture(screen, 'fish101/bg_1', 0, 0, SCREEN_W, SCREEN_H);
        this.caption(screen, '大王乌贼', 0, 280, 36);
        levels.forEach((level, index) => {
            const x = (index - (levels.length - 1) / 2) * 250;
            const card = (index % 4) + 1;
            this.picture(screen, `fish101/level_${card}`, x, 20, 200, 304, () => {
                void this.chooseLevel(level);
            });
            this.caption(screen, level.name, x, -170, 22);
            this.caption(screen, `炮 ${formatMoney(level.minBet)}-${formatMoney(level.maxBet)}`, x, -200, 18);
            this.caption(screen, level.minMoney > 0 ? `准入 ${formatMoney(level.minMoney)}` : '免费进入', x, -228, 18);
        });
        this.picture(screen, 'game270/theme/fh', -560, 300, 140, 46, () => {
            void this.exit();
        });
    }

    private async chooseLevel(level: FishLevelInfo & { name: string }): Promise<void> {
        if (this.choosing || this.table) {
            return;
        }
        if (this.state.money < level.minMoney) {
            this.notify(`需要 ${formatMoney(level.minMoney)} 金币才能进入`);
            return;
        }
        this.level = level;
        if (!this.session) {
            this.roomPage = 0;
            this.showRooms(localRooms(level.levelId));
            return;
        }
        this.choosing = true;
        try {
            const rooms = await this.session.openLevel(level);
            if (!this.root.isValid) {
                return;
            }
            this.roomPage = 0;
            this.showRooms(rooms);
        } catch (error) {
            this.notify(error instanceof Error ? error.message : '进入房间失败');
        } finally {
            this.choosing = false;
        }
    }

    private showRooms(rooms: FishRoomInfo[]): void {
        this.rooms = rooms;
        this.clearScreen();
        const screen = this.screenNode();
        this.picture(screen, 'fish101/room/bg', 0, 0, SCREEN_W, SCREEN_H);
        const room = rooms[Math.min(this.roomPage, rooms.length - 1)];
        if (!room) {
            this.caption(screen, '没有房间', 0, 0, 28);
        } else {
            this.picture(screen, 'fish101/room/table', 0, 10, 560, 350);
            this.caption(screen, `房间 ${room.roomId}`, 0, 250, 28);
            const chairs = [
                { x: -180, y: -150 },
                { x: 180, y: -150 },
                { x: -180, y: 170 },
                { x: 180, y: 170 },
            ];
            chairs.forEach((chair, index) => {
                const player = room.players[index] ?? null;
                if (player) {
                    this.picture(screen, 'fish101/room/chair_taken', chair.x, chair.y, 150, 170);
                    this.picture(screen, 'fish101/room/person', chair.x, chair.y + 20, 80, 160);
                    this.caption(screen, player.nickname || '玩家', chair.x, chair.y - 100, 18);
                } else {
                    const sitHere = () => {
                        void this.sit(room.roomId, index);
                    };
                    this.picture(screen, 'fish101/room/chair_empty', chair.x, chair.y, 140, 160, sitHere);
                    this.picture(screen, 'fish101/room/arrow', chair.x, chair.y + 110, 48, 76, sitHere);
                }
            });
        }
        if (rooms.length > 1) {
            this.picture(screen, 'fish101/room/arrow_l', -560, 0, 80, 90, () => {
                this.roomPage = (this.roomPage - 1 + rooms.length) % rooms.length;
                this.showRooms(rooms);
            });
            this.picture(screen, 'fish101/room/arrow_r', 560, 0, 80, 90, () => {
                this.roomPage = (this.roomPage + 1) % rooms.length;
                this.showRooms(rooms);
            });
        }
        this.picture(screen, 'game270/theme/fh', -560, 300, 140, 46, () => {
            void this.backFromRooms();
        });
    }

    private async sit(roomId: number, sitIndex: number): Promise<void> {
        if (this.choosing || !this.level) {
            return;
        }
        if (!this.session) {
            this.openTable({ roomId, sitIndex });
            return;
        }
        this.choosing = true;
        try {
            const seat = await this.session.sit(this.level, roomId, sitIndex);
            if (!this.root.isValid) {
                return;
            }
            this.openTable({ roomId: seat.roomId, sitIndex: seat.sitIndex });
        } catch (error) {
            this.notify(error instanceof Error ? error.message : '坐下失败');
        } finally {
            this.choosing = false;
        }
    }

    private openTable(seat: { roomId: number; sitIndex: number }): void {
        if (!this.level) {
            return;
        }
        this.clearScreen();
        this.table = new Fish101Table(this.root, this.state, this.level, seat, this.notify, () => {
            void this.backFromTable();
        });
    }

    private async backFromRooms(): Promise<void> {
        if (!this.session) {
            this.showLevels(LOCAL_FISH_LEVELS);
            return;
        }
        try {
            const packet = await this.session.stepBack();
            if (!this.root.isValid) {
                return;
            }
            this.applyBack(packet);
        } catch (error) {
            this.notify(error instanceof Error ? error.message : '返回失败');
            void this.exit();
        }
    }

    private async backFromTable(): Promise<void> {
        this.table?.destroy();
        this.table = null;
        if (!this.session) {
            this.showRooms(this.rooms);
            return;
        }
        try {
            const packet = await this.session.stepBack();
            if (!this.root.isValid) {
                return;
            }
            if (packet.kind === 'fishRooms') {
                this.showRooms(packet.rooms);
                return;
            }
            this.applyBack(packet);
        } catch (error) {
            this.notify(error instanceof Error ? error.message : '离开渔场失败');
            void this.exit();
        }
    }

    private applyBack(packet: WirePacket): void {
        if (packet.kind === 'fishLevels') {
            this.showLevels(packet.levels.map((level, index) => ({
                ...level,
                name: LOCAL_FISH_LEVELS[index]?.name ?? `等级 ${index + 1}`,
            })));
            return;
        }
        if (packet.kind === 'fishRooms') {
            this.showRooms(packet.rooms);
            return;
        }
        void this.exit();
    }

    private async exit(): Promise<void> {
        if (this.leaving) {
            return;
        }
        this.leaving = true;
        this.table?.destroy();
        this.table = null;
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

    private clearScreen(): void {
        this.screen?.destroy();
        this.screen = null;
        for (const child of [...this.root.children]) {
            if (child.name === 'caption') {
                child.destroy();
            }
        }
    }

    private screenNode(): Node {
        const screen = new Node('screen');
        screen.layer = Layers.Enum.UI_2D;
        screen.addComponent(UITransform).setContentSize(SCREEN_W, SCREEN_H);
        screen.setParent(this.root);
        this.screen = screen;
        return screen;
    }

    private picture(parent: Node, path: string, x: number, y: number, width: number, height: number, onClick?: () => void): Node {
        const node = new Node(path);
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(width, height);
        node.setPosition(x, y, 0);
        node.setParent(parent);
        const sprite = node.addComponent(Sprite);
        sprite.sizeMode = Sprite.SizeMode.CUSTOM;
        sprite.trim = false;
        loadSpriteFrame(path, (frame) => {
            if (frame && sprite.isValid) {
                node.getComponent(UITransform)?.setContentSize(width, height);
                sprite.spriteFrame = frame;
            }
        });
        if (onClick) {
            bindClick(node, onClick);
        }
        return node;
    }

    private caption(parent: Node, text: string, x: number, y: number, size: number): void {
        const node = new Node('caption');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(280, size + 8);
        node.setPosition(x, y, 0);
        node.setParent(parent);
        const label = node.addComponent(Label);
        label.string = text;
        label.fontSize = size;
        label.lineHeight = size + 4;
        label.color = new Color(255, 236, 180, 255);
    }
}
