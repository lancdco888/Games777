import { _decorator, Button, Component, EventTouch, JsonAsset, js, Label, Layers, Mask, Node, resources, ScrollView, UITransform } from 'cc';
import { attachSprite, bindClick, CsbNode, mountCsb } from './CsbView';
import { HallPanels } from './HallPanels';
import { formatMoney, GameInfo, HallState } from './HallState';

const { ccclass } = _decorator;

interface SampleLobby {
    nickname: string;
    vipLevel: number;
    money: string;
    moneySafe: string;
    washCode: string;
    url: string;
}

const ICON_WIDTH = 264;
const ICON_HEIGHT = 467;

/**
 * Builds the hall from LobbyLayer.csb and connects every lobby button.
 * Open assets/scenes/Lobby.scene with Cocos Creator 3.8.8.
 */
@ccclass('LobbyApp')
export class LobbyApp extends Component {
    private names = new Map<string, Node>();
    private readonly state = new HallState();
    private panels: HallPanels | null = null;

    start(): void {
        this.panels = new HallPanels(this.node, this.state);
        this.state.listen(() => this.refresh());
        resources.load('layout/LobbyLayer', JsonAsset, (err, asset) => {
            if (err || !asset) {
                console.error(err);
                return;
            }
            this.names = mountCsb(this.node, asset.json as CsbNode);
            this.setActive('btn_return', false);
            this.setActive('lua_btn_chat', false);
            this.setActive('lua_btn_lwjfl', false);
            this.bindHall();
            this.raiseBars();
            resources.load('layout/sample-lobby', JsonAsset, (sampleErr, sample) => {
                if (sampleErr || !sample) {
                    console.error(sampleErr);
                    return;
                }
                this.state.applySample(sample.json as SampleLobby);
                this.bringNicknameIntoBar();
            });
            resources.load('layout/games', JsonAsset, (gameErr, gamesAsset) => {
                if (gameErr || !gamesAsset) {
                    console.error(gameErr);
                    return;
                }
                const games = (gamesAsset.json as { games: GameInfo[] }).games;
                this.fillGameList(games);
                this.raiseBars();
            });
        });
    }

    private bindHall(): void {
        const panels = this.panels;
        if (!panels) {
            return;
        }
        const go = (name: string, action: () => void) => bindClick(this.names.get(name), action);
        go('lua_head_touch', () => panels.openProfile());
        go('lua_coin_btn', () => panels.openRecharge());
        go('lua_coin_touch', () => panels.openRecharge());
        go('lua_safebox_btn', () => panels.openSafe());
        go('lua_safebox_touch', () => panels.openSafe());
        go('lua_btn_safebox', () => panels.openSafe());
        go('lua_btn_set', () => panels.openSettings());
        go('btn_rechage', () => panels.openRecharge());
        go('lua_recharge_btn', () => panels.openRecharge());
        go('btn_copy', () => panels.copyUrl());
        go('lua_btn_service', () => panels.openService());
        go('lua_btn_facebook', () => panels.openRegister());
        go('lua_btn_bind', () => panels.openBind());
        go('lua_btn_vipqy', () => panels.openVip());
        go('lua_btn_activity', () => panels.openActivity());
        go('lua_btn_jjj', () => panels.claimRelief());
        go('lua_btn_give', () => panels.openGive());
    }

    private refresh(): void {
        const state = this.state;
        this.setText('lua_nickname', state.nickname);
        this.setText('washcode_vip_num', String(state.vipLevel));
        this.setText('lua_coin_num', formatMoney(state.money));
        this.setText('lua_safebox_num', formatMoney(state.moneySafe));
        this.setText('safebox_coin_num', formatMoney(state.moneySafe));
        this.setText('safebox_xima_num', formatMoney(state.giftSafe));
        this.setText('washcode_num', formatMoney(state.washCode));
        this.setText('url_text', state.url);
        const vip = this.names.get('vip');
        if (vip) {
            vip.active = state.vipLevel > 0;
        }
    }

    private fillGameList(games: GameInfo[]): void {
        const list = this.names.get('list');
        const listTransform = list?.getComponent(UITransform);
        if (!list || !listTransform) {
            return;
        }
        const mask = list.getComponent(Mask) ?? list.addComponent(Mask);
        mask.type = Mask.Type.GRAPHICS_RECT;
        const scale = (listTransform.height - 24) / ICON_HEIGHT;
        const cardWidth = ICON_WIDTH * scale;
        const cardHeight = ICON_HEIGHT * scale;
        const cellWidth = cardWidth + 12;

        const content = new Node('cards');
        content.layer = Layers.Enum.UI_2D;
        const contentTransform = content.addComponent(UITransform);
        content.setParent(list);
        contentTransform.setAnchorPoint(0, 0);
        contentTransform.setContentSize(Math.max(listTransform.width, games.length * cellWidth), listTransform.height);
        content.setPosition(0, 0, 0);

        const scroll = list.getComponent(ScrollView) ?? list.addComponent(ScrollView);
        scroll.horizontal = true;
        scroll.vertical = false;
        scroll.inertia = true;
        scroll.elastic = true;
        scroll.cancelInnerEvents = true;
        scroll.content = content;

        games.forEach((game, index) => {
            content.addChild(this.createCard(game, index, cellWidth, cardWidth, cardHeight, listTransform.height));
        });
    }

    private createCard(game: GameInfo, index: number, cellWidth: number, cardWidth: number, cardHeight: number, listHeight: number): Node {
        const card = new Node(`game_${game.id}`);
        card.layer = Layers.Enum.UI_2D;
        const transform = card.addComponent(UITransform);
        transform.setAnchorPoint(0.5, 0.5);
        transform.setContentSize(cardWidth, cardHeight);
        card.setPosition(index * cellWidth + cellWidth / 2, listHeight / 2, 0);
        const button = card.addComponent(Button);
        button.transition = Button.Transition.NONE;
        attachSprite(card, `hall/lobby/icon/${game.icon}.png`);

        let startX = 0;
        card.on(Node.EventType.TOUCH_START, (event: EventTouch) => {
            startX = event.getUILocation().x;
        });
        card.on(Node.EventType.TOUCH_END, (event: EventTouch) => {
            if (Math.abs(event.getUILocation().x - startX) < 24) {
                this.panels?.openGame(game);
            }
        });
        return card;
    }

    private raiseBars(): void {
        const panel = this.names.get('panel');
        const user = this.names.get('user_info');
        const buttons = this.names.get('function_buttons');
        if (!panel) {
            return;
        }
        user?.setSiblingIndex(panel.children.length - 1);
        buttons?.setSiblingIndex(panel.children.length - 1);
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

// Creator 3.8.8 registers the 23-character id. The first scene file used the 22-character id.
js.setClassAlias(LobbyApp, 'c4a1eeybTBPkZpYDns8kdSm');
js.setClassAlias(LobbyApp, 'c4oeeybTBPkZpYDns8kdSm');
