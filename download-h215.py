# 双击仓库根目录的 download-h215.bat。
# 本脚本把 https://h215.vip 大厅和 https://game.m215gate.com 全部 H5 游戏
# 下载到脚本旁边的 h215-local 文件夹，然后在本机打开。
# 大厅地址必须是 http://127.0.0.1:8080 ，账号服务器才允许网页访问。
# 登录、余额、开奖仍然走原来的服务器，需要能上网。
# 脚本不读取、不保存账号、密码或 token。下过的文件会跳过，关掉窗口后可以再双击继续。
from __future__ import annotations

import argparse
import json
import mimetypes
import re
import sys
import threading
import time
import urllib.error
import urllib.request
import webbrowser
from concurrent.futures import ThreadPoolExecutor, as_completed
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

HALL_ORIGIN = "https://h215.vip"
GAME_ORIGIN = "https://game.m215gate.com"
GAME_HOST = "https://game.m215gate.com"
LOCAL_GAME_ORIGIN = "http://127.0.0.1:8081"
UA = "Mozilla/5.0"
LANGS = ["zh", "en", "my", "es", "ind", "pt", "vn", "th", "vi", "zh_CN", "my1", "es_MX"]
EXT = {
    "cc.AudioClip": ["mp3", "ogg", "wav", "m4a"],
    "cc.ImageAsset": ["png", "jpg", "jpeg", "webp"],
    "cc.BufferAsset": ["bin"],
    "cc.Asset": ["atlas", "bin", "json", "txt"],
    "cc.ParticleAsset": ["plist", "png"],
    "cc.TextAsset": ["txt", "json"],
    "cc.JsonAsset": ["json"],
    "sp.SkeletonData": ["bin", "json"],
}
BASE64_KEYS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
BASE64_VALUES = [64] * 128
for _i, _c in enumerate(BASE64_KEYS):
    BASE64_VALUES[ord(_c)] = _i
HEX = "0123456789abcdef"
UUID_TMPL = [""] * 8 + ["-"] + [""] * 4 + ["-"] + [""] * 4 + ["-"] + [""] * 4 + ["-"] + [""] * 12
UUID_SLOTS = [i for i, x in enumerate(UUID_TMPL) if x != "-"]
REF_RE = re.compile(
    r"""(?:(?:src|href)\s*=\s*|url\(\s*|["'])"""
    r"""(\.?\.?/?[A-Za-z0-9_./@+-]+\.(?:webmanifest|jpeg|json|wasm|html|webp|png|jpg|gif|svg|mp4|css|js|ico|txt))"""
    r"""(?![A-Za-z0-9])""",
    re.I,
)
PART_RE = re.compile(r"^[A-Za-z0-9_@.+-]+$")

mimetypes.add_type("application/javascript", ".js")
mimetypes.add_type("application/json", ".json")
mimetypes.add_type("application/wasm", ".wasm")
mimetypes.add_type("application/octet-stream", ".bin")
mimetypes.add_type("text/plain; charset=utf-8", ".atlas")
mimetypes.add_type("application/xml", ".plist")
mimetypes.add_type("video/mp4", ".mp4")


def decode_uuid(raw: str) -> str:
    base = raw.split("@", 1)[0]
    if len(base) != 22:
        return base
    out = UUID_TMPL[:]
    out[0] = base[0]
    out[1] = base[1]
    slot = 2
    for i in range(2, 22, 2):
        lhs = BASE64_VALUES[ord(base[i])]
        rhs = BASE64_VALUES[ord(base[i + 1])]
        out[UUID_SLOTS[slot]] = HEX[lhs >> 2]
        slot += 1
        out[UUID_SLOTS[slot]] = HEX[((lhs & 3) << 2) | (rhs >> 4)]
        slot += 1
        out[UUID_SLOTS[slot]] = HEX[rhs & 0xF]
        slot += 1
    return "".join(out)


