#!/usr/bin/env python3
"""Crop Game 270 win movies and the payline pieces used by WinLines."""

from __future__ import annotations

import json
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from export_fgui import Buffer, copy_sound, crop_sprite, load_package, open_atlas, sprite_image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "creator-hall/assets/resources/game270"
GAME = ROOT / "FGame270/res/Game270/Game270.fui"
BASICS = ROOT / "FGameCommon/res/Basics/Basics.fui"

MOVIES = [
    ("wild", GAME, "Wild1UP_Loop"),
    ("scatter", GAME, "Scatter"),
    ("pic1", GAME, "Pic1_0000"),
    ("pic2", GAME, "Pic2_0000"),
    ("pic3", GAME, "Pic3_Intro"),
    ("pic4", GAME, "Pic4_0000"),
    ("coin", BASICS, "Ani_Clip_Gold2"),
]

LINES = [
    "slots_line_flat",
    "slots_line_head",
    "slots_line_short_down",
    "slots_line_short_up",
    "slots_line_long_down",
    "slots_line_long_up",
]


def movie_placed_frames(item: dict, package: dict, cache: dict) -> tuple[int, list[Image.Image]]:
    raw = item["raw"]
    buf = Buffer(raw)
    buf.version = 6
    buf.strings = package["strings"]
    if not buf.seek(0, 0):
        raise ValueError(item["name"])
    interval = buf.i32()
    buf.seek(0, 1)
    frames: list[Image.Image] = []
    box = Image.new("RGBA", (item["width"], item["height"]), (0, 0, 0, 0))
    for _ in range(buf.i16()):
        next_pos = buf.u16() + buf.pos
        x, y, width, height = buf.i32(), buf.i32(), buf.i32(), buf.i32()
        buf.i32()
        sprite_id = buf.s() or ""
        sprite = package["spritesById"][sprite_id]
        image = sprite_image(package, sprite, cache)
        if image.size != (width, height):
            image = image.resize((width, height), Image.Resampling.NEAREST)
        canvas = box.copy()
        canvas.paste(image, (x, y), image)
        frames.append(canvas)
        buf.pos = next_pos
    return interval, frames


def pack(frames: list[Image.Image], columns: int) -> Image.Image:
    cell_w, cell_h = frames[0].size
    rows = (len(frames) + columns - 1) // columns
    sheet = Image.new("RGBA", (columns * cell_w, rows * cell_h), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        sheet.paste(frame, ((index % columns) * cell_w, (index // columns) * cell_h))
    return sheet


def main() -> None:
    packages = {
        GAME: load_package(GAME),
        BASICS: load_package(BASICS),
    }
    cache: dict = {}
    fx = OUT / "fx"
    art = OUT / "art"
    audio = OUT / "audio"
    fx.mkdir(parents=True, exist_ok=True)
    movies = {}
    for key, fui, name in MOVIES:
        package = packages[fui]
        item = next(entry for entry in package["items"] if entry["name"] == name)
        interval, frames = movie_placed_frames(item, package, cache)
        columns = min(8, len(frames))
        sheet = pack(frames, columns)
        sheet.save(fx / f"{key}.png", "PNG")
        movies[key] = {
            "file": f"game270/fx/{key}",
            "count": len(frames),
            "columns": columns,
            "interval": interval / 1000,
            "width": item["width"],
            "height": item["height"],
        }
        print(key, len(frames), "frames", item["width"], item["height"], "interval", interval)

    basics = packages[BASICS]
    by_name = {item["name"]: item for item in basics["items"]}
    for name in LINES:
        item = by_name[name]
        image = sprite_image(basics, basics["spritesById"][item["id"]], cache)
        image.save(art / f"{name}.png", "PNG")
        print("line", name, image.size)

    for index in range(1, 17):
        clip = f"wintune{index:02d}"
        dest = audio / f"{clip}.mp3"
        if not copy_sound(basics, clip, dest):
            raise SystemExit(f"missing {clip}")
    manifest = {"movies": movies}
    (fx / "movies.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print("wrote", fx)


if __name__ == "__main__":
    main()
