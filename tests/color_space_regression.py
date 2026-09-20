#!/usr/bin/env python3
"""CPU round-trip checks for the 15 shader color transforms."""

from __future__ import annotations

import math
from pathlib import Path

import numpy as np


PI = math.pi
TAU = 2 * PI


def wrap(v):
    return np.asarray(v) - np.floor(v)


def opponent(c):
    r, g, b = c
    return np.array(((r + g + b) / 3, r - g, (r + g) / 2 - b))


def rgb(l, a, b):
    return np.array((l + b / 3 + a / 2, l + b / 3 - a / 2, l - 2 * b / 3))


def rss_f(c):
    l, a, b = opponent(c)
    x = a + 0.35 * math.sin(TAU * l)
    y = b + 0.45 * math.sin(PI * x)
    z = l + 0.18 * math.sin(TAU * y)
    return np.array((x, y, z))


def rss_i(v):
    x, y, z = v
    l = z - 0.18 * math.sin(TAU * y)
    b = y - 0.45 * math.sin(PI * x)
    a = x - 0.35 * math.sin(TAU * l)
    return rgb(l, a, b)


def fss_f(c):
    p = (1 + math.sqrt(5)) / 2
    a, b, z = c - 0.5
    x = a + p * b
    y = b + p * p * z
    return np.array((x, y, z + x / p))


def fss_i(v):
    p = (1 + math.sqrt(5)) / 2
    x, y, zz = v
    z = zz - x / p
    b = y - p * p * z
    a = x - p * b
    return np.array((a, b, z)) + 0.5


def csl_f(c):
    l, a, b = opponent(c)
    rho = math.hypot(a, b)
    phase = math.atan2(b, a)
    radius = math.asinh(2.8 * rho) / 2.8
    z = math.asinh(2.2 * (l - 0.5)) / 2.2
    theta = phase + 3.4 * math.log(1 + 5 * rho * rho) + 1.7 * math.sin(TAU * l)
    return np.array((radius * math.cos(theta), radius * math.sin(theta), z))


def csl_i(v):
    x, y, z = v
    radius = math.hypot(x, y)
    rho = math.sinh(2.8 * radius) / 2.8
    l = 0.5 + math.sinh(2.2 * z) / 2.2
    phase = math.atan2(y, x) - 3.4 * math.log(1 + 5 * rho * rho) - 1.7 * math.sin(TAU * l)
    return rgb(l, rho * math.cos(phase), rho * math.sin(phase))


HCS = np.array(((1.15, -0.65, 0.20), (-0.20, 1.30, -0.70), (0.75, 0.15, -0.55)))
HCS_INV = np.linalg.inv(HCS)


def hcs_f(c):
    y = HCS @ (c - 0.5)
    return np.arcsinh(2.6 * y) / 2.6


def hcs_i(v):
    return HCS_INV @ (np.sinh(2.6 * v) / 2.6) + 0.5


def phs_f(c):
    l, a, b = opponent(c)
    w = l - 0.5
    x = a + 0.30 * math.sin(4 * PI * b) + 0.15 * math.sin(10 * PI * w)
    y = b + 0.36 * math.sin(6 * PI * x)
    z = w + 0.24 * math.sin(10 * PI * y)
    return np.array((x, y, z))


def phs_i(v):
    x, y, z = v
    w = z - 0.24 * math.sin(10 * PI * y)
    b = y - 0.36 * math.sin(6 * PI * x)
    a = x - 0.30 * math.sin(4 * PI * b) - 0.15 * math.sin(10 * PI * w)
    return rgb(w + 0.5, a, b)


def standard_f(c, k, c1, c2, coupled=False):
    x, p, z = wrap(c)
    p1 = wrap(p + k / TAU * math.sin(TAU * x))
    x1 = wrap(x + p1)
    z_phase = x1 + p1 if coupled else p1
    z1 = wrap(z + c1 * math.sin(TAU * x1) + c2 * math.sin(TAU * z_phase))
    return np.array((x1, p1, z1))