def resolve_ref(base_rel: str, ref: str) -> str | None:
    ref = ref.split("#", 1)[0].split("?", 1)[0].strip()
    if not ref or ref.startswith(("data:", "http:", "https:", "//", "blob:", "javascript:")):
        return None
    if ref.startswith("/"):
        rel = ref[1:]
    else:
        parent = base_rel.rsplit("/", 1)[0] if "/" in base_rel else ""
        rel = f"{parent}/{ref}" if parent else ref
    parts: list[str] = []
    for part in rel.split("/"):
        if part in ("", "."):
            continue
        if part == "..":
            if not parts:
                return None
            parts.pop()
            continue
        if not PART_RE.fullmatch(part):
            return None
        parts.append(part)
    if not parts:
        return None
    return "/".join(parts)


def native_candidates(bundle: str, uid: str, file_hash: str, type_name: str) -> list[tuple[str, str]]:
    uuid = decode_uuid(uid.split("@", 1)[0])
    exts = EXT.get(type_name, ["bin"])
    found = []
    for ext in exts:
        rel = f"assets/{bundle}/native/{uuid[:2]}/{uuid}.{file_hash}.{ext}"
        found.append((f"{GAME_ORIGIN}/{rel}", rel))
    return found


def import_candidate(bundle: str, uid: str, file_hash: str) -> tuple[str, str]:
    short = uid.split("@", 1)[0]
    rel = f"assets/{bundle}/import/{short[:2]}/{short}.{file_hash}.json"
    return f"{GAME_ORIGIN}/{rel}", rel


def patch_text(text: str, game_port: int) -> str:
    local = f"http://127.0.0.1:{game_port}"
    return text.replace(GAME_HOST, local)


def self_check() -> int:
    wasm = decode_uuid("d2SmiAEh5MEYHkcc9bujX6")
    lua = decode_uuid("a95OSnyu5OrK+6wEptaTIV")
    if wasm != "d24a6880-121e-4c11-81e4-71cf5bba35fa":
        raise SystemExit(f"wasm uuid {wasm}")
    if lua != "a9e4e4a7-caee-4eac-afba-c04a6d693215":
        raise SystemExit(f"lua uuid {lua}")
    url, rel = native_candidates("resources", "d2SmiAEh5MEYHkcc9bujX6", "5d2fb", "cc.BufferAsset")[0]
    expect = "assets/resources/native/d2/d24a6880-121e-4c11-81e4-71cf5bba35fa.5d2fb.bin"
    if rel != expect or not url.endswith(expect):
        raise SystemExit(rel)
    imp, irel = import_candidate("Game270", "0e4dd7f7d", "4e061")
    if irel != "assets/Game270/import/0e/0e4dd7f7d.4e061.json":
        raise SystemExit(irel)
    if resolve_ref("src/import-map.af60e.json", "./../cocos-js/cc.b84aa.js") != "cocos-js/cc.b84aa.js":
        raise SystemExit("import map")
    if resolve_ref("src/settings.json", "../src/chunks/bundle.0e8c5.js") != "src/chunks/bundle.0e8c5.js":
        raise SystemExit("script package")
    sample = "go https://game.m215gate.com/index.html?gameid= api https://api.m215gate.com:443"
    patched = patch_text(sample, 8081)
    if "http://127.0.0.1:8081/index.html?gameid=" not in patched:
        raise SystemExit("patch game")
    if "https://api.m215gate.com:443" not in patched or "https://game.m215gate.com" in patched:
        raise SystemExit("patch api")
    print("self-check ok")
    return 0


class Log:
    def __init__(self, path: Path):
        self.path = path
        self.lock = threading.Lock()
        path.parent.mkdir(parents=True, exist_ok=True)

    def __call__(self, message: str) -> None:
        print(message, flush=True)
        with self.lock:
            with self.path.open("a", encoding="utf-8") as handle:
                handle.write(message + "\n")


