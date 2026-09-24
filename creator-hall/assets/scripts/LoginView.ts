import { BlockInputEvents, Color, EditBox, Graphics, HorizontalTextAlignment, Label, Layers, Node, Overflow, UITransform, VerticalTextAlignment } from 'cc';
import { bindClick } from './CsbView';
import { GosClient } from './GosClient';
import { HallState } from './HallState';
import { loadServerSettings, saveServerSettings, ServerSettings } from './ServerSettings';

/** Login screen. Server buttons talk to goserver; local play keeps the demo account. */
export class LoginView {
    private readonly root: Node;
    private panel: Node | null = null;
    private noteNode: Node | null = null;
    private readonly client = new GosClient();
    private settings: ServerSettings = loadServerSettings();
    private busy = false;

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

    disconnect(): void {
        this.client.close();
    }

    bringToFront(): void {
        this.root.setSiblingIndex(this.root.parent ? this.root.parent.children.length - 1 : 0);
    }

    private showHome(): void {
        this.clear();
        this.title('连接 goserver');
        this.label('先在本机运行 node creator-hall/tools/goserver-bridge.mjs', 0, 250, 20, 860);
        const host = this.field('服务器 IP', -170, 180, 300, 64, this.settings.host);
        const port = this.field('端口', 170, 180, 220, 16, this.settings.port);
        const packageName = this.field('包名', -170, 110, 300, 64, this.settings.packageName);
        const version = this.field('版本', 170, 110, 220, 16, this.settings.version);
        const bridge = this.field('桥接地址', 0, 40, 640, 128, this.settings.bridgeUrl);
        this.action('游客登录', -230, -50, () => {
            this.capture(host, port, packageName, version, bridge);
            void this.enterServer('guest');
        });
        this.action('密码登录', 0, -50, () => {
            this.capture(host, port, packageName, version, bridge);
            this.showPassword();
        });
        this.action('注册账号', 230, -50, () => {
            this.capture(host, port, packageName, version, bridge);
            this.showRegister();
        });
        this.action('本地体验', 0, -140, () => this.finish(this.state.loginGuest()));
        this.label('本地体验不连接服务器。游客登录会沿用上次的游客名。', 0, -210, 18, 760);
    }

    private showPassword(): void {
        this.clear();
        this.title('密码登录');
        this.label(`${this.settings.host}:${this.settings.port || '端口未填'}`, 0, 150, 20, 720);
        const account = this.field('账号', 0, 70, 460, 32, '');
        const password = this.field('密码', 0, 0, 460, 32, '', true);
        this.action('登录', -130, -100, () => {
            void this.enterServer('password', account.string, password.string);
        });
        this.action('返回', 130, -100, () => this.showHome());
    }

    private showRegister(): void {
        this.clear();
        this.title('注册账号');
        const account = this.field('账号 4至12位', 0, 80, 460, 32, '');
        const password = this.field('密码 8至16位', 0, 10, 460, 32, '', true);
        const confirm = this.field('确认密码', 0, -60, 460, 32, '', true);
        this.action('注册并进入', -150, -160, () => {
            void this.enterServer('register', account.string, password.string, confirm.string);
        });
        this.action('返回', 150, -160, () => this.showHome());
    }

    private async enterServer(mode: 'guest' | 'password' | 'register', account = '', password = '', confirm = ''): Promise<void> {
        if (this.busy) {
            return;
        }
        const name = account.trim();
        if (mode !== 'guest') {
            if (name.length < 4 || name.length > 12) {
                this.note('账户名称长度4至12位');
                return;
            }
            if (password.length < 8 || password.length > 16) {
                this.note('账户密码长度8至16位');
                return;
            }
        }
        if (mode === 'register' && password !== confirm) {
            this.note('两次密码不一致');
            return;
        }
        this.busy = true;
        const portNote = this.settings.port === '21000' ? ' 21000 端口在原版客户端会加密，这次发送的是明文。' : '';
        this.note(`正在连接 ${this.settings.host}:${this.settings.port}…${portNote}`);
        try {
            if (mode === 'register') {
                await this.client.register(this.settings, name, password);
            }
            const profile = mode === 'guest'
                ? await this.client.loginGuest(this.settings)
                : await this.client.loginPassword(this.settings, name, password);
            if (mode === 'guest' && profile.username) {
                this.settings.guestUsername = profile.username;
            }
            saveServerSettings(this.settings);
            const result = this.state.applyServer(profile, mode === 'guest' ? '' : name);
            this.busy = false;
            this.finish(result);
        } catch (error) {
            this.busy = false;
            this.note(error instanceof Error ? error.message : '连接失败');
        }
    }

