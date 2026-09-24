#!/usr/bin/env python3
"""Read a FairyGUI .fui package and crop its atlas sprites into PNGs.

The binary matches FairyGUI-unity UIPackage.LoadPackage / ByteBuffer:
big-endian, version >= 2, string table in block 4.
"""

from __future__ import annotations

import gzip
import io
import json
import struct
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parents[1] / "assets/resources/game270"

IMAGE, MOVIE, SOUND, COMPONENT, ATLAS, FONT = 0, 1, 2, 3, 4, 5
TYPE_NAME = {
    0: "image",
    1: "movie",
    2: "sound",
    3: "component",
    4: "atlas",
    5: "font",
    6: "swf",
    7: "misc",
    8: "unknown",
    9: "spine",
    10: "dragonbones",
}


class Buffer:
    def __init__(self, data: bytes):
        self.data = data
        self.pos = 0
        self.version = 0
        self.strings: list[str] = []

    def skip(self, count: int) -> None:
        self.pos += count

    def u8(self) -> int:
        value = self.data[self.pos]
        self.pos += 1
        return value

    def bool(self) -> bool:
        return self.u8() == 1

    def i16(self) -> int:
        value = struct.unpack_from(">h", self.data, self.pos)[0]
        self.pos += 2
        return value

    def u16(self) -> int:
        return self.i16() & 0xFFFF

    def i32(self) -> int:
        value = struct.unpack_from(">i", self.data, self.pos)[0]
        self.pos += 4
        return value

    def u32(self) -> int:
        return self.i32() & 0xFFFFFFFF

    def string(self, length: int | None = None) -> str:
        if length is None:
            length = self.u16()
        raw = self.data[self.pos : self.pos + length]
        self.pos += length
        return raw.decode("utf-8")

    def s(self) -> str | None:
        index = self.u16()
        if index == 65534:
            return None
        if index == 65533:
            return ""
        return self.strings[index]

    def s_array(self, count: int) -> list[str | None]:
        return [self.s() for _ in range(count)]

    def seek(self, index_pos: int, block: int) -> bool:
        saved = self.pos
        self.pos = index_pos
        seg_count = self.u8()
        if block >= seg_count:
            self.pos = saved
            return False
        use_short = self.u8() == 1
        self.pos += (2 if use_short else 4) * block
        new_pos = self.i16() if use_short else self.i32()
        if new_pos > 0:
            self.pos = index_pos + new_pos
            return True
        self.pos = saved
        return False


