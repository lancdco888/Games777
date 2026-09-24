#!/usr/bin/env python3
"""Read Cocos Studio CSB files and emit a Creator-ready lobby layout plus a preview image."""

import gzip
import io
import json
import re
import struct
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
STUDIO = ROOT / "hall/res/studio"
OUT = Path(__file__).resolve().parents[1]
RES_OUT = OUT / "assets/resources/hall"
LAYOUT_OUT = OUT / "assets/resources/layout"
PREVIEW = OUT / "preview/lobby-preview.png"

WIDGET_FILE = {
    "Button": 6,
    "ImageView": 6,
    "Sprite": 6,
    "TextBMFont": 6,
    "Panel": 6,
    "LoadingBar": 6,
    "Slider": 6,
    "CheckBox": 6,
}


class Csb:
    def __init__(self, path: Path):
        self.data = path.read_bytes()
        self.n = len(self.data)

    def u32(self, off):
        return struct.unpack_from("<I", self.data, off)[0]

    def i32(self, off):
        return struct.unpack_from("<i", self.data, off)[0]

    def u16(self, off):
        return struct.unpack_from("<H", self.data, off)[0]

    def f32(self, off):
        return struct.unpack_from("<f", self.data, off)[0]

    def fields(self, pos):
        vt = pos - self.i32(pos)
        if not (0 <= vt <= self.n - 4):
            return {}
        vsize = self.u16(vt)
        if not 4 <= vsize <= 200 or vt + vsize > self.n:
            return {}
        return {vo: self.u16(vt + vo) for vo in range(4, vsize, 2)}

    def slot(self, pos, vo):
        rel = self.fields(pos).get(vo, 0)
        return None if not rel else pos + rel

    def get_str(self, pos, vo):
        p = self.slot(pos, vo)
        if p is None or p + 4 > self.n:
            return None
        start = p + self.u32(p)
        if start + 4 > self.n:
            return None
        length = self.u32(start)
        if length > 2000 or start + 4 + length > self.n:
            return None
        return self.data[start + 4 : start + 4 + length].decode("utf-8", "replace")

    def get_tbl(self, pos, vo):
        p = self.slot(pos, vo)
        if p is None or p + 4 > self.n:
            return None
        table = p + self.u32(p)
        if not 0 < table < self.n - 4:
            return None
        return table

    def get_vec(self, pos, vo):
        p = self.slot(pos, vo)
        if p is None or p + 4 > self.n:
            return []
        vec = p + self.u32(p)
        if not 0 <= vec <= self.n - 4:
            return []
        count = self.u32(vec)
        if count > 2000 or vec + 4 + count * 4 > self.n:
            return []
        items = []
        for i in range(count):
            ptr = vec + 4 + i * 4
            items.append(ptr + self.u32(ptr))
        return items

    def resource(self, table, vo):
        res = self.get_tbl(table, vo)
        if not res:
            return None
        path = self.get_str(res, 4)
        if not path or path.startswith("Default/"):
            return None
        return path.replace("\\", "/")

    def node(self, pos):
        cls = self.get_str(pos, 4) or "Node"
        options = self.get_tbl(pos, 8)
        data = self.get_tbl(options, 4) if options else None
        widget = self.get_tbl(data, 4) if data else None
        item = {
            "cls": cls,
            "name": cls,
            "x": 0.0,
            "y": 0.0,
            "w": 0.0,
            "h": 0.0,
            "ax": 0.5,
            "ay": 0.5,
            "visible": True,
            "file": None,
            "text": None,
            "children": [],
        }
        if widget:
            item["name"] = self.get_str(widget, 4) or cls
            pos_s = self.slot(widget, 18)
            scale = self.slot(widget, 20)
            anchor = self.slot(widget, 22)
            size = self.slot(widget, 26)
            vis = self.slot(widget, 12)
            if pos_s:
                item["x"] = round(self.f32(pos_s), 2)
                item["y"] = round(self.f32(pos_s + 4), 2)
            if scale:
                item["sx"] = round(self.f32(scale), 3)
                item["sy"] = round(self.f32(scale + 4), 3)
            if anchor:
                item["ax"] = round(self.f32(anchor), 3)
                item["ay"] = round(self.f32(anchor + 4), 3)
            if size:
                item["w"] = round(self.f32(size), 2)
                item["h"] = round(self.f32(size + 4), 2)
            if vis is not None and self.data[vis] == 0:
                item["visible"] = False
            item["layout"] = self.layout_info(widget)
        if data and cls in WIDGET_FILE:
            item["file"] = self.resource(data, WIDGET_FILE[cls])
        if data and cls == "Text":
            item["text"] = self.get_str(data, 12)
        if data and cls == "TextBMFont":
            item["text"] = self.get_str(data, 8)
        for child in self.get_vec(pos, 6):
            if 0 < child < self.n:
                item["children"].append(self.node(child))
        return item

    def layout_info(self, widget):
        lay = self.get_tbl(widget, 44)
        if not lay:
            return None

        def u8(vo):
            slot = self.slot(lay, vo)
            if slot is None or slot >= self.n:
                return 0
            return self.data[slot]

        def num(vo):
            slot = self.slot(lay, vo)
            if not slot:
                return 0.0
            return round(self.f32(slot), 4)

        info = {
            "px": bool(u8(4)),
            "py": bool(u8(6)),
            "xp": num(8),
            "yp": num(10),
            "sw": bool(u8(12)),
            "sh": bool(u8(14)),
            "wp": num(16),
            "hp": num(18),
            "hx": self.get_str(lay, 24) or "",
            "vy": self.get_str(lay, 26) or "",
            "left": num(28),
            "right": num(30),
            "top": num(32),
            "bottom": num(34),
        }
        if not any(info[key] for key in ("px", "py", "sw", "sh", "hx", "vy")):
            return None
        return info

    def tree(self):
        root = self.u32(0)
        node = self.get_tbl(root, 10)
        tree = self.node(node)
        tree["name"] = tree["name"] if tree["name"] != "Node" else "Layer"
        tree["w"] = tree["w"] or 1280
        tree["h"] = tree["h"] or 720
        tree["ax"] = 0
        tree["ay"] = 0
        return tree