def read_url(url: str, attempts: int = 4) -> bytes:
    last: Exception | None = None
    for attempt in range(attempts):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=60) as response:
                return response.read()
        except urllib.error.HTTPError as exc:
            if exc.code in (403, 404, 410):
                raise
            last = exc
        except Exception as exc:
            last = exc
        time.sleep(0.4 * (attempt + 1))
    assert last is not None
    raise last


def denied(data: bytes) -> bool:
    return data.startswith(b"<?xml") and b"AccessDenied" in data[:800]


def place(root: Path, rel: str) -> Path:
    return root.joinpath(*rel.split("/"))


def write_bytes(dest: Path, data: bytes) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp = dest.with_name(dest.name + ".part")
    tmp.write_bytes(data)
    tmp.replace(dest)


def save_one(url: str, dest: Path) -> tuple[str, int]:
    if dest.exists() and dest.stat().st_size > 0:
        return "skip", dest.stat().st_size
    data = read_url(url)
    if denied(data) or not data:
        raise PermissionError("denied")
    write_bytes(dest, data)
    return "ok", len(data)


def save_alts(options: list[tuple[str, Path]]) -> tuple[str, int]:
    for _url, dest in options:
        if dest.exists() and dest.stat().st_size > 0:
            return "skip", dest.stat().st_size
    last: Exception | None = None
    for url, dest in options:
        try:
            return save_one(url, dest)
        except Exception as exc:
            last = exc
    assert last is not None
    raise last


def code_of(exc: Exception) -> str:
    code = getattr(exc, "code", None)
    if code:
        return str(code)
    text = str(exc).strip() or exc.__class__.__name__
    return text[:80]


def download_many(jobs: list[tuple[str, list[tuple[str, Path]], bool]], workers: int, log: Log, label: str) -> dict[str, int]:
    stats = {"ok": 0, "skip": 0, "miss": 0, "absent": 0, "denied": 0}
    misses: list[str] = []
    lock = threading.Lock()
    done = 0

    def one(job: tuple[str, list[tuple[str, Path]], bool]) -> tuple[str, str]:
        name, options, required = job
        try:
            kind, _size = save_alts(options)
            return kind, name
        except Exception as exc:
            status = code_of(exc)
            if status in {"403", "denied"}:
                return "denied", name
            if not required and status == "404":
                return "absent", name
            return "miss", f"{status} {name}"

    if not jobs:
        return stats
    with ThreadPoolExecutor(max_workers=workers) as pool:
        futures = [pool.submit(one, job) for job in jobs]
        for future in as_completed(futures):
            kind, info = future.result()
            with lock:
                stats[kind] = stats.get(kind, 0) + 1
                done += 1
                if kind == "miss" and len(misses) < 20:
                    misses.append("失败 " + info)
                elif kind == "denied" and len(misses) < 20:
                    misses.append("源站拒绝 " + info)
                if done == len(jobs) or done % 200 == 0:
                    log(
                        f"{label} {done}/{len(jobs)} 新下 {stats['ok']} 跳过 {stats['skip']} "
                        f"失败 {stats['miss']} 源站拒绝 {stats['denied']}"
                    )
    for item in misses:
        log(item)
    return stats


def text_refs(text: str) -> list[str]:
    return REF_RE.findall(text)


def is_asset_path(path: str) -> bool:
    return bool(re.search(r"\.(?:png|jpg|jpeg|webp|gif|svg|js|css|ico|webmanifest)$", path, re.I))


def hall_paths(text: str) -> tuple[set[str], set[str]]:
    files: set[str] = set()
    prefixes: set[str] = set()
    for match in re.findall(r"""["'](/(?:images|assets)/[^"']+)["']""", text):
        path = match.split("#", 1)[0].split("?", 1)[0]
        if is_asset_path(path):
            files.add(path)
    for match in re.findall(r"""url\(\s*["']?(/(?:images|assets)/[^"')\s]+)""", text, re.I):
        path = match.split("#", 1)[0].split("?", 1)[0]
        if is_asset_path(path):
            files.add(path)
    for match in re.findall(r"""["'](/images/[^"']+)["']\s*\+""", text):
        prefixes.add(match)
    for match in re.findall(r"""url\((/images/[^"')]+)["']\s*\+""", text):
        prefixes.add(match)
    return files, prefixes


