"""Decode game 101 art from the original ETC2 sheets into real PNGs and a catalog."""
from __future__ import annotations

import gzip
import io
import re
import struct
from pathlib import Path

import texture2ddecoder
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'creator-hall/assets/resources/fish101'
LUA = ROOT / 'fish2/script/config/fish_info_hw.lua'


NAMES = {
    0: '迦魶鱼', 16: '鲨鱼', 100: '旋风迦魶鱼', 101: '旋风小丑鱼', 102: '旋风碟鱼', 104: '旋风狮子鱼',
    200: '闪电鲨', 203: '连环炸弹蟹', 302: '霸王鲸', 323: '黄金鲨鱼', 324: '黄金鲸', 325: '聚餐元宵',
}


def decode_pkm(path: Path) -> Image.Image:
    raw = path.read_bytes()
    if raw[:2] == b'\x1f\x8b':
        raw = gzip.decompress(raw)
    if raw[:8] == b'\x89PNG\r\n\x1a\n':
        return Image.open(io.BytesIO(raw)).convert('RGBA')
    if raw[:4] != b'PKM ':
        return Image.open(io.BytesIO(raw)).convert('RGBA')
    fmt, width, height = struct.unpack_from('>HHH', raw, 6)
    payload = raw[16:]
    if fmt == 3:
        pixels = texture2ddecoder.decode_etc2a8(payload, width, height)
    elif fmt == 2:
        pixels = texture2ddecoder.decode_etc2a1(payload, width, height)
    elif fmt == 1:
        pixels = texture2ddecoder.decode_etc2(payload, width, height)
    elif fmt == 0:
        pixels = texture2ddecoder.decode_etc1(payload, width, height)
    else:
        raise SystemExit(f'unsupported PKM format {fmt} in {path}')
    return Image.frombytes('RGBA', (width, height), pixels, 'raw', 'BGRA')


def crop(atlas: Image.Image, x: int, y: int, w: int, h: int, rotated: bool) -> Image.Image:
    if rotated:
        image = atlas.crop((x, y, x + h, y + w)).transpose(Image.Transpose.ROTATE_90)
    else:
        image = atlas.crop((x, y, x + w, y + h))
    return image.convert('RGBA')


def parse_plist(path: Path) -> list[tuple[str, tuple[int, int, int, int], bool]]:
    text = path.read_text(encoding='utf-8', errors='replace')
    frames: list[tuple[str, tuple[int, int, int, int], bool]] = []
    for match in re.finditer(r'<key>([^<]+\.png)</key>\s*<dict>(.*?)</dict>', text, re.S):
        name, body = match.group(1), match.group(2)
        rect = re.search(r'<key>(?:textureRect|frame)</key>\s*<string>\{\{(\d+),(\d+)\},\{(\d+),(\d+)\}\}</string>', body)
        if not rect:
            continue
        rotated = bool(re.search(r'<key>(?:textureRotated|rotated)</key>\s*<(true|false)\s*/>', body))
        flag = re.search(r'<key>(?:textureRotated|rotated)</key>\s*<(true|false)\s*/>', body)
        frames.append((name, tuple(int(part) for part in rect.groups()), flag.group(1) == 'true' if flag else False))
    return frames


def frame_index(name: str) -> int:
    found = re.search(r'\((\d+)\)', name)
    if found:
        return int(found.group(1))
    found = re.search(r'(\d+)', Path(name).stem)
    return int(found.group(1)) if found else 0


def save(image: Image.Image, relative: str) -> None:
    path = OUT / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, 'PNG')


def pick_frames(frames: list[tuple[str, tuple[int, int, int, int], bool]], count: int):
    ordered = sorted(frames, key=lambda item: frame_index(item[0]))
    if len(ordered) <= count:
        return ordered
    step = (len(ordered) - 1) / (count - 1)
    return [ordered[round(index * step)] for index in range(count)]


