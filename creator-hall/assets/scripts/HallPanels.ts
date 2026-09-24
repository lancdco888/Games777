import {
    BlockInputEvents,
    Button,
    Color,
    EditBox,
    Graphics,
    HorizontalTextAlignment,
    Label,
    Layers,
    Node,
    Overflow,
    UITransform,
    VerticalTextAlignment,
} from 'cc';
import { bindClick } from './CsbView';
import { formatMoney, GameInfo, HallResult, HallState } from './HallState';

const FISH_LEVELS: Array<[string, number, string]> = [
    ['体验场', 0, '10-100'],
    ['初级场', 1000, '100-1,000'],
    ['中级场', 10000, '1,000-10,000'],
    ['高级场', 100000, '10,000-100,000'],
];

const RECHARGE_AMOUNTS = [100, 500, 1000, 5000, 10000, 50000];

/**
 * Hall popups for the buttons on the original lobby.
 * Account changes stay on this device until the socket login is ported.
 */
export class HallPanels {
    private popup: Node | null = null;
    private toastNode: Label | null = null;

    private logoutHandler: (() => void) | null = null;

    constructor(private readonly root: Node, private readonly state: HallState) {}

    setLogout(handler: () => void): void {
        this.logoutHandler = handler;
    }

    dismiss(): void {
        this.close();
    }

    toast(text: string): void {
        if (!this.toastNode) {
            const node = new Node('toast');
            node.layer = Layers.Enum.UI_2D;
            const transform = node.addComponent(UITransform);
            transform.setContentSize(760, 48);
            node.setPosition(640, 250, 0);
            node.setParent(this.root);
            const label = node.addComponent(Label);
            label.fontSize = 26;
            label.lineHeight = 32;
            label.horizontalAlign = HorizontalTextAlignment.CENTER;
            label.verticalAlign = VerticalTextAlignment.CENTER;
            label.color = new Color(255, 244, 210, 255);
            this.toastNode = label;
        }
        this.toastNode.node.active = true;
        this.toastNode.string = text;
        this.toastNode.node.setSiblingIndex(this.root.children.length - 1);
        const current = text;
        setTimeout(() => {
            if (this.toastNode && this.toastNode.string === current) {
                this.toastNode.node.active = false;
            }
        }, 2200);
    }

    copyUrl(): void {
        this.copyText(this.state.url);
        this.toast('复制成功');
    }

    claimRelief(): void {
        this.toast(this.state.claimRelief().message);
    }

    openProfile(): void {
        const state = this.state;
        this.open('个人信息', 500, (panel) => {
            this.text(panel, `${state.nickname}    ID ${state.userId}`, 0, 160, 28);
            this.text(panel, `VIP ${state.vipLevel}    账号 ${state.account || '未绑定'}`, 0, 110, 24);
            this.text(panel, `携带 ${formatMoney(state.money)}    保险箱 ${formatMoney(state.moneySafe)}`, 0, 60, 24);
            this.text(panel, `洗码 ${formatMoney(state.washCode)}`, 0, 16, 24);
            this.button(panel, '复制 ID', -180, -50, 200, 58, () => {
                this.copyText(state.userId);
                this.toast('复制成功');
            });
            this.button(panel, '查看 VIP', 40, -50, 200, 58, () => this.openVip());
            this.button(panel, '绑定账号', -180, -130, 200, 58, () => this.openBind());
            this.button(panel, '退出登录', 40, -130, 200, 58, () => {
                this.close();
                if (this.logoutHandler) {
                    this.logoutHandler();
                    return;
                }
                this.toast('已退出登录');
            });
        });
    }

    openSettings(): void {
        this.open('设置', 460, (panel) => {
            const rows: Array<['music' | 'sound' | 'effect' | 'notice', string]> = [
                ['music', '音乐'],
                ['sound', '音效'],
                ['effect', '特效'],
                ['notice', '跑马灯'],
            ];
            rows.forEach((row, index) => {
                const draw = () => `${row[1]}：${this.state[row[0]] ? '开' : '关'}`;
                const label = this.text(panel, draw(), 0, 130 - index * 78, 28);
                this.button(panel, '切换', 250, 130 - index * 78, 120, 52, () => {
                    this.toast(this.state.toggle(row[0]).message);
                    label.string = draw();
                });
            });
        });
    }