def expand_prefix(prefix: str) -> list[str]:
    if prefix.endswith("/avatar/"):
        return [prefix + str(n) + ".png" for n in range(1, 41)]
    if prefix.endswith("/type/"):
        return [prefix + str(n) + ".png" for n in range(1, 16)]
    if prefix.endswith("/bonus/"):
        return [prefix + str(n) + ".png" for n in range(1, 9)]
    if prefix.endswith("/"):
        return []
    if prefix.endswith("coin_"):
        return [prefix + str(n) + ".png" for n in range(1, 13)]
    if prefix.endswith("vip_0"):
        return [prefix + str(n) + ".png" for n in range(0, 16)]
    if prefix.endswith("_"):
        return [prefix + lang + ".png" for lang in LANGS]
    return []


def rel_job(origin: str, root: Path, rel: str, required: bool) -> tuple[str, list[tuple[str, Path]], bool]:
    clean = rel.lstrip("/")
    return clean, [(f"{origin}/{clean}", place(root, clean))], required


def download_hall(root: Path, workers: int, log: Log) -> None:
    log("开始下载大厅 https://h215.vip")
    hall = root / "hall"
    jobs: list[tuple[str, list[tuple[str, Path]], bool]] = []
    queued: set[str] = set()

    def add(rel: str, required: bool) -> None:
        clean = resolve_ref("index.html", rel) if not rel.startswith("/") else rel.lstrip("/")
        if not clean or clean in queued:
            return
        queued.add(clean)
        jobs.append(rel_job(HALL_ORIGIN, hall, clean, required))

    for rel in [
        "index.html", "sw.js", "registerSW.js", "manifest.webmanifest",
        "favicon.ico", "apple-touch-icon-192x192.png", "NoSleep.min.js",
    ]:
        add(rel, rel in {"index.html", "sw.js", "registerSW.js", "manifest.webmanifest", "NoSleep.min.js"})
    download_many(jobs, workers, log, "大厅页面")

    index = hall / "index.html"
    if not index.exists():
        raise RuntimeError("大厅首页没有下下来，请检查网络后重新双击。")
    more: list[tuple[str, list[tuple[str, Path]], bool]] = []
    queued_more: set[str] = set()

    def add_more(rel: str, required: bool) -> None:
        if not rel or rel in queued or rel in queued_more:
            return
        queued_more.add(rel)
        more.append(rel_job(HALL_ORIGIN, hall, rel, required))

    for ref in text_refs(index.read_text(encoding="utf-8", errors="replace")):
        rel = resolve_ref("index.html", ref)
        if rel:
            add_more(rel, True)
    sw = hall / "sw.js"
    if sw.exists():
        sw_text = sw.read_text(encoding="utf-8", errors="replace")
        for match in re.findall(r'url:"([^"]+)"', sw_text):
            rel = resolve_ref("sw.js", match)
            if rel:
                add_more(rel, True)
        box = re.search(r"workbox-[A-Za-z0-9]+", sw_text)
        if box:
            name = box.group(0)
            if not name.endswith(".js"):
                name += ".js"
            add_more(name, True)
    download_many(more, workers, log, "大厅脚本")

    images: set[str] = set()
    prefixes: set[str] = set()
    for path in hall.rglob("*"):
        if path.suffix.lower() not in {".js", ".css", ".html", ".webmanifest"} or not path.is_file():
            continue
        if path.stat().st_size > 8_000_000:
            continue
        found, prefs = hall_paths(path.read_text(encoding="utf-8", errors="replace"))
        images.update(found)
        prefixes.update(prefs)
    image_jobs = []
    seen_img: set[str] = set()
    for path in sorted(images):
        rel = path.lstrip("/")
        if rel and rel not in seen_img:
            seen_img.add(rel)
            image_jobs.append(rel_job(HALL_ORIGIN, hall, rel, True))
    optional = []
    for prefix in sorted(prefixes):
        for path in expand_prefix(prefix):
            rel = path.lstrip("/")
            if rel not in seen_img:
                seen_img.add(rel)
                optional.append(rel_job(HALL_ORIGIN, hall, rel, False))
    log(f"大厅图片 {len(image_jobs)} 个固定地址，{len(optional)} 个语言或编号尝试")
    download_many(image_jobs + optional, workers, log, "大厅图片")