def parse_fish() -> list[dict]:
    text = LUA.read_text(encoding='utf-8', errors='replace')
    blocks = re.split(r'\n    [A-Za-z0-9_]+ = \{', text)
    keys = re.findall(r'\n    ([A-Za-z0-9_]+) = \{', text)
    fish = []
    for key, block in zip(keys, blocks[1:]):
        type_match = re.search(r'typeId = (\d+)', block)
        action = re.search(r'actionFile = "actions/(general|golden|special)/([a-z0-9_]+)\.actions"', block)
        if not type_match or not action:
            continue
        comment = ''
        head = block[:80]
        named = re.search(r'--\s*(\S+)', text[text.find(key + ' = {') - 40:text.find(key + ' = {')])
        if named:
            comment = named.group(1)
        coins = re.search(r'\n        coin = \{([^}]+)\}', block)
        coin_list = [int(part) for part in re.findall(r'\d+', re.search(r'coinList = \{([^}]+)\}', block).group(1))] if 'coinList' in block else []
        values = [int(part) for part in re.findall(r'\d+', coins.group(1))] if coins else []
        if len(values) >= 3:
            coin_min, coin_max, coin_step = values[0], values[1], values[2]
        elif len(values) == 2:
            coin_min, coin_max, coin_step = values[0], values[1], 1
        elif coin_list:
            coin_min, coin_max, coin_step = coin_list[0], coin_list[-1], 1
        else:
            continue
        folder, stem = action.group(1), action.group(2)
        sheet = ROOT / f'fish_101/fish/{folder}/{stem}_move_0.png'
        plist = ROOT / f'fish2/fish/{folder}/{stem}_move_0.plist'
        if not sheet.exists() or not plist.exists():
            continue
        type_id = int(type_match.group(1))
        if type_id > 18 and type_id not in {100, 101, 102, 104, 200, 203, 205, 302, 305, 306, 323, 324, 325}:
            continue
        if 'isCycleFish = true' in block:
            whirl = ROOT / f'fish_101/fish/{folder}/{stem}_xuanfeng_move_0.png'
            whirl_plist = ROOT / f'fish2/fish/{folder}/{stem}_xuanfeng_move_0.plist'
            if whirl.exists() and whirl_plist.exists():
                sheet = whirl
                plist = whirl_plist
                stem = f'{stem}_xuanfeng'
        group = 'golden' if type_id >= 300 else 'special' if type_id >= 200 else 'general'
        comment = NAMES.get(type_id, comment)
        fish.append({
            'typeId': type_id,
            'name': comment or key,
            'group': group,
            'folder': folder,
            'stem': stem,
            'sheet': sheet,
            'plist': plist,
            'coinMin': coin_min,
            'coinMax': coin_max,
            'coinStep': max(1, coin_step),
            'coinList': coin_list,
            'boss': type_id in {305, 306},
            'upright': 'upwards = true' in block,
        })
    fish.sort(key=lambda item: item['typeId'])
    return fish


def fit(width: int, height: int, boss: bool) -> tuple[int, int]:
    limit = 300 if boss else 220 if width > 170 else width
    if width <= limit:
        return width, height
    scale = limit / width
    return max(1, int(width * scale)), max(1, int(height * scale))


def extract_fish(records: list[dict]) -> list[dict]:
    catalog = []
    for record in records:
        atlas = decode_pkm(record['sheet'])
        frames = parse_plist(record['plist'])
        chosen = pick_frames(frames, 2 if record['boss'] or record['typeId'] >= 200 else 4)
        if not chosen:
            continue
        first = None
        for index, (_name, rect, rotated) in enumerate(chosen):
            image = crop(atlas, *rect, rotated)
            if first is None:
                first = image.size
            save(image, f"fish/{record['stem']}_{index}.png")
        width, height = fit(first[0], first[1], record['boss'])
        speed = 55 if record['boss'] else max(80, 150 - min(record['coinMin'], 40) * 2)
        catalog.append({
            'typeId': record['typeId'],
            'name': record['name'],
            'group': record['group'],
            'art': f"fish101/fish/{record['stem']}",
            'frames': len(chosen),
            'coinMin': record['coinMin'],
            'coinMax': record['coinMax'],
            'coinStep': record['coinStep'],
            'coinList': record['coinList'],
            'width': width,
            'height': height,
            'speed': speed,
            'boss': record['boss'],
            'upright': record['upright'],
        })
        print(f"fish {record['typeId']} {record['name']} {first[0]}x{first[1]} -> {width}x{height} frames={len(chosen)}")
    return catalog


def extract_named(atlas: Image.Image, plist: Path, names: dict[str, str]) -> None:
    frames = {name: (rect, rotated) for name, rect, rotated in parse_plist(plist)}
    for source, relative in names.items():
        if source not in frames:
            print('missing', source)
            continue
        rect, rotated = frames[source]
        save(crop(atlas, *rect, rotated), relative)
        print('ui', relative, rect, rotated)