def load_plist(path: Path):
    frames = {}
    if not path.is_file():
        return None, frames
    root = ET.parse(path).getroot()
    dicts = list(root.iter("dict"))
    # Top metadata and frames live in the first dict's key/value pairs.
    top = dicts[0]
    kids = list(top)
    mapping = {}
    i = 0
    while i < len(kids) - 1:
        if kids[i].tag == "key":
            mapping[kids[i].text] = kids[i + 1]
            i += 2
        else:
            i += 1
    frames_dict = mapping.get("frames")
    meta = mapping.get("metadata")
    texture = "common.png"
    if meta is not None:
        mk = list(meta)
        j = 0
        while j < len(mk) - 1:
            if mk[j].tag == "key" and mk[j].text in ("textureFileName", "realTextureFileName"):
                texture = mk[j + 1].text
            j += 1
    if frames_dict is not None:
        fk = list(frames_dict)
        j = 0
        while j < len(fk) - 1:
            if fk[j].tag == "key" and fk[j + 1].tag == "dict":
                info = {}
                inner = list(fk[j + 1])
                k = 0
                while k < len(inner) - 1:
                    if inner[k].tag == "key":
                        info[inner[k].text] = inner[k + 1].text
                    k += 1
                match = re.match(r"\{\{(\d+),(\d+)\},\{(\d+),(\d+)\}\}", info.get("frame", ""))
                if match:
                    x, y, w, h = map(int, match.groups())
                    frames[fk[j].text.replace("\\", "/")] = {
                        "x": x,
                        "y": y,
                        "w": w,
                        "h": h,
                        "rotated": info.get("rotated") == "true",
                        "texture": texture,
                        "plist": path,
                    }
            j += 1
    return path.parent / texture, frames