def queue_game_refs(game: Path, rel: str, jobs: list, queued: set[str]) -> None:
    path = place(game, rel)
    if not path.exists() or path.stat().st_size > 250_000:
        return
    if path.suffix.lower() not in {".html", ".css", ".js"}:
        return
    if path.name.startswith("cc."):
        return
    text = path.read_text(encoding="utf-8", errors="replace")
    for ref in text_refs(text):
        child = resolve_ref(rel, ref)
        if child and child not in queued:
            queued.add(child)
            jobs.append(rel_job(GAME_ORIGIN, game, child, True))


def download_game_shell(root: Path, workers: int, log: Log) -> dict:
    log("开始下载游戏页面 https://game.m215gate.com")
    game = root / "game"
    seeds = [
        "index.html", "game.html", "style.css", "sw.js", "icon.png",
        "logo.png", "logo.mp4", "hand_tips.png", "index.appcache", "game.appcache",
    ]
    queued = set(seeds)
    jobs = [rel_job(GAME_ORIGIN, game, rel, rel in {"index.html", "game.html"}) for rel in seeds]
    download_many(jobs, workers, log, "游戏页面")
    if not (game / "game.html").exists() or not (game / "index.html").exists():
        raise RuntimeError("游戏页面没有下下来，请检查网络后重新双击。")

    follow = []
    for rel in list(queued):
        queue_game_refs(game, rel, follow, queued)
    download_many(follow, workers, log, "游戏脚本")
    follow2 = []
    for rel in [job[0] for job in follow]:
        queue_game_refs(game, rel, follow2, queued)
    download_many(follow2, workers, log, "游戏引擎入口")

    settings_rel = None
    for path in game.glob("application*.js"):
        match = re.search(r"settingsPath\s*=\s*'([^']+)'", path.read_text(encoding="utf-8", errors="replace"))
        if match:
            settings_rel = resolve_ref(path.name, match.group(1))
    if not settings_rel:
        raise RuntimeError("没有找到游戏 settings 文件。")
    download_many([rel_job(GAME_ORIGIN, game, settings_rel, True)], workers, log, "游戏配置表")
    settings_path = place(game, settings_rel)
    if not settings_path.exists():
        raise RuntimeError("游戏配置表下载失败。")
    settings = json.loads(settings_path.read_text(encoding="utf-8"))
    extra = []
    for name in (settings.get("plugins") or {}).get("jsList") or []:
        rel = resolve_ref("src/file.json", name)
        if rel and rel not in queued:
            queued.add(rel)
            extra.append(rel_job(GAME_ORIGIN, game, rel, True))
    for name in (settings.get("scripting") or {}).get("scriptPackages") or []:
        rel = resolve_ref("src/file.json", name)
        if rel and rel not in queued:
            queued.add(rel)
            extra.append(rel_job(GAME_ORIGIN, game, rel, True))
    import_maps = list(game.glob("src/import-map*.json"))
    for path in import_maps:
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            continue
        rel_base = path.relative_to(game).as_posix()
        for ref in (data.get("imports") or {}).values():
            rel = resolve_ref(rel_base, ref)
            if rel and rel not in queued:
                queued.add(rel)
                extra.append(rel_job(GAME_ORIGIN, game, rel, True))
    versions = (settings.get("assets") or {}).get("bundleVers") or {}
    for bundle, ver in versions.items():
        rel = f"assets/{bundle}/config.{ver}.json"
        extra.append(rel_job(GAME_ORIGIN, game, rel, True))
    log(f"游戏包 {len(versions)} 个")
    download_many(extra, workers, log, "游戏包配置")
    return settings