def write_catalog(catalog: list[dict]) -> None:
    lines = [
        '/** Fish spawned in 大王乌贼. Sizes are the original frame scaled into the 1280x720 table. */',
        'export interface FishKind {',
        '    typeId: number;',
        "    name: string;",
        "    group: 'general' | 'golden' | 'special';",
        '    art: string;',
        '    frames: number;',
        '    coinMin: number;',
        '    coinMax: number;',
        '    coinStep: number;',
        '    coinList: number[];',
        '    width: number;',
        '    height: number;',
        '    speed: number;',
        '    boss: boolean;',
        '    upright: boolean;',
        '}',
        '',
        'export const FISH_KINDS: FishKind[] = [',
    ]
    for item in catalog:
        coins = ', '.join(str(value) for value in item['coinList'])
        lines.append(
            '    {'
            f" typeId: {item['typeId']}, name: {item['name']!r}, group: '{item['group']}',"
            f" art: '{item['art']}', frames: {item['frames']},"
            f" coinMin: {item['coinMin']}, coinMax: {item['coinMax']}, coinStep: {item['coinStep']},"
            f" coinList: [{coins}], width: {item['width']}, height: {item['height']},"
            f" speed: {item['speed']}, boss: {'true' if item['boss'] else 'false'},"
            f" upright: {'true' if item['upright'] else 'false'} }},"
        )
    lines.append('];')
    lines.append('')
    path = ROOT / 'creator-hall/assets/scripts/Fish101Catalog.ts'
    path.write_text('\n'.join(lines), encoding='utf-8')
    print('catalog', len(catalog), path)


def main() -> None:
    if OUT.exists():
        for stale in OUT.glob('*.png'):
            stale.unlink()
    records = parse_fish()
    catalog = extract_fish(records)
    write_catalog(catalog)
    ui = decode_pkm(ROOT / 'fish2/ui/ui.png')
    extract_named(ui, ROOT / 'fish2/ui/ui.plist', {
        'anniu_jiahao.png': 'ui/plus.png',
        'anniu_jianhao.png': 'ui/minus.png',
        'anniu_jiguang.png': 'ui/laser.png',
        'yuwang_1.png': 'ui/net.png',
        'paotaijizuo.png': 'ui/base.png',
        'paotaixianshijinbilanse.png': 'ui/coin_bg.png',
        'yuzhonglaixi_beijing.png': 'ui/boss_banner.png',
        'zidongkaipao.png': 'ui/auto_label.png',
        'suodingquan_01.png': 'ui/lock_ring.png',
        'nideweiziguangquan.png': 'ui/seat_ring.png',
        **{f'pao_{index:02d}.png': f'ui/pao_{index:02d}.png' for index in range(1, 8)},
        **{f'zidan_{index:02d}.png': f'ui/zidan_{index:02d}.png' for index in range(1, 8)},
        **{f'no1_{digit}.png': f'ui/no1_{digit}.png' for digit in list('0123456789') + ['d']},
    })
    ui_cn = decode_pkm(ROOT / 'fish2/ui/ui_cn.png')
    extract_named(ui_cn, ROOT / 'fish2/ui/ui_cn.plist', {
        'anniu_suoding.png': 'ui/lock.png',
        'anniu_zidong.png': 'ui/auto.png',
        'nideweizi.png': 'ui/your_seat.png',
    })
    book = decode_pkm(ROOT / 'fish2/ui/studio/fish2_ui_cn.png')
    extract_named(book, ROOT / 'fish2/ui/studio/fish2_ui_cn.plist', {
        'cn/anniu_yibanyu_lanse.png': 'ui/tab_general.png',
        'cn/anniu_yibanyu_huangse.png': 'ui/tab_general_on.png',
        'cn/anniu_caijingyu_lanse.png': 'ui/tab_golden.png',
        'cn/anniu_caijingyu_huangse.png': 'ui/tab_golden_on.png',
        'cn/anniu_teshuyu_lanse.png': 'ui/tab_special.png',
        'cn/anniu_teshuyu_huangse.png': 'ui/tab_special_on.png',
    })
    room = decode_pkm(ROOT / 'hall/res/studio/room/room.png')
    extract_named(room, ROOT / 'hall/res/studio/room/room.plist', {
        'room/table.png': 'room/table.png',
        'room/chair_1.png': 'room/chair_empty.png',
        'room/chair_2.png': 'room/chair_taken.png',
        'room/arrow_d.png': 'room/arrow.png',
        'room/person_1.png': 'room/person.png',
        'room/arrow_l.png': 'room/arrow_l.png',
        'room/arrow_r.png': 'room/arrow_r.png',
    })
    for index, source in enumerate(['bg1.png', 'bg6.png', 'bg9.png'], start=1):
        image = decode_pkm(ROOT / 'fish2/bg' / source)
        left = max(0, (image.width - 1280) // 2)
        top = max(0, (image.height - 720) // 2)
        save(image.crop((left, top, left + 1280, top + 720)), f'bg_{index}.png')
        print('bg', source, image.size)
    room_bg = decode_pkm(ROOT / 'hall/res/studio/room/room_bg.png')
    save(room_bg.resize((1280, 720), Image.Resampling.BILINEAR) if room_bg.size != (1280, 720) else room_bg, 'room/bg.png')
    print('room bg', room_bg.size)
    for level in range(1, 5):
        card = decode_pkm(ROOT / f'hall/res/level/101/{level}.png')
        save(card, f'level_{level}.png')
        print('level', level, card.size)


if __name__ == '__main__':
    main()
