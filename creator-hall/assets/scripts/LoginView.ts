import { BlockInputEvents, Color, EditBox, Graphics, HorizontalTextAlignment, Label, Layers, Node, Overflow, UITransform, VerticalTextAlignment } from 'cc';
import { bindClick } from './CsbView';
import { HallState } from './HallState';

/** Login screen shown before the lobby. Guest, password, and register all enter the hall. */
export class LoginView {
    private readonly root: Node;
    private panel: Node | null = null;

    constructor(
        parent: Node,
        private readonly state: HallState,
        private readonly onEnter: (message: string) => void,
    ) {
        this.root = new Node('hall_login');
        this.root.layer = Layers.Enum.UI_2D;
        const transform = this.root.addComponent(UITransform);
        transform.setContentSize(1280, 720);
        this.root.setPosition(640, 360, 0);
        this.root.setParent(parent);
        this.root.addComponent(BlockInputEvents);
        const shade = this.root.addComponent(Graphics);
        shade.fillColor = new Color(8, 18, 36, 255);
        shade.rect(-640, -360, 1280, 720);
        shade.fill();
        this.showHome();
    }

    show(): void {
        this.root.active = true;
        this.bringToFront();
        this.showHome();
    }

    hide(): void {
        this.root.active = false;
    }

    bringToFront(): void {
        this.root.setSiblingIndex(this.root.parent ? this.root.parent.children.length - 1 : 0);
    }

    private showHome(): void {
        this.clear();
        this.title('大厅登录');
        this.label('游客登录会生成新账号。已有账号可用密码登录。', 0, 150, 22, 720);
        this.label('体验账号 player9236    密码 12345678', 0, 100, 24, 760);
        this.action('游客登录', 0, 10, () => this.finish(this.state.loginGuest()));
        this.action('密码登录', 0, -80, () => this.showPassword());
        this.action('注册账号', 0, -170, () => this.showRegister());
    }

    private showPassword(): void {
        this.clear();
        this.title('密码登录');
        const account = this.field('账号', 0, 60);
        const password = this.field('密码', 0, -10, true);
        this.action('登录', -130, -120, () => {
            const result = this.state.loginAccount(account.string, password.string);
            if (!result.ok) {
                this.label(result.message, 0, -190, 22, 640);
                return;
            }
            this.finish(result);
        });
        this.action('返回', 130, -120, () => this.showHome());
    }

    private showRegister(): void {
        this.clear();
        this.title('注册账号');
        const account = this.field('账号 4至12位', 0, 80);
        const password = this.field('密码 8至16位', 0, 10, true);
        const confirm = this.field('确认密码', 0, -60, true);
        this.action('注册并进入', -150, -160, () => {
            const result = this.state.registerAccount(account.string, password.string, confirm.string);
            if (!result.ok) {
                this.label(result.message, 0, -230, 22, 640);
                return;
            }
            this.finish(result);
        });
        this.action('返回', 150, -160, () => this.showHome());
    }

    private finish(result: { ok: boolean; message: string }): void {
        if (!result.ok) {
            return;
        }
        this.hide();
        this.onEnter(result.message);
    }

    private clear(): void {
        this.panel?.destroy();
        this.panel = new Node('login_panel');
        this.panel.layer = Layers.Enum.UI_2D;
        this.panel.addComponent(UITransform).setContentSize(860, 560);
        this.panel.setParent(this.root);
    }

    private title(value: string): void {
        this.label(value, 0, 220, 40, 700);
    }

    private label(value: string, x: number, y: number, size: number, width: number): void {
        const node = new Node('text');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(width, size + 16);
        node.setPosition(x, y, 0);
        node.setParent(this.panel ?? this.root);
        const label = node.addComponent(Label);
        label.string = value;
        label.fontSize = size;
        label.lineHeight = size + 8;
        label.overflow = Overflow.SHRINK;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.verticalAlign = VerticalTextAlignment.CENTER;
        label.color = new Color(255, 236, 190, 255);
    }

    private action(value: string, x: number, y: number, handler: () => void): void {
        const node = new Node(value);
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(240, 64);
        node.setPosition(x, y, 0);
        node.setParent(this.panel ?? this.root);
        const graphics = node.addComponent(Graphics);
        graphics.fillColor = new Color(24, 78, 128, 255);
        graphics.roundRect(-120, -32, 240, 64, 12);
        graphics.fill();
        const labelNode = new Node('caption');
        labelNode.layer = Layers.Enum.UI_2D;
        labelNode.addComponent(UITransform).setContentSize(220, 40);
        labelNode.setParent(node);
        const label = labelNode.addComponent(Label);
        label.string = value;
        label.fontSize = 26;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.verticalAlign = VerticalTextAlignment.CENTER;
        label.color = new Color(255, 244, 220, 255);
        bindClick(node, handler);
    }

    private field(placeholder: string, x: number, y: number, password = false): EditBox {
        const node = new Node(placeholder);
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(460, 52);
        node.setPosition(x, y, 0);
        node.setParent(this.panel ?? this.root);
        const graphics = node.addComponent(Graphics);
        graphics.fillColor = new Color(6, 16, 32, 255);
        graphics.roundRect(-230, -26, 460, 52, 8);
        graphics.fill();
        const edit = node.addComponent(EditBox);
        edit.placeholder = placeholder;
        edit.string = '';
        edit.fontSize = 24;
        edit.fontColor = new Color(255, 244, 220, 255);
        edit.maxLength = 16;
        edit.inputMode = password ? EditBox.InputMode.SINGLE_LINE : EditBox.InputMode.SINGLE_LINE;
        if (password) {
            edit.inputFlag = EditBox.InputFlag.PASSWORD;
        }
        return edit;
    }
}