def asset_jobs(game: Path, settings: dict, only_bundle: str, max_assets: int | None) -> list:
    versions = (settings.get("assets") or {}).get("bundleVers") or {}
    jobs = []
    for bundle, ver in versions.items():
        if only_bundle and bundle != only_bundle:
            continue
        cfg_path = game / "assets" / bundle / f"config.{ver}.json"
        if not cfg_path.exists() or cfg_path.stat().st_size == 0:
            continue
        cfg = json.loads(cfg_path.read_text(encoding="utf-8"))
        types = cfg.get("types") or []
        uuids = cfg.get("uuids") or []
        paths = cfg.get("paths") or {}
        version_map = cfg.get("versions") or {}
        for kind in ("import", "native"):
            arr = version_map.get(kind) or []
            for index in range(0, len(arr), 2):
                uuid_index = arr[index]
                file_hash = str(arr[index + 1])
                if not isinstance(uuid_index, int) or uuid_index >= len(uuids):
                    continue
                uid = uuids[uuid_index]
                info = paths.get(str(uuid_index))
                type_name = ""
                if info and len(info) > 1 and isinstance(info[1], int) and info[1] < len(types):
                    type_name = types[info[1]]
                if kind == "import":
                    url, rel = import_candidate(bundle, uid, file_hash)
                    options = [(url, place(game, rel))]
                else:
                    options = [(url, place(game, rel)) for url, rel in native_candidates(bundle, uid, file_hash, type_name)]
                jobs.append((f"{bundle} {kind} {uid}", options, True))
                if max_assets is not None and len(jobs) >= max_assets:
                    return jobs
    return jobs


def download_game_icons(root: Path, settings: dict, workers: int, log: Log) -> None:
    hall = root / "hall"
    jobs = []
    for bundle in (settings.get("assets") or {}).get("bundleVers") or {}:
        match = re.fullmatch(r"Game(\d+)", bundle)
        if not match:
            continue
        rel = f"images/v1/game/{match.group(1)}.png"
        jobs.append(rel_job(HALL_ORIGIN, hall, rel, False))
    if jobs:
        log(f"大厅游戏图标 {len(jobs)} 个")
        download_many(jobs, workers, log, "游戏图标")


def patch_hall(hall: Path, game_port: int, log: Log) -> None:
    local = f"http://127.0.0.1:{game_port}"
    changed = 0
    for path in hall.rglob("*.js"):
        text = path.read_text(encoding="utf-8", errors="replace")
        if GAME_HOST not in text:
            continue
        path.write_text(patch_text(text, game_port), encoding="utf-8")
        changed += 1
    log(f"已把大厅里的游戏地址改到 {local} ，改了 {changed} 个脚本。账号接口仍是 https://api.m215gate.com:443")


def page_has(url: str, needle: bytes) -> bool:
    try:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=2) as response:
            return needle in response.read(8000)
    except Exception:
        return False


class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, fmt: str, *args) -> None:
        return