def standard_i(v, k, c1, c2, coupled=False):
    x1, p1, z1 = wrap(v)
    x = wrap(x1 - p1)
    p = wrap(p1 - k / TAU * math.sin(TAU * x))
    z_phase = x1 + p1 if coupled else p1
    z = wrap(z1 - c1 * math.sin(TAU * x1) - c2 * math.sin(TAU * z_phase))
    return np.array((x, p, z))


def cfe_f(c):
    eps = 0.001
    x, y, z = eps + (1 - 2 * eps) * c
    n = math.floor(1 / x)
    xx = 1 / x - n
    yy = 1 / (n + y)
    zz = wrap(z + 0.23 * math.sin(TAU * xx) + 0.17 * math.sin(TAU * yy))
    return np.array((xx, yy, zz))


def cfe_i(v):
    eps = 0.001
    xx, yy, zz = v
    n = math.floor(1 / yy)
    x = 1 / (n + xx)
    y = 1 / yy - n
    z = wrap(zz - 0.23 * math.sin(TAU * xx) - 0.17 * math.sin(TAU * yy))
    return (np.array((x, y, z)) - eps) / (1 - 2 * eps)


ANO = np.array(((2, 1, 1), (1, 1, 1), (1, 1, 0)), dtype=float)
ANO_INV = np.array(((1, -1, 0), (-1, 1, 1), (0, 1, -1)), dtype=float)
TOR = np.array(((1, 1, 1), (1, 2, 1), (1, 1, 2)), dtype=float)
TOR_INV = np.array(((3, -1, -1), (-1, 1, 0), (-1, 0, 1)), dtype=float)


def torus_f(c, matrix):
    return wrap(matrix @ c)


def torus_i(v, matrix):
    return wrap(matrix @ v)


def cat_f(c):
    x, y, z = c - 0.5
    xx = x + 0.70 * y**3 + 0.18 * math.sin(6 * PI * y)
    yy = y + 0.80 * z**3 + 0.24 * math.sin(4 * PI * xx)
    zz = z + 0.75 * xx**3 - 0.28 * yy + 0.12 * math.sin(TAU * xx)
    return np.array((xx, yy, zz))


def cat_i(v):
    xx, yy, zz = v
    z = zz - 0.75 * xx**3 + 0.28 * yy - 0.12 * math.sin(TAU * xx)
    y = yy - 0.80 * z**3 - 0.24 * math.sin(4 * PI * xx)
    x = xx - 0.70 * y**3 - 0.18 * math.sin(6 * PI * y)
    return np.array((x, y, z)) + 0.5


def rot(v, angle):
    cs, sn = math.cos(angle), math.sin(angle)
    return np.array((cs * v[0] - sn * v[1], sn * v[0] + cs * v[1]))


def brd_f(c):
    x, y, z = c - 0.5
    a = 3.6 * math.sin(TAU * z) + 0.9 * math.sin(6 * PI * z)
    x1, y1 = rot((x, y), a)
    b = 3.2 * math.sin(TAU * x1) - 0.8 * math.cos(4 * PI * x1)
    y2, z2 = rot((y1, z), b)
    angle = 3.8 * math.sin(TAU * y2) + 1.1 * math.sin(4 * PI * y2)
    z3, x3 = rot((z2, x1), angle)
    return np.array((x3, y2, z3))


def brd_i(v):
    x3, y2, z3 = v
    angle = 3.8 * math.sin(TAU * y2) + 1.1 * math.sin(4 * PI * y2)
    z2, x1 = rot((z3, x3), -angle)
    b = 3.2 * math.sin(TAU * x1) - 0.8 * math.cos(4 * PI * x1)
    y1, z = rot((y2, z2), -b)
    a = 3.6 * math.sin(TAU * z) + 0.9 * math.sin(6 * PI * z)
    x, y = rot((x1, y1), -a)
    return np.array((x, y, z)) + 0.5


AXIS = np.ones(3) / math.sqrt(3)


def qro_angle(q):
    return 4.2 * math.tanh(2 * np.linalg.norm(q)) + 2.4 * math.sin(4 * np.dot(AXIS, q))