    openSafe(): void {
        let kind: 'coin' | 'wash' = 'coin';
        this.open('保险箱', 500, (panel) => {
            const pocket = this.text(panel, '', 0, 150, 26);
            const safe = this.text(panel, '', 0, 100, 26);
            const refresh = () => {
                if (kind === 'coin') {
                    pocket.string = `携带金币 ${formatMoney(this.state.money)}`;
                    safe.string = `保险箱 ${formatMoney(this.state.moneySafe)}`;
                } else {
                    pocket.string = `携带洗码 ${formatMoney(this.state.washCode)}`;
                    safe.string = `保险箱洗码 ${formatMoney(this.state.giftSafe)}`;
                }
            };
            refresh();
            this.button(panel, '金币', -120, 40, 160, 52, () => {
                kind = 'coin';
                refresh();
            });
            this.button(panel, '洗码', 80, 40, 160, 52, () => {
                kind = 'wash';
                refresh();
            });
            const input = this.field(panel, '输入金额', 0, -30);
            input.inputMode = EditBox.InputMode.NUMERIC;
            this.button(panel, '存入', -140, -120, 180, 58, () => {
                this.toast(this.state.deposit(kind, Number(input.string)).message);
                refresh();
            });
            this.button(panel, '取出', 80, -120, 180, 58, () => {
                this.toast(this.state.withdraw(kind, Number(input.string)).message);
                refresh();
            });
        });
    }

    openRecharge(): void {
        this.open('充值', 460, (panel) => {
            this.text(panel, `当前携带 ${formatMoney(this.state.money)}`, 0, 150, 26);
            RECHARGE_AMOUNTS.forEach((amount, index) => {
                const column = index % 3;
                const row = Math.floor(index / 3);
                this.button(panel, formatMoney(amount), -220 + column * 220, 50 - row * 90, 190, 64, () => {
                    this.toast(this.state.recharge(amount).message);
                    this.close();
                });
            });
        });
    }

    openService(): void {
        this.open('客服', 520, (panel) => {
            this.text(panel, '在线客服：service888', 0, 170, 26);
            this.button(panel, '复制客服号', 0, 110, 220, 52, () => {
                this.copyText('service888');
                this.toast('复制成功');
            });
            this.state.mails.forEach((mail, index) => {
                const title = `${mail.read ? '' : '● '}${mail.title}`;
                this.button(panel, title, 0, 30 - index * 80, 560, 64, () => {
                    mail.read = true;
                    this.toast(mail.body);
                    this.openService();
                });
            });
        });
    }

    openActivity(): void {
        this.open('活动中心', 460, (panel) => {
            this.state.activities.forEach((item, index) => {
                this.button(panel, item.name, 0, 120 - index * 100, 460, 72, () => {
                    if (item.id === 'sign') {
                        this.toast(this.state.signIn().message);
                        return;
                    }
                    if (item.id === 'recharge') {
                        this.openRecharge();
                        return;
                    }
                    this.openVip();
                });
            });
        });
    }

    openVip(): void {
        const level = this.state.vipLevel;
        this.open('VIP 特权', 420, (panel) => {
            this.text(panel, `当前等级 VIP ${level}`, 0, 110, 30);
            this.text(panel, '签到奖励、充值到账和赠送都按当前等级开放', 0, 50, 22, 620);
            this.text(panel, level >= 8 ? '已是最高等级' : `再升级可降低赠送手续费，当前 ${this.state.giftFee * 100}%`, 0, -10, 22, 620);
            this.button(panel, '去充值', 0, -100, 220, 58, () => this.openRecharge());
        });
    }