def serve(hall: Path, game: Path, hall_port: int, game_port: int, open_browser: bool, log: Log) -> None:
    if hall_port != 8080:
        log("大厅如果不是 8080 端口，账号服务器会拒绝登录。请使用默认端口。")
    servers = []
    for folder, port in ((hall, hall_port), (game, game_port)):
        handler = lambda *args, directory=str(folder), **kwargs: QuietHandler(*args, directory=directory, **kwargs)
        try:
            server = ThreadingHTTPServer(("127.0.0.1", port), handler)
        except OSError as exc:
            raise RuntimeError(
                f"端口 {port} 已被占用。如果刚才的窗口还开着，直接用浏览器打开 http://127.0.0.1:{hall_port} 。"
            ) from exc
        servers.append(server)
        threading.Thread(target=server.serve_forever, daemon=True).start()
    log("")
    log(f"大厅 http://127.0.0.1:{hall_port}")
    log(f"游戏 http://127.0.0.1:{game_port}")
    log("请不要关闭这个窗口。关闭后本机网页会停。")
    log("登录仍使用原来的账号。系统如果询问是否允许 Python 访问网络，请选允许。")
    if open_browser:
        webbrowser.open(f"http://127.0.0.1:{hall_port}/")
    try:
        while True:
            time.sleep(3600)
    except KeyboardInterrupt:
        log("已停止。再次双击可以重新打开。")
    finally:
        for server in servers:
            server.shutdown()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="下载 h215 大厅和全部 H5 游戏到本机")
    parser.add_argument("--dir", type=Path, default=None)
    parser.add_argument("--workers", type=int, default=16)
    parser.add_argument("--hall-port", type=int, default=8080)
    parser.add_argument("--game-port", type=int, default=8081)
    parser.add_argument("--no-serve", action="store_true")
    parser.add_argument("--serve-only", action="store_true")
    parser.add_argument("--no-browser", action="store_true")
    parser.add_argument("--max-assets", type=int, default=None)
    parser.add_argument("--only-bundle", default="")
    parser.add_argument("--self-check", action="store_true")
    parser.add_argument("--refresh", action="store_true")
    return parser.parse_args()


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    args = parse_args()
    if args.self_check:
        return self_check()
    root = (args.dir or Path(__file__).resolve().parent / "h215-local").resolve()
    log = Log(root / "download.log")
    hall = root / "hall"
    game = root / "game"
    try:
        if (
            not args.no_serve
            and not args.serve_only
            and page_has(f"http://127.0.0.1:{args.hall_port}/", b"Slots Casino")
        ):
            log(f"本机大厅已经在运行：http://127.0.0.1:{args.hall_port}")
            log("要重新下载，先关掉原来的黑色窗口，再双击一次。")
            if not args.no_browser:
                webbrowser.open(f"http://127.0.0.1:{args.hall_port}/")
            return 0
        already = (
            (root / "download.done").exists()
            and args.max_assets is None
            and not args.only_bundle
            and not args.refresh
        )
        if not args.serve_only and already:
            log("这份下载已经完成，直接打开网页。")
            log("要重新检查漏掉的文件，先删掉 h215-local 里面的 download.done，再双击。")
        elif not args.serve_only:
            log(f"文件会保存到 {root}")
            log("大约 1.1GB。已经下过的文件会跳过。")
            download_hall(root, args.workers, log)
            settings = download_game_shell(root, args.workers, log)
            download_game_icons(root, settings, args.workers, log)
            jobs = asset_jobs(game, settings, args.only_bundle, args.max_assets)
            log(f"游戏资源 {len(jobs)} 个")
            stats = download_many(jobs, args.workers, log, "游戏资源")
            log(
                f"游戏资源完成：新下 {stats['ok']} ，跳过 {stats['skip']} ，"
                f"失败 {stats['miss']} ，源站拒绝 {stats['denied']} 。"
                "被拒绝的文件官方网页同样下不到。"
            )
            if args.max_assets is None and not args.only_bundle:
                (root / "download.done").write_text("ok\n", encoding="utf-8")
        if not (hall / "index.html").exists():
            raise RuntimeError(f"还没有大厅文件。请先完整运行一次。目录：{root}")
        patch_hall(hall, args.game_port, log)
        if args.no_serve:
            log(f"下载结束，未启动网页服务。目录：{root}")
            return 0
        serve(hall, game, args.hall_port, args.game_port, not args.no_browser, log)
        return 0
    except KeyboardInterrupt:
        log("已暂停。再次双击会从断点继续。")
        return 0
    except Exception as exc:
        log(f"出错了：{exc}")
        log("再次双击会跳过已完成的文件，继续下载。")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