PLISTS = {}
for plist in STUDIO.rglob("*.plist"):
    tex, frames = load_plist(plist)
    if tex and frames:
        PLISTS[str(plist.relative_to(STUDIO))] = (tex, frames)


def resolve_file(rel: str):
    if not rel:
        return None
    direct = [
        STUDIO / rel,
        STUDIO / "mm" / rel,
    ]
    for candidate in direct:
        if candidate.is_file():
            return ("file", candidate)
    for _plist, (tex, frames) in PLISTS.items():
        if rel in frames and tex.is_file():
            return ("atlas", tex, frames[rel])
    return None


def open_image(path: Path) -> Image.Image:
    raw = path.read_bytes()
    if raw[:2] == b"\x1f\x8b":
        raw = gzip.decompress(raw)
    return Image.open(io.BytesIO(raw)).convert("RGBA")


def export_image(rel: str, cache: dict):
    if not rel:
        return None
    if rel in cache:
        return cache[rel]
    found = resolve_file(rel)
    if not found or Path(rel).suffix.lower() not in {".png", ".jpg", ".jpeg", ".webp"}:
        cache[rel] = None
        return None
    dest_rel = Path("hall") / rel
    dest = RES_OUT / rel
    dest.parent.mkdir(parents=True, exist_ok=True)
    if found[0] == "file":
        image = open_image(found[1])
    else:
        _kind, tex, frame = found
        image = open_image(tex)
        x, y, w, h = frame["x"], frame["y"], frame["w"], frame["h"]
        if frame["rotated"]:
            image = image.crop((x, y, x + h, y + w)).transpose(Image.ROTATE_90)
        else:
            image = image.crop((x, y, x + w, y + h))
    image.save(dest)
    cache[rel] = str(dest_rel).replace("\\", "/")
    return cache[rel]


def apply_layout(node, parent_w, parent_h):
    lay = node.get("layout") or {}
    if lay.get("sw") and parent_w:
        node["w"] = round(lay["wp"] * parent_w, 2)
    if lay.get("sh") and parent_h:
        node["h"] = round(lay["hp"] * parent_h, 2)
    if lay.get("px") and parent_w:
        node["x"] = round(lay["xp"] * parent_w, 2)
    if lay.get("py") and parent_h:
        node["y"] = round(lay["yp"] * parent_h, 2)
    edge_x = lay.get("hx") or ""
    edge_y = lay.get("vy") or ""
    if edge_x == "LeftEdge":
        node["x"] = round(lay["left"] + node["ax"] * node["w"], 2)
    elif edge_x == "RightEdge" and parent_w:
        node["x"] = round(parent_w - lay["right"] - (1 - node["ax"]) * node["w"], 2)
    elif edge_x == "BothEdge" and parent_w:
        left = lay["left"]
        width = max(1.0, parent_w - lay["left"] - lay["right"])
        node["w"] = round(width, 2)
        node["x"] = round(left + node["ax"] * width, 2)
    if edge_y == "BottomEdge":
        node["y"] = round(lay["bottom"] + node["ay"] * node["h"], 2)
    elif edge_y == "TopEdge" and parent_h:
        node["y"] = round(parent_h - lay["top"] - (1 - node["ay"]) * node["h"], 2)
    elif edge_y == "BothEdge" and parent_h:
        bottom = lay["bottom"]
        height = max(1.0, parent_h - lay["top"] - lay["bottom"])
        node["h"] = round(height, 2)
        node["y"] = round(bottom + node["ay"] * height, 2)
    for child in node["children"]:
        apply_layout(child, node["w"], node["h"])


def collect_files(node, cache):
    if node.get("file"):
        node["sprite"] = export_image(node["file"], cache)
    for child in node["children"]:
        collect_files(child, cache)


