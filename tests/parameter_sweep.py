"""Contact sheets that sweep every plugin parameter over the same image.

Usage: python tests/parameter_sweep.py INPUT.png OUTPUT_DIR [--scale 0.5] [--cap 160]

Uses the CPU reference in radial_regression.py, so it reproduces the shader math
only; it does not compile HLSL or run Direct2D. Uploaded images are not committed.
"""
import os
import sys
from concurrent.futures import ProcessPoolExecutor

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from radial_regression import falloff_value, render  # noqa: E402

FONT = '/usr/share/fonts/truetype/fonts-japanese-gothic.ttf'
MODE_NAMES = ['冪乗', '三乗', '四乗', '六乗', '指数']
BG, FG, SUB, ACCENT = '#16181d', '#f2f4f8', '#9aa4b2', '#7fd1ff'

# Plugin defaults, in the units the YMM4 UI shows.
DEFAULTS = dict(aberration=40, power=2, radius=100, mode=0, radial=8, scale=0,
                cx=0, cy=0, steps=32, mix=100, scale_mode=0)


def needed_steps(w, h, p, cap):
    """Mirror of ChromaticAberrationProcessor's sample-count estimate."""
    radius = min(max(p['radius'] / 100, 0.01), 100)
    power = min(max(p['power'], 0), 32)
    radial = np.deg2rad(p['radial'])
    scale = p['scale'] / 100
    corner = np.hypot((w / 2 + abs(p['cx'])) / (w / 2), (h / 2 + abs(p['cy'])) / (h / 2))
    fmax = float(falloff_value(np.array([corner / radius]), power, p['mode'])[0])
    max_radius = np.hypot(w, h) / 2 + np.hypot(p['cx'], p['cy'])
    scale_max, radial_max = abs(scale) * fmax, abs(radial) * fmax
    zoom = np.exp(min(scale_max, 16)) if p['scale_mode'] == 1 else 1 + scale_max
    slope = scale_max * zoom if p['scale_mode'] == 1 else scale_max
    need = 2 * abs(p['aberration']) * fmax + 2 * max_radius * (slope + radial_max * zoom)
    return int(min(max(np.ceil(need), 2), cap))


SRC = None


def init_worker(src):
    global SRC
    SRC = src


def tile(args):
    """Render one variant. Pixel parameters arrive already scaled to the source."""
    index, p, cap = args
    src = SRC
    h, w = src.shape[:2]
    steps = p['steps'] if p['steps'] is not None else needed_steps(w, h, p, cap)
    out = render(src, radial=p['radial'], aberration=p['aberration'], scale=p['scale'] / 100,
                 power=p['power'], steps=steps, offset=(p['cx'], p['cy']), fixed=True,
                 mix=p['mix'] / 100, radius=p['radius'] / 100, mode=p['mode'],
                 scale_mode=p['scale_mode'])
    rgb = np.uint8(np.clip(out[..., :3] + (1 - out[..., 3:]), 0, 1) * 255)
    return index, rgb, steps


def sweep(name, note, values, **overrides):
    """One sheet row: a parameter name, a caption, and its variants."""
    return dict(name=name, note=note, variants=[
        (label, {**DEFAULTS, **overrides, **params}) for label, params in values])


def rows():
    d = DEFAULTS
    return [
        [sweep('収差', '中心から外へ色をずらす量。効果の主役', [
            ('0 px（無効）', dict(aberration=0)), ('10 px', dict(aberration=10)),
            (f'{d["aberration"]} px（既定）', dict(aberration=40)),
            ('150 px', dict(aberration=150)), ('600 px', dict(aberration=600))]),
         sweep('減衰', '収差120pxで比較。0は全面均一、大きいほど周辺だけに集中', [
             ('0（均一）', dict(power=0)), ('1', dict(power=1)),
             ('2.0（既定）', dict(power=2)), ('6', dict(power=6)), ('16', dict(power=16))],
             aberration=120),
         sweep('半径', '収差60pxで比較。減衰の効く範囲。小さいほど中心から立ち上がる', [
             ('25 %', dict(radius=25)), ('50 %', dict(radius=50)),
             ('100 %（既定）', dict(radius=100)), ('300 %', dict(radius=300)),
             ('1000 %', dict(radius=1000))], aberration=60)],

        [sweep('減衰形式', '収差120px・減衰2.0。三乗以上は指数の下限が上がる', [
            (f'{MODE_NAMES[i]}{"（既定）" if i == 0 else ""}', dict(mode=i)) for i in range(5)],
            aberration=120),
         sweep('ラジアル', '収差0pxで比較。中心まわりにねじる角度', [
             ('0°', dict(radial=0)), ('8°（既定）', dict(radial=8)), ('45°', dict(radial=45)),
             ('180°', dict(radial=180)), ('720°', dict(radial=720))], aberration=0),
         sweep('スケール', '収差0・ラジアル0で比較。色ごとに拡大率を変える量', [
             ('-200 %', dict(scale=-200)), ('-60 %', dict(scale=-60)),
             ('0 %（既定）', dict(scale=0)), ('60 %', dict(scale=60)),
             ('200 %', dict(scale=200))], aberration=0, radial=0)],

        [sweep('中心X', '収差150pxで比較。ずれの中心の横位置', [
            ('-900 px', dict(cx=-900)), ('-450 px', dict(cx=-450)),
            ('0 px（既定）', dict(cx=0)), ('450 px', dict(cx=450)), ('900 px', dict(cx=900))],
            aberration=150),
         sweep('中心Y', '収差150pxで比較。ずれの中心の縦位置', [
             ('-675 px', dict(cy=-675)), ('-340 px', dict(cy=-340)),
             ('0 px（既定）', dict(cy=0)), ('340 px', dict(cy=340)), ('675 px', dict(cy=675))],
             aberration=150),
         sweep('強さ', '収差150pxで比較。元の映像との合成量', [
             ('0 %（素材のまま）', dict(mix=0)), ('25 %', dict(mix=25)), ('50 %', dict(mix=50)),
             ('75 %', dict(mix=75)), ('100 %（既定）', dict(mix=100))], aberration=150)],

        [sweep('ステップ数', '収差300pxで比較。少ないと分光が縞に割れる', [
            ('2', dict(steps=2)), ('8', dict(steps=8)), ('32（既定の上限）', dict(steps=32)),
            ('128', dict(steps=128)), ('512', dict(steps=512))], aberration=300),
         sweep('スケール方式', 'スケールの符号ごとの倍率の作り方の違い', [
             ('絶対値 / -150 %（既定）', dict(scale=-150, scale_mode=0)),
             ('指数 / -150 %', dict(scale=-150, scale_mode=1)),
             ('絶対値 / +150 %（既定）', dict(scale=150, scale_mode=0)),
             ('指数 / +150 %', dict(scale=150, scale_mode=1))], aberration=0, radial=0)],
    ]


