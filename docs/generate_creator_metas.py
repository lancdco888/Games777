#!/usr/bin/env python3
"""Generate minimal Cocos Creator .meta files for TypeScript sources."""
from __future__ import annotations

import json
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "creator-games777" / "assets"


def ensure_meta(path: Path, importer: str) -> None:
    meta = path.with_suffix(path.suffix + ".meta")
    if meta.exists():
        return
    data = {
        "ver": "4.0.24",
        "importer": importer,
        "imported": True,
        "uuid": str(uuid.uuid4()),
        "files": [],
        "subMetas": {},
        "userData": {},
    }
    meta.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print("meta", meta.relative_to(ROOT.parent))


def main() -> None:
    for d in sorted({p.parent for p in ROOT.rglob("*") if p.is_file() or p.is_dir()}):
        if d == ROOT:
            continue
        if not d.is_dir():
            continue
        # folder meta
        folder_meta = Path(str(d) + ".meta")
        if not folder_meta.exists() and ROOT in d.parents or d.parent == ROOT or ROOT in d.parents:
            if not folder_meta.exists():
                data = {
                    "ver": "1.2.0",
                    "importer": "directory",
                    "imported": True,
                    "uuid": str(uuid.uuid4()),
                    "files": [],
                    "subMetas": {},
                    "userData": {},
                }
                folder_meta.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
                print("dir ", folder_meta.relative_to(ROOT.parent))

    for ts in ROOT.rglob("*.ts"):
        if ts.name.endswith(".d.ts"):
            # still need meta for some setups; skip ambient
            continue
        ensure_meta(ts, "typescript")

    for scene in ROOT.rglob("*.scene"):
        ensure_meta(scene, "scene")


if __name__ == "__main__":
    main()