def load_package(path: Path) -> dict:
    buf = Buffer(path.read_bytes())
    if buf.u32() != 0x46475549:
        raise ValueError(f"{path} is not a FairyGUI package")
    buf.version = buf.i32()
    buf.bool()
    package_id = buf.string()
    package_name = buf.string()
    buf.skip(20)
    index_pos = buf.pos

    if not buf.seek(index_pos, 4):
        raise ValueError("missing string table")
    buf.strings = [buf.string() for _ in range(buf.i32())]
    if buf.seek(index_pos, 5):
        for _ in range(buf.i32()):
            index = buf.u16()
            length = buf.i32()
            buf.strings[index] = buf.string(length)

    dependencies = []
    buf.seek(index_pos, 0)
    for _ in range(buf.i16()):
        dependencies.append({"id": buf.s(), "name": buf.s()})
    if buf.version >= 2:
        branch_count = buf.i16()
        if branch_count > 0:
            buf.s_array(branch_count)

    items: dict[str, dict] = {}
    order: list[dict] = []
    buf.seek(index_pos, 1)
    for _ in range(buf.i16()):
        next_pos = buf.i32() + buf.pos
        item = {
            "type": buf.u8(),
            "id": buf.s(),
            "name": buf.s(),
            "path": buf.s(),
            "file": buf.s(),
            "exported": buf.bool(),
            "width": buf.i32(),
            "height": buf.i32(),
        }
        kind = item["type"]
        if kind == IMAGE:
            scale = buf.u8()
            if scale == 1:
                buf.skip(20)
            item["smoothing"] = buf.bool()
        elif kind == MOVIE:
            buf.bool()
            raw_len = buf.i32()
            item["raw"] = bytes(buf.data[buf.pos : buf.pos + raw_len])
            buf.skip(raw_len)
        elif kind == FONT:
            buf.skip(buf.i32())
        elif kind == COMPONENT:
            buf.u8()
            buf.skip(buf.i32())
        elif kind in (9, 10):
            buf.skip(8)
        if buf.version >= 2 and buf.pos < next_pos:
            branch = buf.s()
            if branch:
                item["name"] = f"{branch}/{item['name']}"
            branch_count = buf.u8()
            if branch_count > 0:
                buf.s_array(branch_count)
            high_count = buf.u8()
            if high_count > 0:
                buf.s_array(high_count)
        item["typeName"] = TYPE_NAME.get(kind, str(kind))
        items[item["id"]] = item
        order.append(item)
        buf.pos = next_pos

    sprites = []
    sprites_by_id: dict[str, dict] = {}
    buf.seek(index_pos, 2)
    for _ in range(buf.i16()):
        next_pos = buf.u16() + buf.pos
        item_id = buf.s()
        atlas_id = buf.s()
        rect = (buf.i32(), buf.i32(), buf.i32(), buf.i32())
        rotated = buf.bool()
        offset = (0, 0)
        original = (rect[3], rect[2]) if rotated else (rect[2], rect[3])
        if buf.version >= 2 and buf.bool():
            offset = (buf.i32(), buf.i32())
            original = (buf.i32(), buf.i32())
        owner = items.get(item_id or "", {})
        atlas = items.get(atlas_id or "", {})
        sprite = {
            "id": item_id,
            "name": owner.get("name") or item_id,
            "atlas": atlas.get("file"),
            "rect": rect,
            "rotated": rotated,
            "offset": offset,
            "original": original,
        }
        sprites.append(sprite)
        if item_id:
            sprites_by_id[item_id] = sprite
        buf.pos = next_pos

    return {
        "id": package_id,
        "name": package_name,
        "version": buf.version,
        "folder": path.parent,
        "dependencies": dependencies,
        "items": order,
        "sprites": sprites,
        "spritesById": sprites_by_id,
        "strings": buf.strings,
    }


def movie_frames(raw: bytes, strings: list[str]) -> list[str]:
    """Sprite ids for each frame. Block 1 of a movie clip."""
    buf = Buffer(raw)
    buf.version = 6
    buf.strings = strings
    if not buf.seek(0, 1):
        return []
    frames = []
    for _ in range(buf.i16()):
        next_pos = buf.u16() + buf.pos
        buf.skip(16)
        buf.i32()
        frames.append(buf.s() or "")
        buf.pos = next_pos
    return frames


def open_atlas(folder: Path, file_name: str) -> Image.Image:
    path = folder / file_name
    raw = path.read_bytes()
    if raw[:2] == b"\x1f\x8b":
        raw = gzip.decompress(raw)
    return Image.open(io.BytesIO(raw)).convert("RGBA")


def crop_sprite(atlas: Image.Image, sprite: dict) -> Image.Image:
    x, y, w, h = sprite["rect"]
    image = atlas.crop((x, y, x + w, y + h))
    if sprite["rotated"]:
        image = image.transpose(Image.Transpose.ROTATE_90)
    return image


def safe_name(name: str) -> str:
    cleaned = "".join(ch if ch.isalnum() or ch in "-_" else "_" for ch in name)
    return cleaned.strip("_") or "sprite"


def sprite_image(package: dict, sprite: dict, cache: dict[str, Image.Image]) -> Image.Image:
    atlas_file = sprite["atlas"]
    disk_name = f"{package['name']}_{atlas_file}"
    if disk_name not in cache:
        cache[disk_name] = open_atlas(package["folder"], disk_name)
    return crop_sprite(cache[disk_name], sprite)


def save_unique(image: Image.Image, out_dir: Path, name: str, used: dict[str, int]) -> str:
    base = safe_name(name)
    used[base] = used.get(base, 0) + 1
    if used[base] > 1:
        base = f"{base}_{used[base]}"
    image.save(out_dir / f"{base}.png", "PNG")
    return base


