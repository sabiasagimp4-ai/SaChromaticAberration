import math
import random


def opponent(rgb):
    r, g, b = rgb
    return (r - g, (r + g) * 0.5 - b, (r + g + b) / 3.0)


def from_opponent(o):
    a, b, l = o
    return (
        l + b / 3.0 + a / 2.0,
        l + b / 3.0 - a / 2.0,
        l - 2.0 * b / 3.0,
    )


def close3(a, b, eps=1e-7):
    return max(abs(x - y) for x, y in zip(a, b)) < eps


def tos_forward(rgb):
    a, b, l = opponent(rgb)
    rho = math.hypot(a, b)
    phi = math.atan2(b, a)
    rw = rho ** 0.65
    den = math.asinh(1.5)
    z = math.asinh(3.0 * (l - 0.5)) / den
    theta = phi + 1.1 * math.sin(math.pi * z) + 1.8 * rw * rw
    return (rw * math.cos(theta), rw * math.sin(theta), z)


def tos_inverse(c):
    x, y, z = c
    rw = math.hypot(x, y)
    theta = math.atan2(y, x)
    rho = rw ** (1.0 / 0.65)
    phi = theta - 1.1 * math.sin(math.pi * z) - 1.8 * rw * rw
    return from_opponent((
        rho * math.cos(phi),
        rho * math.sin(phi),
        0.5 + math.sinh(z * math.asinh(1.5)) / 3.0,
    ))


def log_forward(rgb):
    eps = 1e-4
    q = [math.log(max(v, 0.0) + eps) for v in rgb]
    return (q[0] - q[1], (q[0] + q[1]) * 0.5 - q[2], sum(q) / 3.0)


def log_inverse(c):
    eps = 1e-4
    u, v, w = c
    a = w + v / 3.0 + u / 2.0
    b = w + v / 3.0 - u / 2.0
    d = w - 2.0 * v / 3.0
    return tuple(math.exp(x) - eps for x in (a, b, d))


def mobius_forward(rgb):
    a, b, l = opponent(rgb)
    cr, ci = 0.45, 0.25
    dr = 1.0 + cr * a - ci * b
    di = cr * b + ci * a
    den = dr * dr + di * di
    return ((a * dr + b * di) / den, (b * dr - a * di) / den, l)


def mobius_inverse(c):
    x, y, l = c
    cr, ci = 0.45, 0.25
    dr = 1.0 - cr * x + ci * y
    di = -cr * y - ci * x
    den = dr * dr + di * di
    return from_opponent(((x * dr + y * di) / den, (y * dr - x * di) / den, l))


def sine_forward(rgb):
    a, b, l = opponent(rgb)
    x = a + 0.35 * math.sin(2.0 * math.pi * l)
    y = b + 0.45 * math.sin(math.pi * x)
    z = l + 0.18 * math.sin(2.0 * math.pi * y)
    return (x, y, z)


def sine_inverse(c):
    x, y, z = c
    l = z - 0.18 * math.sin(2.0 * math.pi * y)
    b = y - 0.45 * math.sin(math.pi * x)
    a = x - 0.35 * math.sin(2.0 * math.pi * l)
    return from_opponent((a, b, l))


M = (
    (1.15, -0.65, 0.20),
    (-0.20, 1.30, -0.70),
    (0.75, 0.15, -0.55),
)
MI = (
    (1.24553344, 0.66870852, -0.39816233),
    (1.29657989, 1.59775396, -1.56202144),
    (2.05206738, 1.34762634, -2.78713629),
)


def matvec(m, v):
    return tuple(sum(a * b for a, b in zip(row, v)) for row in m)


def hyper_forward(rgb):
    q = tuple(v - 0.5 for v in rgb)
    y = matvec(M, q)
    return tuple(math.asinh(2.6 * v) / 2.6 for v in y)


def hyper_inverse(c):
    y = tuple(math.sinh(2.6 * v) / 2.6 for v in c)
    q = matvec(MI, y)
    return tuple(v + 0.5 for v in q)


pairs = [
    (tos_forward, tos_inverse),
    (log_forward, log_inverse),
    (mobius_forward, mobius_inverse),
    (sine_forward, sine_inverse),
    (hyper_forward, hyper_inverse),
]

rng = random.Random(0)
for _ in range(10000):
    rgb = (rng.random(), rng.random(), rng.random())
    for forward, inverse in pairs:
        restored = inverse(forward(rgb))
        assert close3(rgb, restored, 2e-7), (forward.__name__, rgb, restored)

print("all experimental color spaces round-trip")
