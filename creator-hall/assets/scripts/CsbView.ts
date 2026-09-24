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
import { bitmapFont, layoutBitmap } from './BitmapFont';
import type { BitmapFont } from './BitmapFont';

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
    if (item.cls === 'TextBMFont' && mountBitmap(node, item.file || '', item.text || '')) {
        // Image glyphs from the original .fnt page.
    } else if (item.cls === 'Text' || item.cls === 'TextBMFont') {
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
    loadSpriteFrame(spritePath, (frame) => {
        if (!frame) {
            return;
        }
        showSprite(sprite, frame);
    });
}

/** Loads a resources image as a sprite frame. Creator may import it as a frame, image, or texture. */
export function loadSpriteFrame(spritePath: string, done: (frame: SpriteFrame | null) => void): void {
    const base = spritePath.replace(/\.(png|jpg|jpeg|webp)$/i, '');
    imageStats.pending += 1;
    resources.load(`${base}/spriteFrame`, SpriteFrame, (err, frame) => {
        if (!err && frame) {
            finishLoad(frame, done);
            return;
        }
        resources.load(base, ImageAsset, (imageErr, image) => {
            if (!imageErr && image) {
                finishLoad(frameFromImage(image), done);
                return;
            }
            resources.load(`${base}/texture`, Texture2D, (textureErr, texture) => {
                if (!textureErr && texture) {
                    finishLoad(frameFromTexture(texture), done);
                    return;
                }
                imageStats.pending -= 1;
                imageStats.missing += 1;
                console.warn('[hall] image missing', base, err || imageErr || textureErr);
                reportImages();
                done(null);
            });
        });
    });
}

function finishLoad(frame: SpriteFrame, done: (frame: SpriteFrame | null) => void): void {
    imageStats.pending -= 1;
    imageStats.loaded += 1;
    reportImages();
    done(frame);
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
    if (!sprite.isValid) {
        return;
    }
    const transform = sprite.node.getComponent(UITransform);
    const width = transform?.width || frame.rect.width;
    const height = transform?.height || frame.rect.height;
    sprite.sizeMode = Sprite.SizeMode.CUSTOM;
    sprite.spriteFrame = frame;
    transform?.setContentSize(width, height);
}

function reportImages(): void {
    if (imageStats.pending === 0) {
        console.log(`[hall] images loaded ${imageStats.loaded}, missing ${imageStats.missing}`);
    }
}

interface MountedBitmap {
    font: BitmapFont;
    text: string;
    frame: SpriteFrame | null;
    node: Node;
}

const mountedBitmaps = new WeakMap<Node, MountedBitmap>();
const glyphFrames = new Map<string, SpriteFrame>();

/** Draw a bitmap-font string into the node. Returns false when the file is not an image font. */
export function mountBitmap(node: Node, fileOrId: string, text: string): boolean {
    const font = bitmapFont(fileOrId);
    if (!font) {
        return false;
    }
    const state: MountedBitmap = { font, text, frame: null, node };
    mountedBitmaps.set(node, state);
    loadSpriteFrame(font.page, (frame) => {
        if (!frame || !node.isValid) {
            return;
        }
        state.frame = frame;
        redrawBitmap(state);
    });
    return true;
}

/** Update a node created by mountBitmap. Returns false for ordinary Labels. */
export function setBitmapText(node: Node | null | undefined, text: string): boolean {
    if (!node) {
        return false;
    }
    const state = mountedBitmaps.get(node);
    if (!state) {
        return false;
    }
    state.text = text;
    redrawBitmap(state);
    return true;
}

/** Number readout whose `.string` paints image glyphs instead of a system font. */
export class BitmapReadout {
    private value = '';
    node: Node;

    constructor(node: Node, fontId: string, text = '') {
        this.node = node;
        this.value = text;
        mountBitmap(node, fontId, text);
    }

    get string(): string {
        return this.value;
    }

    set string(value: string) {
        this.value = value;
        setBitmapText(this.node, value);
    }
}

function redrawBitmap(state: MountedBitmap): void {
    const node = state.node;
    if (!node.isValid) {
        return;
    }
    for (const child of [...node.children]) {
        if (child.name === 'bm') {
            child.destroy();
        }
    }
    if (!state.frame) {
        return;
    }
    const transform = node.getComponent(UITransform);
    const placed = layoutBitmap(
        state.font,
        state.text,
        transform?.width || 0,
        transform?.height || 0,
        transform?.anchorX ?? 0.5,
        transform?.anchorY ?? 0.5,
    );
    for (const glyph of placed) {
        const child = new Node('bm');
        child.layer = Layers.Enum.UI_2D;
        const ui = child.addComponent(UITransform);
        ui.setAnchorPoint(0.5, 0.5);
        child.setPosition(glyph.x, glyph.y, 0);
        child.setParent(node);
        const sprite = child.addComponent(Sprite);
        sprite.sizeMode = Sprite.SizeMode.CUSTOM;
        sprite.type = Sprite.Type.SIMPLE;
        sprite.trim = false;
        sprite.spriteFrame = cropGlyph(state.frame, state.font.id, glyph.ch, glyph.sx, glyph.sy, glyph.sw, glyph.sh);
        ui.setContentSize(glyph.w, glyph.h);
    }
}

function cropGlyph(base: SpriteFrame, fontId: string, ch: string, x: number, y: number, w: number, h: number): SpriteFrame {
    const key = `${fontId}:${ch}`;
    const cached = glyphFrames.get(key);
    if (cached) {
        return cached;
    }
    const frame = new SpriteFrame();
    frame.reset({
        texture: base.texture,
        rect: new Rect(x, y, w, h),
        originalSize: new Size(w, h),
    });
    frame.packable = false;
    glyphFrames.set(key, frame);
    return frame;
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