# Reel symbols in SymbolConfig order, plus the board art the local screen draws.
SYMBOL_SOURCES = {
    "wild": ("Wild1UP_Loop", "slots_345_wild"),
    "scatter": ("Scatter", "scatter"),
    "lantern": ("slots_symbol_denglong",),
    "pic1": ("Pic1_0000", "pic1"),
    "pic2": ("Pic2_0000", "pic2"),
    "pic3": ("Pic3_Intro", "pic3"),
    "pic4": ("Pic4_0000", "pic4"),
    "sl1": ("slots_345_sl1",),
    "sl2": ("slots_345_sl2",),
    "sl3": ("slots_345_sl3",),
    "sl4": ("slots_345_sl4",),
    "sl5": ("slots_345_sl5",),
    "bg": ("slots_270_background_ng",),
    "frame": ("slots_270_frame_01",),
    "kuang": ("kuang",),
}

SOUND_SOURCES = {
    "reelstop": "slots_321_reelstop",
    "wild": "SND_Wild",
    "scatter": "SND_Scatter",
    "pic1": "SND_Pic1",
    "win": "SND_ExpandWin",
}


def find_item(package: dict, name: str) -> dict | None:
    for item in package["items"]:
        if item["name"] == name:
            return item
    return None


def resolve_art(package: dict, names: tuple[str, ...], cache: dict[str, Image.Image]) -> Image.Image | None:
    by_id = package["spritesById"]
    for name in names:
        item = find_item(package, name)
        if not item:
            continue
        if item["type"] == IMAGE and item["id"] in by_id:
            return sprite_image(package, by_id[item["id"]], cache)
        if item["type"] == MOVIE and item.get("raw"):
            for sprite_id in movie_frames(item["raw"], package["strings"]):
                sprite = by_id.get(sprite_id)
                if sprite and sprite["rect"][2] > 8 and sprite["rect"][3] > 8:
                    return sprite_image(package, sprite, cache)
    return None


def copy_sound(package: dict, item_name: str, dest: Path) -> bool:
    item = find_item(package, item_name)
    if not item or not item.get("file"):
        return False
    source = package["folder"] / f"{package['name']}_{item['file']}"
    if not source.exists():
        return False
    dest.write_bytes(source.read_bytes())
    return True


def export_package(fui: Path, out_dir: Path) -> dict:
    package = load_package(fui)
    out_dir.mkdir(parents=True, exist_ok=True)
    art_dir = out_dir / "art"
    audio_dir = out_dir / "audio"
    art_dir.mkdir(exist_ok=True)
    audio_dir.mkdir(exist_ok=True)
    cache: dict[str, Image.Image] = {}
    used: dict[str, int] = {}
    written = []
    for item in package["items"]:
        if item["type"] != IMAGE or item["id"] not in package["spritesById"]:
            continue
        image = sprite_image(package, package["spritesById"][item["id"]], cache)
        base = save_unique(image, art_dir, item["name"], used)
        written.append({"name": item["name"], "file": f"game270/art/{base}.png", "width": image.width, "height": image.height})

    symbols = {}
    for key, names in SYMBOL_SOURCES.items():
        image = resolve_art(package, names, cache)
        if image is None:
            print("missing", key, names)
            continue
        image.save(out_dir / f"{key}.png", "PNG")
        symbols[key] = {"file": f"game270/{key}.png", "width": image.width, "height": image.height}

    sounds = {}
    for key, name in SOUND_SOURCES.items():
        dest = audio_dir / f"{key}.mp3"
        if copy_sound(package, name, dest):
            sounds[key] = f"game270/audio/{key}.mp3"
        else:
            # Keep the original package sound beside the screen when the short name differs.
            item = find_item(package, name)
            print("missing sound", key, name, item["file"] if item else None)

    for item in package["items"]:
        if item["type"] != SOUND or not item.get("file"):
            continue
        dest = audio_dir / f"{safe_name(item['name'])}.mp3"
        if not dest.exists():
            copy_sound(package, item["name"], dest)

    manifest = {
        "package": package["name"],
        "id": package["id"],
        "dependencies": package["dependencies"],
        "symbols": symbols,
        "sounds": sounds,
        "images": written,
    }
    (out_dir / "sprites.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    return manifest


def main() -> None:
    fui = ROOT / "FGame270/res/Game270/Game270.fui"
    manifest = export_package(fui, OUT)
    print("images", len(manifest["images"]), "symbols", list(manifest["symbols"]), "sounds", manifest["sounds"])


if __name__ == "__main__":
    main()