def render(node, image, ox, oy, missing):
    if not node.get("visible", True):
        return
    ax = node.get("ax", 0.5)
    ay = node.get("ay", 0.5)
    left = ox + node["x"] - ax * node["w"]
    bottom = oy + node["y"] - ay * node["h"]
    sprite = node.get("sprite")
    if sprite:
        path = RES_OUT / Path(sprite).relative_to("hall")
        if path.is_file():
            pic = open_image(path)
            if node["w"] > 1 and node["h"] > 1:
                pic = pic.resize((max(1, int(node["w"])), max(1, int(node["h"]))), Image.Resampling.LANCZOS)
            top = 720 - (bottom + pic.height)
            image.alpha_composite(pic, (int(round(left)), int(round(top))))
    elif node["cls"] in ("Text", "TextBMFont") and node.get("text"):
        draw = ImageDraw.Draw(image)
        top = 720 - (bottom + node["h"])
        draw.text((left, top), node["text"], fill=(255, 236, 170, 255))
    if node.get("file") and not sprite and not str(node["file"]).lower().endswith(".fnt"):
        missing.append(node["file"])
    for child in node["children"]:
        render(child, image, left, bottom, missing)


def find_parent_origin(node, target_name, ox=0.0, oy=0.0):
    ax = node.get("ax", 0.5)
    ay = node.get("ay", 0.5)
    left = ox + node["x"] - ax * node["w"]
    bottom = oy + node["y"] - ay * node["h"]
    for child in node["children"]:
        if child.get("name") == target_name:
            return left, bottom
        found = find_parent_origin(child, target_name, left, bottom)
        if found:
            return found
    return None


def set_visible(node, name, visible):
    if node.get("name") == name:
        node["visible"] = visible
    for child in node["children"]:
        set_visible(child, name, visible)


def export_game_catalog():
    text = (ROOT / "hall/src/common/const_game.lua").read_text(encoding="utf-8", errors="replace")
    blocks = re.findall(r"\[(\d+)\]\s*=\s*\{(.*?)\n\s*\},", text, re.S)
    catalog = {}
    for game_id, body in blocks:
        icon = re.search(r"\[const_game\.Icon\]\s*=\s*(\d+)", body)
        name = re.search(r"\[const_game\.Game_Name\]\s*=\s*TR\(\s*[\"'](.+?)[\"']", body)
        game_type = re.search(r"\[const_game\.Game_type\]\s*=\s*['\"]([^'\"]+)", body)
        catalog[int(game_id)] = {
            "id": int(game_id),
            "icon": int(icon.group(1)) if icon else int(game_id),
            "name": name.group(1) if name else str(game_id),
            "type": game_type.group(1) if game_type else "slot",
        }
    icon_out = RES_OUT / "lobby/icon"
    icon_out.mkdir(parents=True, exist_ok=True)
    sources = [ROOT / "hall/res/lobby/icon", ROOT / "hall/res/mm/language/lobby/icon"]
    copied = 0
    for index, folder in enumerate(sources):
        if not folder.is_dir():
            continue
        for src in folder.glob("*.png"):
            dest = icon_out / src.name
            if index > 0 and dest.is_file():
                continue
            open_image(src).save(dest)
            copied += 1
    sample = json.loads((LAYOUT_OUT / "sample-lobby.json").read_text(encoding="utf-8"))
    preferred = [item["id"] for item in sample.get("games", [])]
    available = {int(path.stem) for path in icon_out.glob("*.png")}
    ordered = []
    seen = set()
    for game_id in preferred + sorted(available):
        if game_id in seen or game_id not in available:
            continue
        seen.add(game_id)
        info = catalog.get(game_id) or {"id": game_id, "icon": game_id, "name": str(game_id), "type": "slot"}
        if info["icon"] not in available:
            info = dict(info)
            info["icon"] = game_id
        ordered.append(info)
    (LAYOUT_OUT / "games.json").write_text(json.dumps({"games": ordered}, ensure_ascii=False, indent=2), encoding="utf-8")
    return copied, len(ordered)