    openBind(): void {
        this.open('绑定账号', 420, (panel) => {
            const account = this.field(panel, '账号', 0, 70);
            const password = this.field(panel, '密码', 0, 0, true);
            if (this.state.account) {
                account.string = this.state.account;
            }
            this.button(panel, '确定绑定', 0, -90, 240, 60, () => {
                const result = this.state.bindAccount(account.string, password.string);
                this.toast(result.message);
                if (result.ok) {
                    this.close();
                }
            });
        });
    }

    openRegister(): void {
        this.open('注册会员', 380, (panel) => {
            const account = this.field(panel, '会员账号', 0, 40);
            this.button(panel, this.state.registered ? '已注册' : '注册', 0, -70, 240, 60, () => {
                const result = this.state.register(account.string);
                this.toast(result.message);
                if (result.ok) {
                    this.close();
                }
            });
        });
    }

    openGive(): void {
        if (!this.state.giftPassword) {
            this.open('设置赠送密码', 360, (panel) => {
                const password = this.field(panel, '6 位数字密码', 0, 40, true);
                password.maxLength = 6;
                password.inputMode = EditBox.InputMode.NUMERIC;
                this.button(panel, '确定', 0, -70, 220, 58, () => {
                    const result = this.state.setGiftPassword(password.string);
                    this.toast(result.message);
                    if (result.ok) {
                        this.openGive();
                    }
                });
            });
            return;
        }
        this.open('赠送', 520, (panel) => {
            this.text(
                panel,
                `最少 ${formatMoney(this.state.giftMin)}，手续费 ${this.state.giftFee * 100}%，至少保留 ${formatMoney(this.state.giftRemain)}`,
                0,
                180,
                20,
                700,
            );
            const target = this.field(panel, '对方 ID', 0, 110);
            target.inputMode = EditBox.InputMode.NUMERIC;
            const amount = this.field(panel, '赠送金额', 0, 50);
            amount.inputMode = EditBox.InputMode.NUMERIC;
            const password = this.field(panel, '赠送密码', 0, -10, true);
            password.maxLength = 6;
            password.inputMode = EditBox.InputMode.NUMERIC;
            this.button(panel, '确认赠送', 0, -90, 240, 58, () => {
                const result = this.state.give(target.string.trim(), Number(amount.string), password.string);
                this.toast(result.message);
                if (result.ok) {
                    this.close();
                }
            });
            const last = this.state.records[0];
            this.text(panel, last ? `最近赠送 ${formatMoney(last.amount)} 给 ${last.target}` : '还没有赠送记录', 0, -160, 20, 640);
        });
    }

    openGame(game: GameInfo): void {
        if (game.type === 'haiwang') {
            this.open(game.name, 520, (panel) => {
                FISH_LEVELS.forEach((level, index) => {
                    this.button(
                        panel,
                        `${level[0]}   炮值 ${level[2]}   准入 ${formatMoney(level[1])}`,
                        0,
                        150 - index * 86,
                        640,
                        68,
                        () => this.finishGame(this.state.enterGame(game.name, level[0], level[1])),
                    );
                });
            });
            return;
        }
        this.open(game.name, 340, (panel) => {
            this.text(panel, `游戏编号 ${game.id}`, 0, 50, 26);
            this.button(panel, '进入游戏', 0, -50, 260, 64, () => {
                this.finishGame(this.state.enterGame(game.name, '', 0));
            });
        });
    }

    private finishGame(result: HallResult): void {
        this.toast(result.message);
        if (result.ok) {
            this.close();
        }
    }