def qro_rotate(q, angle):
    return q * math.cos(angle) + np.cross(AXIS, q) * math.sin(angle) + AXIS * np.dot(AXIS, q) * (1 - math.cos(angle))


def qro_f(c):
    q = c - 0.5
    return qro_rotate(q, qro_angle(q))


def qro_i(v):
    return qro_rotate(v, -qro_angle(v)) + 0.5


Q = np.array(((1 / math.sqrt(3), 1 / math.sqrt(3), 1 / math.sqrt(3)),
              (1 / math.sqrt(2), 0, -1 / math.sqrt(2)),
              (1 / math.sqrt(6), -2 / math.sqrt(6), 1 / math.sqrt(6))))


def hbp_f(c):
    x, y, z = Q @ (c - 0.5)
    xx = math.asinh(1.6 * x) / 1.6
    y0 = y + 0.32 * math.sin(PI * xx)
    yy = math.asinh(2.1 * y0) / 2.1
    z0 = z - 0.28 * math.cos(PI * yy) + 0.14 * math.sin(PI * xx)
    zz = math.asinh(1.8 * z0) / 1.8
    return np.array((xx, yy, zz))


def hbp_i(v):
    xx, yy, zz = v
    z0 = math.sinh(1.8 * zz) / 1.8
    z = z0 + 0.28 * math.cos(PI * yy) - 0.14 * math.sin(PI * xx)
    y0 = math.sinh(2.1 * yy) / 2.1
    y = y0 - 0.32 * math.sin(PI * xx)
    x = math.sinh(1.6 * xx) / 1.6
    return Q.T @ np.array((x, y, z)) + 0.5


TRANSFORMS = {
    "RSS-1": (rss_f, rss_i),
    "FSS-1": (fss_f, fss_i),
    "CSL-1": (csl_f, csl_i),
    "HCS-1": (hcs_f, hcs_i),
    "PHS-1": (phs_f, phs_i),
    "CSM-1": (lambda c: standard_f(c, 5.8, 0.37, -0.29), lambda v: standard_i(v, 5.8, 0.37, -0.29)),
    "KSM-1": (lambda c: standard_f(c, 8.8, 0.42, -0.34, True), lambda v: standard_i(v, 8.8, 0.42, -0.34, True)),
    "CFE-1": (cfe_f, cfe_i),
    "ANO-1": (lambda c: torus_f(c, ANO), lambda v: torus_i(v, ANO_INV)),
    "CAT-2": (cat_f, cat_i),
    "BRD-2": (brd_f, brd_i),
    "TOR-2": (lambda c: torus_f(c, TOR), lambda v: torus_i(v, TOR_INV)),
    "STD-2": (lambda c: standard_f(c, 7.6, 0.30, -0.27), lambda v: standard_i(v, 7.6, 0.30, -0.27)),
    "QRO-2": (qro_f, qro_i),
    "HBP-2": (hbp_f, hbp_i),
}


def main():
    rng = np.random.default_rng(20260920)
    samples = rng.random((2000, 3))
    for name, (forward, inverse) in TRANSFORMS.items():
        errors = [np.max(np.abs(inverse(forward(sample)) - sample)) for sample in samples]
        maximum = max(errors)
        if maximum > 2e-10:
            raise AssertionError(f"{name} round trip error: {maximum:.3e}")
        print(f"{name}: max error {maximum:.3e}")

    root = Path(__file__).resolve().parents[1]
    effect_source = (root / "ChromaticAberrationEffect.cs").read_text(encoding="utf-8")
    shader_source = (root / "Shaders" / "ChromaticAberration.hlsl").read_text(encoding="utf-8")
    if "ChromaticColorSpace colorSpace = ChromaticColorSpace.Rgb;" not in effect_source:
        raise AssertionError("RGB is not the default color space")
    if shader_source.count("if (colorSpace ==") != 30:
        raise AssertionError("forward/inverse shader dispatch does not cover all 15 spaces")


if __name__ == "__main__":
    main()