def draw_game_cards(canvas: Image.Image):
    small = ImageFont.truetype("/usr/share/fonts/truetype/wqy/wqy-microhei.ttc", 22)
    list_x, list_y, list_w, list_h = 20, 75, 1240, 570
    icon_h = list_h - 24
    icon_w = icon_h * 264 / 467
    cell_w = icon_w + 12
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    catalog = json.loads((LAYOUT_OUT / "games.json").read_text(encoding="utf-8"))["games"]
    for index, game in enumerate(catalog):
        x = list_x + index * cell_w + 8
        if x + icon_w > list_x + list_w:
            break
        bottom = list_y + 12
        top = int(round(720 - (bottom + icon_h)))
        icon_path = RES_OUT / "lobby/icon" / f"{game['icon']}.png"
        if icon_path.is_file():
            pic = open_image(icon_path).resize((int(icon_w), int(icon_h)), Image.Resampling.LANCZOS)
            overlay.alpha_composite(pic, (int(round(x)), top))
        else:
            draw.rounded_rectangle((x, top, x + icon_w, top + icon_h), radius=16, fill=(16, 36, 64, 230))
            draw.text((x + 12, top + icon_h / 2), game["name"], font=small, fill=(255, 236, 180, 255))
    mask = Image.new("L", canvas.size, 0)
    mask_draw = ImageDraw.Draw(mask)
    list_top = 720 - (list_y + list_h)
    mask_draw.rectangle((list_x, list_top, list_x + list_w, list_top + list_h), fill=255)
    clipped = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    clipped.paste(overlay, mask=mask)
    canvas.alpha_composite(clipped)


def main():
    RES_OUT.mkdir(parents=True, exist_ok=True)
    LAYOUT_OUT.mkdir(parents=True, exist_ok=True)
    PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    cache = {}
    layouts = {}
    for name in ("LobbyLayer", "GameItem"):
        src = STUDIO / "csb/LobbyLayer" / f"{name}.csb"
        tree = Csb(src).tree()
        apply_layout(tree, 1280, 720)
        collect_files(tree, cache)
        layouts[name] = tree
        (LAYOUT_OUT / f"{name}.json").write_text(json.dumps(tree, ensure_ascii=False, indent=2), encoding="utf-8")
    lobby = layouts["LobbyLayer"]
    canvas = Image.new("RGBA", (1280, 720), (12, 28, 48, 255))
    set_visible(lobby, "btn_return", False)
    missing = []
    render(lobby, canvas, 0, 0, missing)
    icons, game_count = export_game_catalog()
    draw_game_cards(canvas)
    buttons = None

    def grab(node):
        nonlocal buttons
        if node.get("name") == "function_buttons":
            buttons = node
        for child in node["children"]:
            grab(child)

    grab(lobby)
    origin = find_parent_origin(lobby, "function_buttons")
    if buttons and origin:
        render(buttons, canvas, origin[0], origin[1], missing)
    canvas.convert("RGB").save(PREVIEW, quality=90)
    panel = next(child for child in lobby["children"] if child["name"] == "panel")
    user_info = next(child for child in panel["children"] if child["name"] == "user_info")
    creator_x = user_info["x"] - panel["ax"] * panel["w"]
    creator_y = user_info["y"] - panel["ay"] * panel["h"]
    if abs(creator_x + 640) > 0.2 or abs(creator_y - 360) > 0.2:
        raise SystemExit(f"user_info position drifted: {creator_x}, {creator_y}")
    copied = sum(1 for v in cache.values() if v)
    absent = sorted(set(missing))
    print(json.dumps({"copied": copied, "icons": icons, "games": game_count, "missing": absent, "preview": str(PREVIEW), "userInfo": [creator_x, creator_y]}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