    private open(title: string, height: number, build: (panel: Node) => void): void {
        this.close();
        const host = new Node('hall_popup');
        host.layer = Layers.Enum.UI_2D;
        const hostTransform = host.addComponent(UITransform);
        hostTransform.setContentSize(1280, 720);
        host.setPosition(640, 360, 0);
        host.setParent(this.root);

        const dim = new Node('dim');
        dim.layer = Layers.Enum.UI_2D;
        const dimTransform = dim.addComponent(UITransform);
        dimTransform.setContentSize(1280, 720);
        dim.setParent(host);
        const shade = dim.addComponent(Graphics);
        shade.fillColor = new Color(0, 0, 0, 160);
        shade.rect(-640, -360, 1280, 720);
        shade.fill();
        bindClick(dim, () => this.close());
        const dimButton = dim.getComponent(Button);
        if (dimButton) {
            dimButton.transition = Button.Transition.NONE;
        }

        const panel = new Node('panel');
        panel.layer = Layers.Enum.UI_2D;
        const panelTransform = panel.addComponent(UITransform);
        panelTransform.setContentSize(780, height);
        panel.setParent(host);
        panel.addComponent(BlockInputEvents);
        const board = panel.addComponent(Graphics);
        board.fillColor = new Color(10, 28, 52, 245);
        board.roundRect(-390, -height / 2, 780, height, 18);
        board.fill();
        board.strokeColor = new Color(255, 214, 120, 255);
        board.lineWidth = 3;
        board.roundRect(-390, -height / 2, 780, height, 18);
        board.stroke();
        this.text(panel, title, 0, height / 2 - 42, 32);
        this.button(panel, '关闭', 300, height / 2 - 42, 110, 46, () => this.close());
        build(panel);
        this.popup = host;
        host.setSiblingIndex(this.root.children.length - 1);
    }

    private copyText(value: string): void {
        const host = globalThis as { navigator?: { clipboard?: { writeText: (text: string) => Promise<void> } } };
        host.navigator?.clipboard?.writeText(value).catch(() => undefined);
    }

    private close(): void {
        this.popup?.destroy();
        this.popup = null;
    }

    private text(parent: Node, value: string, x: number, y: number, size: number, width = 680): Label {
        const node = new Node('text');
        node.layer = Layers.Enum.UI_2D;
        const transform = node.addComponent(UITransform);
        transform.setContentSize(width, size + 16);
        node.setPosition(x, y, 0);
        node.setParent(parent);
        const label = node.addComponent(Label);
        label.string = value;
        label.fontSize = size;
        label.lineHeight = size + 6;
        label.overflow = Overflow.SHRINK;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.verticalAlign = VerticalTextAlignment.CENTER;
        label.color = new Color(255, 236, 190, 255);
        return label;
    }

    private button(parent: Node, value: string, x: number, y: number, width: number, height: number, handler: () => void): void {
        const node = new Node(value);
        node.layer = Layers.Enum.UI_2D;
        const transform = node.addComponent(UITransform);
        transform.setContentSize(width, height);
        node.setPosition(x, y, 0);
        node.setParent(parent);
        const graphics = node.addComponent(Graphics);
        graphics.fillColor = new Color(24, 78, 128, 255);
        graphics.roundRect(-width / 2, -height / 2, width, height, 12);
        graphics.fill();
        graphics.strokeColor = new Color(255, 214, 120, 255);
        graphics.lineWidth = 2;
        graphics.roundRect(-width / 2, -height / 2, width, height, 12);
        graphics.stroke();
        this.text(node, value, 0, 0, 22, width - 20);
        bindClick(node, handler);
    }

    private field(parent: Node, placeholder: string, x: number, y: number, password = false): EditBox {
        const node = new Node(placeholder);
        node.layer = Layers.Enum.UI_2D;
        const transform = node.addComponent(UITransform);
        transform.setContentSize(460, 52);
        node.setPosition(x, y, 0);
        node.setParent(parent);
        const graphics = node.addComponent(Graphics);
        graphics.fillColor = new Color(6, 16, 32, 255);
        graphics.roundRect(-230, -26, 460, 52, 8);
        graphics.fill();
        const edit = node.addComponent(EditBox);
        edit.placeholder = placeholder;
        edit.string = '';
        edit.fontSize = 24;
        edit.placeholderFontSize = 22;
        edit.fontColor = new Color(255, 244, 220, 255);
        edit.maxLength = 18;
        edit.inputMode = password ? EditBox.InputMode.NUMERIC : EditBox.InputMode.SINGLE_LINE;
        if (password) {
            edit.inputFlag = EditBox.InputFlag.PASSWORD;
        }
        return edit;
    }
}