def build(src_path, out_dir, scale, cap, tile_w):
    os.makedirs(out_dir, exist_ok=True)
    full = Image.open(src_path).convert('RGBA')
    w, h = int(round(full.width * scale)), int(round(full.height * scale))
    src = np.asarray(full.resize((w, h), Image.LANCZOS), dtype=float) / 255
    tile_h = int(round(tile_w * h / w))

    layout, jobs = [], []
    for sheet in rows():
        sheet_layout = []
        for row in sheet:
            tiles = []
            for label, p in row['variants']:
                px = dict(p, aberration=p['aberration'] * scale,
                          cx=p['cx'] * scale, cy=p['cy'] * scale)
                tiles.append((len(jobs), label))
                jobs.append((len(jobs), px, cap))
            sheet_layout.append((row['name'], row['note'], tiles))
        layout.append(sheet_layout)
    print(f'{len(jobs)} tiles at {w}x{h}', flush=True)

    names = {i: (n, l) for s in layout for n, _, ts in s for i, l in ts}
    done = {}
    with ProcessPoolExecutor(max_workers=min(4, os.cpu_count() or 1),
                             initializer=init_worker, initargs=(src,)) as pool:
        for index, rgb, steps in pool.map(tile, jobs):
            done[index] = rgb
            print(f'  [{len(done)}/{len(jobs)}] {names[index][0]} {names[index][1]} steps={steps}',
                  flush=True)

    title_f, name_f, note_f, label_f = (ImageFont.truetype(FONT, s) for s in (34, 30, 21, 23))
    pad, gap, head, cap_h = 26, 12, 52, 38
    sheet_titles = ['① 収差・減衰・半径', '② 減衰形式・ラジアル・スケール',
                    '③ 中心X・中心Y・強さ', '④ ステップ数・スケール方式']
    paths = []
    for sheet_index, sheet in enumerate(layout):
        cols = max(len(ts) for _, _, ts in sheet)
        width = pad * 2 + cols * tile_w + (cols - 1) * gap
        height = pad * 2 + 54 + sum(head + tile_h + cap_h + gap for _ in sheet)
        canvas = Image.new('RGB', (width, height), BG)
        draw = ImageDraw.Draw(canvas)
        title = f'{sheet_titles[sheet_index]}　— 表記のない項目はすべて既定値'
        width = max(width, pad * 2 + int(draw.textlength(title, font=title_f)))
        if width > canvas.width:
            canvas = Image.new('RGB', (width, height), BG)
            draw = ImageDraw.Draw(canvas)
        draw.text((pad, pad), title, font=title_f, fill=FG)
        y = pad + 54
        for name, note, tiles in sheet:
            draw.text((pad, y + 6), name, font=name_f, fill=ACCENT)
            nx = pad + draw.textlength(name, font=name_f) + 16
            draw.text((nx, y + 15), note, font=note_f, fill=SUB)
            y += head
            for col, (index, label) in enumerate(tiles):
                img = Image.fromarray(done[index]).resize((tile_w, tile_h), Image.LANCZOS)
                x = pad + col * (tile_w + gap)
                canvas.paste(img, (x, y))
                draw.rectangle([x, y, x + tile_w - 1, y + tile_h - 1], outline='#3a4150')
                draw.text((x + 4, y + tile_h + 8), label, font=label_f, fill=FG)
            y += tile_h + cap_h + gap
        path = os.path.join(out_dir, f'sweep_{sheet_index + 1}.png')
        canvas.save(path)
        paths.append(path)
        print('wrote', path, canvas.size, flush=True)
    return paths


if __name__ == '__main__':
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    opts = dict(a.lstrip('-').split('=') for a in sys.argv[1:] if a.startswith('--'))
    build(args[0], args[1], float(opts.get('scale', 0.5)), int(opts.get('cap', 160)),
          int(opts.get('tile', 560)))
