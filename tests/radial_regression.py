"""CPU reference of HLSL math; does not exercise Direct2D or compile the shader.
Usage: python tests/radial_regression.py INPUT.jpg OUTPUT.png
Requires numpy and Pillow. Uploaded images are not committed to the repository.
"""
import sys
import numpy as np
from PIL import Image, ImageDraw


def render(src, radial=90, aberration=40, scale=0, power=2, steps=128,
           offset=(0, 0), fixed=True, mix=1):
    h, w = src.shape[:2]
    if fixed and (mix == 0 or (radial == 0 and aberration == 0 and scale == 0)):
        return src.copy()
    y, x = np.mgrid[:h, :w].astype(float)
    cx, cy = w / 2 + offset[0], h / 2 + offset[1]
    dx, dy = x + .5 - cx, y + .5 - cy
    radius = np.hypot(dx, dy)
    ux, uy = dx / np.maximum(radius, 1e-5), dy / np.maximum(radius, 1e-5)
    falloff = np.hypot(dx / (w / 2), dy / (h / 2)) ** power
    colors = np.zeros((h, w, 3))
    coverage = np.zeros_like(colors)
    alpha = np.zeros((h, w, 1))
    # Input and output use premultiplied RGBA, as Direct2D does.
    def sample(qx, qy):
        if fixed:
            qx, qy = np.clip(qx, 0, w - 1), np.clip(qy, 0, h - 1)
        ix, iy = np.floor(qx).astype(int), np.floor(qy).astype(int)
        fx, fy = qx - ix, qy - iy
        out = np.zeros((h, w, 4))
        for ox, oy, weight in ((0, 0, (1-fx)*(1-fy)), (1, 0, fx*(1-fy)),
                               (0, 1, (1-fx)*fy), (1, 1, fx*fy)):
            xx, yy = ix + ox, iy + oy
            valid = (xx >= 0) & (xx < w) & (yy >= 0) & (yy < h)
            out += src[np.clip(yy, 0, h-1), np.clip(xx, 0, w-1)] * (weight * valid)[..., None]
        return out
    for t in np.linspace(0, 1, steps):
        s = 2*t-1
        a = np.deg2rad(radial)*s
        qx = cx + (dx*np.cos(a)-dy*np.sin(a))*(1+scale*s) + ux*aberration*falloff*s - .5
        qy = cy + (dx*np.sin(a)+dy*np.cos(a))*(1+scale*s) + uy*aberration*falloff*s - .5
        smp = sample(qx, qy)
        straight = np.divide(smp[..., :3], smp[..., 3:], out=np.zeros_like(colors), where=smp[..., 3:] > 0)
        weight = np.exp(-.5*((t-np.array([1, .5, 0]))/.25)**2)
        colors += straight * weight * (smp[..., 3:] if fixed else 1)
        coverage += weight * (smp[..., 3:] if fixed else 1)
        alpha += smp[..., 3:]
    alpha /= steps
    color = np.clip(colors / np.maximum(coverage, 1e-5), 0, 1)
    return src*(1-mix) + np.concatenate((color*alpha, alpha), axis=2)*mix


def checks():
    rng = np.random.default_rng(41)
    opaque = rng.random((13, 23, 4)); opaque[..., 3] = 1
    count = 0
    for radial in (-720, -180, -90, 0, 90, 180, 720):
        for scale in (-1, 0, 1):
            out = render(opaque, radial=radial, scale=scale, offset=(41, -27), steps=32)
            assert np.allclose(out[..., 3], 1), (radial, scale)
            assert np.isfinite(out).all()
            count += 1
    transparent = np.zeros_like(opaque)
    assert np.array_equal(render(transparent), transparent)
    semi = np.ones_like(opaque)*.4
    assert np.allclose(render(semi), semi)
    assert np.array_equal(render(opaque, radial=0, aberration=0), opaque)
    assert np.array_equal(render(opaque, mix=0), opaque)
    one = np.ones((1, 1, 4))
    assert np.allclose(render(one), one)
    mask = opaque.copy(); mask[..., 3] = rng.random(mask.shape[:2]); mask[..., :3] *= mask[..., 3:]
    out = render(mask)
    assert (out[..., :3] <= out[..., 3:] + 1e-9).all()
    print(f'PASS: {count} opaque extreme settings + transparent, semitransparent, identity, mix=0, 1px, premultiplication')


if __name__ == '__main__':
    checks()
    if len(sys.argv) == 3:
        src = np.array(Image.open(sys.argv[1]).convert('RGBA'), dtype=float)/255
        h, w = src.shape[:2]
        canvas = Image.new('RGB', (2*w, 3*(h+28)), '#20232a')
        draw = ImageDraw.Draw(canvas)
        for row, angle in enumerate((30, 90, 180)):
            for col, fixed in enumerate((False, True)):
                out = render(src, radial=angle, steps=128, fixed=fixed)
                yy, xx = np.mgrid[:h, :w]
                checker = np.where(((xx//12+yy//12)%2)[..., None], .65, .4)
                rgb = out[..., :3]+checker*(1-out[..., 3:])
                tile = Image.fromarray(np.uint8(np.clip(rgb, 0, 1)*255))
                canvas.paste(tile, (col*w, row*(h+28)+28))
                draw.text((col*w+8, row*(h+28)+7), f'{"AFTER" if fixed else "BEFORE"} | radial {angle} | CPU reference', fill='white')
                print(f'{angle=} {fixed=} alpha_min={out[...,3].min():.6f} alpha_mean={out[...,3].mean():.6f}')
        canvas.save(sys.argv[2])