    private capture(host: EditBox, port: EditBox, packageName: EditBox, version: EditBox, bridge: EditBox): void {
        this.settings = {
            ...this.settings,
            host: host.string.trim() || this.settings.host,
            port: port.string.trim(),
            packageName: packageName.string.trim() || this.settings.packageName,
            version: version.string.trim() || this.settings.version,
            bridgeUrl: bridge.string.trim() || this.settings.bridgeUrl,
        };
        saveServerSettings(this.settings);
    }

    private finish(result: { ok: boolean; message: string }): void {
        if (!result.ok) {
            this.note(result.message);
            return;
        }
        this.hide();
        this.onEnter(result.message);
    }

    private clear(): void {
        this.noteNode = null;
        this.panel?.destroy();
        this.panel = new Node('login_panel');
        this.panel.layer = Layers.Enum.UI_2D;
        this.panel.addComponent(UITransform).setContentSize(980, 640);
        this.panel.setParent(this.root);
    }

    private title(value: string): void {
        this.label(value, 0, 290, 36, 700);
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

    private note(value: string): void {
        this.noteNode?.destroy();
        const node = new Node('status');
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(860, 36);
        node.setPosition(0, -270, 0);
        node.setParent(this.panel ?? this.root);
        const label = node.addComponent(Label);
        label.string = value;
        label.fontSize = 20;
        label.lineHeight = 28;
        label.overflow = Overflow.SHRINK;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.verticalAlign = VerticalTextAlignment.CENTER;
        label.color = new Color(255, 196, 120, 255);
        this.noteNode = node;
    }

    private action(value: string, x: number, y: number, handler: () => void): void {
        const node = new Node(value);
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(200, 56);
        node.setPosition(x, y, 0);
        node.setParent(this.panel ?? this.root);
        const graphics = node.addComponent(Graphics);
        graphics.fillColor = new Color(24, 78, 128, 255);
        graphics.roundRect(-100, -28, 200, 56, 12);
        graphics.fill();
        const labelNode = new Node('caption');
        labelNode.layer = Layers.Enum.UI_2D;
        labelNode.addComponent(UITransform).setContentSize(180, 36);
        labelNode.setParent(node);
        const label = labelNode.addComponent(Label);
        label.string = value;
        label.fontSize = 24;
        label.horizontalAlign = HorizontalTextAlignment.CENTER;
        label.verticalAlign = VerticalTextAlignment.CENTER;
        label.color = new Color(255, 244, 220, 255);
        bindClick(node, handler);
    }

    private field(placeholder: string, x: number, y: number, width: number, maxLength: number, value: string, password = false): EditBox {
        const node = new Node(placeholder);
        node.layer = Layers.Enum.UI_2D;
        node.addComponent(UITransform).setContentSize(width, 48);
        node.setPosition(x, y, 0);
        node.setParent(this.panel ?? this.root);
        const graphics = node.addComponent(Graphics);
        graphics.fillColor = new Color(6, 16, 32, 255);
        graphics.roundRect(-width / 2, -24, width, 48, 8);
        graphics.fill();
        const edit = node.addComponent(EditBox);
        edit.placeholder = placeholder;
        edit.string = value;
        edit.fontSize = 22;
        edit.fontColor = new Color(255, 244, 220, 255);
        edit.maxLength = maxLength;
        edit.inputMode = EditBox.InputMode.SINGLE_LINE;
        if (password) {
            edit.inputFlag = EditBox.InputFlag.PASSWORD;
        }
        return edit;
    }
}
