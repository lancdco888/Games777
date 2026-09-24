import {
    Button,
    Color,
    HorizontalTextAlignment,
    Label,
    Layers,
    Node,
    Overflow,
    resources,
    Sprite,
    SpriteFrame,
    UITransform,
    VerticalTextAlignment,
} from 'cc';

export interface CsbLayout {
    px?: boolean;
    py?: boolean;
    xp?: number;
    yp?: number;
    sw?: boolean;
    sh?: boolean;
    wp?: number;
    hp?: number;
    hx?: string;
    vy?: string;
    left?: number;
    right?: number;
    top?: number;
    bottom?: number;
}

export interface CsbNode {
    cls: string;
    name: string;
    x: number;
    y: number;
    w: number;
    h: number;
    ax: number;
    ay: number;
    sx?: number;
    sy?: number;
    visible?: boolean;
    file?: string | null;
    text?: string | null;
    sprite?: string | null;
    children: CsbNode[];
}

/** CSB position is the anchor point in the parent's bottom-left space. */
export function toCreatorPosition(item: CsbNode, parent: CsbNode): { x: number; y: number } {
    return {
        x: item.x - parent.ax * parent.w,
        y: item.y - parent.ay * parent.h,
    };
}

export function mountCsb(parent: Node, root: CsbNode): Map<string, Node> {
    const named = new Map<string, Node>();
    for (const child of root.children) {
        parent.addChild(createNode(child, root, named));
    }
    return named;
}

function createNode(item: CsbNode, parentData: CsbNode, named: Map<string, Node>): Node {
    const node = new Node(item.name || item.cls);
    node.layer = Layers.Enum.UI_2D;
    node.active = item.visible !== false;

    const transform = node.addComponent(UITransform);
    transform.setAnchorPoint(item.ax, item.ay);
    transform.setContentSize(Math.max(item.w, 0), Math.max(item.h, 0));
    const pos = toCreatorPosition(item, parentData);
    node.setPosition(pos.x, pos.y, 0);
    node.setScale(item.sx ?? 1, item.sy ?? 1, 1);

    if (!named.has(node.name)) {
        named.set(node.name, node);
    }
    if (item.sprite) {
        addSprite(node, item.sprite);
    }
    if (item.cls === 'Text' || item.cls === 'TextBMFont') {
        addLabel(node, item);
    }
    if (item.cls === 'Button') {
        const button = node.addComponent(Button);
        button.transition = Button.Transition.NONE;
    }
    for (const child of item.children) {
        node.addChild(createNode(child, item, named));
    }
    return node;
}

function addSprite(node: Node, spritePath: string): void {
    const sprite = node.addComponent(Sprite);
    sprite.sizeMode = Sprite.SizeMode.CUSTOM;
    sprite.type = Sprite.Type.SIMPLE;
    const loadPath = spritePath.replace(/\.(png|jpg|jpeg|webp)$/i, '') + '/spriteFrame';
    resources.load(loadPath, SpriteFrame, (err, frame) => {
        if (err || !frame || !sprite.isValid) {
            return;
        }
        sprite.spriteFrame = frame;
        sprite.sizeMode = Sprite.SizeMode.CUSTOM;
    });
}

function addLabel(node: Node, item: CsbNode): void {
    const label = node.addComponent(Label);
    label.string = item.text || '';
    label.fontSize = Math.max(16, Math.round((item.h || 24) * 0.72));
    label.lineHeight = label.fontSize + 4;
    label.overflow = Overflow.SHRINK;
    label.enableWrapText = false;
    label.color = new Color(255, 236, 180, 255);
    label.horizontalAlign = item.ax < 0.2 ? HorizontalTextAlignment.LEFT : HorizontalTextAlignment.CENTER;
    label.verticalAlign = VerticalTextAlignment.CENTER;
}
