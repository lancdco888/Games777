#!/usr/bin/env python3
"""Check the generated lobby layout, scene link, and sample player data."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LAYOUT = ROOT / "assets/resources/layout/LobbyLayer.json"
SAMPLE = ROOT / "assets/resources/layout/sample-lobby.json"
SCENE = ROOT / "assets/scenes/Lobby.scene"
SCRIPT_META = ROOT / "assets/scripts/LobbyApp.ts.meta"

BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"


def compress_uuid(uuid: str) -> str:
    """Scene components use Creator's non-min uuid, which keeps 5 hex characters."""
    hexv = uuid.replace("-", "")
    out = [hexv[:5]]
    index = 5
    while index < len(hexv):
        value = int(hexv[index : index + 3], 16)
        out.append(BASE64[value >> 6])
        out.append(BASE64[value & 63])
        index += 3
    return "".join(out)


def find(node, name):
    if node.get("name") == name:
        return node
    for child in node.get("children", []):
        found = find(child, name)
        if found:
            return found
    return None


def main():
    lobby = json.loads(LAYOUT.read_text(encoding="utf-8"))
    sample = json.loads(SAMPLE.read_text(encoding="utf-8"))
    scene = json.loads(SCENE.read_text(encoding="utf-8"))
    meta = json.loads(SCRIPT_META.read_text(encoding="utf-8"))

    panel = find(lobby, "panel")
    user_info = find(lobby, "user_info")
    game_list = find(lobby, "list")
    assert panel and user_info and game_list
    creator_x = user_info["x"] - panel["ax"] * panel["w"]
    creator_y = user_info["y"] - panel["ay"] * panel["h"]
    assert abs(creator_x + 640) < 0.2 and abs(creator_y - 360) < 0.2

    for name in ("lua_nickname", "lua_coin_num", "lua_safebox_num", "washcode_num", "url_text", "function_buttons"):
        assert find(lobby, name), name

    assert len(sample["games"]) == 13
    assert sample["games"][0]["id"] == 270
    assert sample["vipLevel"] > 0

    compressed = compress_uuid(meta["uuid"])
    assert compressed == "c4a1eeybTBPkZpYDns8kdSm"
    script = next(item for item in scene if item.get("__type__") == compressed)
    assert script["node"]["__id__"] == 4
    lobby_node = scene[4]
    assert lobby_node["_name"] == "Lobby"
    assert lobby_node["_components"][1]["__id__"] == scene.index(script)
    print(json.dumps({"nodes": "ok", "script": compressed, "games": len(sample["games"])}))


if __name__ == "__main__":
    main()
