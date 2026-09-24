import {
    _decorator,
    Color,
    Component,
    Graphics,
    HorizontalTextAlignment,
    JsonAsset,
    Label,
    Layers,
    Mask,
    Node,
    Overflow,
    resources,
    ScrollView,
    UITransform,
    VerticalTextAlignment,
} from 'cc';
import { CsbNode, mountCsb } from './CsbView';

const { ccclass } = _decorator;

interface GameEntry {
    id: number;
    name: string;
}

interface SampleLobby {
    nickname: string;
    vipLevel: number;
    money: string;
    moneySafe: string;
    washCode: string;
    url: string;
    games: GameEntry[];
}

const ITEM_WIDTH = 274;
const ITEM_HEIGHT = 600;

/**
 * Builds the hall from LobbyLayer.csb.
 * Sample data stands in for PKG_Lobby_Client_Enter_Success until the socket is ported.
 * Open assets/scenes/Lobby.scene in Cocos Creator 3.8.
 */
@ccclass('LobbyApp')
export class LobbyApp extends Component {
    private names = new Map<string, Node>();
    private status: Label | null = null;

    start(): void {
        resources.load('layout/LobbyLayer', JsonAsset, (err, asset) => {
            if (err || !asset) {
                console.error(err);
                return;
            }
            this.names = mountCsb(this.node, asset.json as CsbNode);
            this.setActive('btn_return', false);
            this.setActive('lua_btn_chat', false);
            this.setActive('lua_btn_lwjfl', false);
            this.createStatus();
            resources.load('layout/sample-lobby', JsonAsset, (sampleErr, sample) => {
                if (sampleErr || !sample) {
                    console.error(sampleErr);
                    return;
                }
                this.applySample(sample.json as SampleLobby);
            });
        });
    }

    private applySample(sample: SampleLobby): void {
        this.setText('lua_nickname', sample.nickname);
        this.bringNicknameIntoBar();
        this.setText('washcode_vip_num', String(sample.vipLevel));
        this.setText('lua_coin_num', sample.money);
        this.setText('lua_safebox_num', sample.moneySafe);
        this.setText('safebox_coin_num', sample.moneySafe);
        this.setText('washcode_num', sample.washCode);
        this.setText('url_text', sample.url);
        const vip = this.names.get('vip');
        if (vip) {
            vip.active = sample.vipLevel > 0;
        }
        this.fillGameList(sample.games);
        this.setStatus('大厅已进入');
    }

    private fillGameList(games: GameEntry[]): void {
        const list = this.names.get('list');
        if (!list) {
            return;
        }
        const listTransform = list.getComponent(UITransform);
        if (!listTransform) {
            return;
        }
        const mask = list.addComponent(Mask);
        mask.type = Mask.Type.GRAPHICS_RECT;

        const content = new Node('cards');
        content.layer = Layers.Enum.UI_2D;
        const contentTransform = content.addComponent(UITransform);
        content.setParent(list);
        const scale = listTransform.height / ITEM_HEIGHT;
        const cellWidth = ITEM_WIDTH * scale + 3;
        contentTransform.setAnchorPoint(0, 0);
        contentTransform.setContentSize(Math.max(listTransform.width, games.length * cellWidth), listTransform.height);
        content.setPosition(0, 0, 0);

        const scroll = list.addComponent(ScrollView);
        scroll.horizontal = true;
        scroll.vertical = false;
        scroll.inertia = true;
        scroll.elastic = true;
        scroll.content = content;

        games.forEach((game, index) => {
            content.addChild(this.createCard(game, index, cellWidth, scale, listTransform.height));
        });
    }

    private createCard(game: GameEntry, index: number, cellWidth: number, scale: number, listHeight: number): Node {
        const card = new Node(`game_${game.id}`);
        card.layer = Layers.Enum.UI_2D;
        const transform = card.addComponent(UITransform);
        const width = ITEM_WIDTH * scale - 10;
        const height = listHeight - 16;
        transform.setAnchorPoint(0.5, 0.5);
        transform.setContentSize(width, height);
        card.setPosition(index * cellWidth + cellWidth / 2, listHeight / 2, 0);

        const graphics = card.addComponent(Graphics);
        graphics.fillColor = new Color(16, 36, 64, 230);
        graphics.roundRect(-width / 2, -height / 2, width, height, 18);
        graphics.fill();
        graphics.strokeColor = new Color(255, 214, 120, 255);
        graphics.lineWidth = 3;
        graphics.roundRect(-width / 2, -height / 2, width, height, 18);
        graphics.stroke();

        card.addChild(this.createCardLabel(String(game.id), 0, 24, 40));
        card.addChild(this.createCardLabel(game.name, 0, -28, 24));

        let startX = 0;
        card.on(Node.EventType.TOUCH_START, (event) => {
            startX = event.getUILocation().x;
        });
        card.on(Node.EventType.TOUCH_END, (event) => {
            if (Math.abs(event.getUILocation().x - startX) < 30) {
                this.onGameClick(game);
            }
        });
        return card;
    }

    private createCardLabel(text: string, x: number, y: number, fontSize: number): Node {
        const node = new Node(text);
        node.layer = Layers.Enum.UI_2D;
        const transform = node.addComponent(UITransform);
        transform.setContentSize(220, fontSize + 8);
        node.setPosition(x, y, 0);
        const label = node.addComponent(Label);
        label.string = text;
        label.fontSize = fontSize;
        label.lineHeight = fontSize + 4;
        label.overflow = Overflow.SHRINK;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.verticalAlign = VerticalTextAlignment.CENTER;
        label.color = new Color(255, 236, 180, 255);
        return node;
    }

    private createStatus(): void {
        const node = new Node('enter_status');
        node.layer = Layers.Enum.UI_2D;
        const transform = node.addComponent(UITransform);
        transform.setAnchorPoint(0.5, 0.5);
        transform.setContentSize(640, 40);
        node.setPosition(640, 130, 0);
        node.setParent(this.node);
        const label = node.addComponent(Label);
        label.fontSize = 28;
        label.lineHeight = 32;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.color = new Color(255, 244, 210, 255);
        label.string = '';
        this.status = label;
    }

    private onGameClick(game: GameEntry): void {
        this.setStatus(`进入游戏 ${game.id} ${game.name}`);
    }

    private setStatus(text: string): void {
        if (this.status) {
            this.status.string = text;
        }
    }

    /** Nickname in this CSB is stored above the 72px bar, so pull it back beside the avatar. */
    private bringNicknameIntoBar(): void {
        const nickname = this.names.get('layout_nickname');
        const parentTransform = nickname?.parent?.getComponent(UITransform);
        if (!nickname || !parentTransform) {
            return;
        }
        if (nickname.position.y > parentTransform.height) {
            nickname.setPosition(150, parentTransform.height * 0.5, 0);
        }
    }

    private setText(name: string, text: string): void {
        const node = this.names.get(name);
        const label = node?.getComponent(Label);
        if (label) {
            label.string = text;
        }
    }

    private setActive(name: string, active: boolean): void {
        const node = this.names.get(name);
        if (node) {
            node.active = active;
        }
    }
}
