import {
    Button,
    Color,
    HorizontalTextAlignment,
    ImageAsset,
    Label,
    Layers,
    Node,
    Overflow,
    Rect,
    resources,
    Size,
    Sprite,
    SpriteFrame,
    Texture2D,
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

const imageStats = { pending: 0, loaded: 0, missing: 0 };

export function attachSprite(node: Node, spritePath: string): void {
    addSprite(node, spritePath);
}

/** Runtime buttons only respond after a click listener is attached. */
export function bindClick(node: Node | null | undefined, handler: () => void): void {
    if (!node) {
        return;
    }
    let button = node.getComponent(Button);
    if (!button) {
        button = node.addComponent(Button);
    }
    button.transition = Button.Transition.SCALE;
    button.zoomScale = 0.94;
    button.interactable = true;
    let locked = false;
    node.on(Button.EventType.CLICK, () => {
        if (locked) {
            return;
        }
        locked = true;
        handler();
        setTimeout(() => {
            locked = false;
        }, 250);
    });
}

function addSprite(node: Node, spritePath: string): void {
    const sprite = node.addComponent(Sprite);
    sprite.sizeMode = Sprite.SizeMode.CUSTOM;
    sprite.type = Sprite.Type.SIMPLE;
    sprite.trim = false;
    const base = spritePath.replace(/\.(png|jpg|jpeg|webp)$/i, '');
    imageStats.pending += 1;
    resources.load(`${base}/spriteFrame`, SpriteFrame, (err, frame) => {
        if (!err && frame) {
            showSprite(sprite, frame);
            return;
        }
        resources.load(base, ImageAsset, (imageErr, image) => {
            if (!imageErr && image) {
                showSprite(sprite, frameFromImage(image));
                return;
            }
            resources.load(`${base}/texture`, Texture2D, (textureErr, texture) => {
                if (!textureErr && texture) {
                    showSprite(sprite, frameFromTexture(texture));
                    return;
                }
                imageStats.pending -= 1;
                imageStats.missing += 1;
                console.warn('[hall] image missing', base, err || imageErr || textureErr);
                reportImages();
            });
        });
    });
}

function frameFromImage(image: ImageAsset): SpriteFrame {
    const texture = new Texture2D();
    texture.image = image;
    return frameFromTexture(texture);
}

function frameFromTexture(texture: Texture2D): SpriteFrame {
    const frame = new SpriteFrame();
    const width = texture.width || imageWidth(texture);
    const height = texture.height || imageHeight(texture);
    frame.reset({
        texture,
        rect: new Rect(0, 0, width, height),
        originalSize: new Size(width, height),
    });
    frame.packable = false;
    return frame;
}

function imageWidth(texture: Texture2D): number {
    return texture.image?.width || 0;
}

function imageHeight(texture: Texture2D): number {
    return texture.image?.height || 0;
}

function showSprite(sprite: Sprite, frame: SpriteFrame): void {
    imageStats.pending -= 1;
    if (!sprite.isValid) {
        reportImages();
        return;
    }
    const transform = sprite.node.getComponent(UITransform);
    const width = transform?.width || frame.rect.width;
    const height = transform?.height || frame.rect.height;
    sprite.sizeMode = Sprite.SizeMode.CUSTOM;
    sprite.spriteFrame = frame;
    transform?.setContentSize(width, height);
    imageStats.loaded += 1;
    reportImages();
}

function reportImages(): void {
    if (imageStats.pending === 0) {
        console.log(`[hall] images loaded ${imageStats.loaded}, missing ${imageStats.missing}`);
    }
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
