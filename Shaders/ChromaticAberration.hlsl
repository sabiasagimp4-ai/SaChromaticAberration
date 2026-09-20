#define D2D_ENTRY main
#include <d2d1effecthelpers.hlsli>

float4 imageRect;    // left, top, right, bottom (シーン座標)
float centerOffsetX; // 中心のずらし量(px)
float centerOffsetY;
float aberration;    // 半径方向のずらし量(px)
float radialAngle;   // ねじれ角(rad)
float scaleAmount;   // 拡大方向のずらし量(比率)
float mixAmount;     // 合成量 0..1
int stepCount;       // サンプル数
float falloffPower;  // 中心からの距離に対する収差の増え方。2で距離の二乗に比例
float radiusScale;   // 減衰半径の倍率。1.0が従来の画面基準
int falloffMode;     // 0=冪乗, 1=三乗, 2=四乗, 3=六乗, 4=指数
int scaleMode;       // 0=absolute linear, 1=positive exponential
int colorSpace;      // 0=RGB, 1..15=experimental transforms

static const float PI = 3.14159265358979323846;
static const float TWO_PI = 6.28318530717958647692;

float wrap01(float value)
{
    return value - floor(value);
}

float3 wrap01(float3 value)
{
    return value - floor(value);
}

float cube(float value)
{
    return value * value * value;
}

// fxc ps_4_0 does not expose every inverse hyperbolic intrinsic consistently,
// so keep the small set needed by the transforms here.
float safeAsinh(float value)
{
    float magnitude = abs(value);
    return sign(value) * log(magnitude + sqrt(magnitude * magnitude + 1.0));
}

float safeSinh(float value)
{
    value = clamp(value, -12.0, 12.0);
    return 0.5 * (exp(value) - exp(-value));
}

float safeTanh(float value)
{
    float e = exp(-2.0 * min(abs(value), 20.0));
    return sign(value) * (1.0 - e) / (1.0 + e);
}

float3 rgbToOpponent(float3 color)
{
    float l = (color.r + color.g + color.b) / 3.0;
    float a = color.r - color.g;
    float b = (color.r + color.g) * 0.5 - color.b;
    return float3(l, a, b);
}

float3 opponentToRgb(float l, float a, float b)
{
    return float3(
        l + b / 3.0 + a * 0.5,
        l + b / 3.0 - a * 0.5,
        l - 2.0 * b / 3.0);
}

// RSS-1 — Reversible Sine Shear
float3 rssForward(float3 color)
{
    float3 lab = rgbToOpponent(color);
    float x = lab.y + 0.35 * sin(TWO_PI * lab.x);
    float y = lab.z + 0.45 * sin(PI * x);
    float z = lab.x + 0.18 * sin(TWO_PI * y);
    return float3(x, y, z);
}

float3 rssInverse(float3 value)
{
    float l = value.z - 0.18 * sin(TWO_PI * value.y);
    float b = value.y - 0.45 * sin(PI * value.x);
    float a = value.x - 0.35 * sin(TWO_PI * l);
    return opponentToRgb(l, a, b);
}

// FSS-1 — Golden Shear
float3 fssForward(float3 color)
{
    const float golden = 1.618033988749895;
    const float golden2 = 2.618033988749895;
    float3 q = color - 0.5;
    float x = q.x + golden * q.y;
    float y = q.y + golden2 * q.z;
    float z = q.z + x / golden;
    return float3(x, y, z);
}

float3 fssInverse(float3 value)
{
    const float golden = 1.618033988749895;
    const float golden2 = 2.618033988749895;
    float z = value.z - value.x / golden;
    float y = value.y - golden2 * z;
    float x = value.x - golden * y;
    return float3(x, y, z) + 0.5;
}

// CSL-1 — Complex Spiral
float3 cslForward(float3 color)
{
    float3 lab = rgbToOpponent(color);
    float rho = length(lab.yz);
    float phase = atan2(lab.z, lab.y);
    float radius = safeAsinh(2.8 * rho) / 2.8;
    float z = safeAsinh(2.2 * (lab.x - 0.5)) / 2.2;
    float theta = phase + 3.4 * log(1.0 + 5.0 * rho * rho) + 1.7 * sin(TWO_PI * lab.x);
    return float3(radius * cos(theta), radius * sin(theta), z);
}

float3 cslInverse(float3 value)
{
    float radius = length(value.xy);
    float rho = safeSinh(2.8 * radius) / 2.8;
    float l = 0.5 + safeSinh(2.2 * value.z) / 2.2;
    float phase = atan2(value.y, value.x)
        - 3.4 * log(1.0 + 5.0 * rho * rho)
        - 1.7 * sin(TWO_PI * l);
    return opponentToRgb(l, rho * cos(phase), rho * sin(phase));
}

// HCS-1 — Hyperbolic Cross
float3 hcsForward(float3 color)
{
    float3 q = color - 0.5;
    float3 y = float3(
        1.15 * q.x - 0.65 * q.y + 0.20 * q.z,
        -0.20 * q.x + 1.30 * q.y - 0.70 * q.z,
        0.75 * q.x + 0.15 * q.y - 0.55 * q.z);
    return float3(
        safeAsinh(2.6 * y.x) / 2.6,
        safeAsinh(2.6 * y.y) / 2.6,
        safeAsinh(2.6 * y.z) / 2.6);
}

float3 hcsInverse(float3 value)
{
    float3 y = float3(
        safeSinh(2.6 * value.x) / 2.6,
        safeSinh(2.6 * value.y) / 2.6,
        safeSinh(2.6 * value.z) / 2.6);
    float3 q = float3(
        1.2455334354 * y.x + 0.6687085248 * y.y - 0.3981623277 * y.z,
        1.2965798877 * y.x + 1.5977539561 * y.y - 1.5620214395 * y.z,
        2.0520673813 * y.x + 1.3476263400 * y.y - 2.7871362940 * y.z);
    return q + 0.5;
}

// PHS-1 — Prime Harmonic
float3 phsForward(float3 color)
{
    float3 lab = rgbToOpponent(color);
    float w = lab.x - 0.5;
    float x = lab.y + 0.30 * sin(4.0 * PI * lab.z) + 0.15 * sin(10.0 * PI * w);
    float y = lab.z + 0.36 * sin(6.0 * PI * x);
    float z = w + 0.24 * sin(10.0 * PI * y);
    return float3(x, y, z);
}

float3 phsInverse(float3 value)
{
    float w = value.z - 0.24 * sin(10.0 * PI * value.y);
    float b = value.y - 0.36 * sin(6.0 * PI * value.x);
    float a = value.x - 0.30 * sin(4.0 * PI * b) - 0.15 * sin(10.0 * PI * w);
    return opponentToRgb(w + 0.5, a, b);
}

// CSM-1 — Chirikov Standard Map
float3 csmForward(float3 color)
{
    float x = wrap01(color.r);
    float p = wrap01(color.g);
    float z = wrap01(color.b);
    float p1 = wrap01(p + (5.8 / TWO_PI) * sin(TWO_PI * x));
    float x1 = wrap01(x + p1);
    float z1 = wrap01(z + 0.37 * sin(TWO_PI * x1) - 0.29 * sin(TWO_PI * p1));
    return float3(x1, p1, z1);
}

float3 csmInverse(float3 value)
{
    float x1 = wrap01(value.x);
    float p1 = wrap01(value.y);
    float z1 = wrap01(value.z);
    float x = wrap01(x1 - p1);
    float p = wrap01(p1 - (5.8 / TWO_PI) * sin(TWO_PI * x));
    float z = wrap01(z1 - 0.37 * sin(TWO_PI * x1) + 0.29 * sin(TWO_PI * p1));
    return float3(x, p, z);
}

// KSM-1 — Kicked Standard
float3 ksmForward(float3 color)
{
    float x = wrap01(color.r);
    float p = wrap01(color.g);
    float z = wrap01(color.b);
    float p1 = wrap01(p + (8.8 / TWO_PI) * sin(TWO_PI * x));
    float x1 = wrap01(x + p1);
    float z1 = wrap01(z + 0.42 * sin(TWO_PI * x1) - 0.34 * sin(TWO_PI * (x1 + p1)));
    return float3(x1, p1, z1);
}

float3 ksmInverse(float3 value)
{
    float x1 = wrap01(value.x);
    float p1 = wrap01(value.y);
    float z1 = wrap01(value.z);
    float x = wrap01(x1 - p1);
    float p = wrap01(p1 - (8.8 / TWO_PI) * sin(TWO_PI * x));
    float z = wrap01(z1 - 0.42 * sin(TWO_PI * x1) + 0.34 * sin(TWO_PI * (x1 + p1)));
    return float3(x, p, z);
}

// CFE-1 — Continued-Fraction Natural Extension
float3 cfeForward(float3 color)
{
    const float epsilon = 0.001;
    float3 squeezed = epsilon + (1.0 - 2.0 * epsilon) * saturate(color);
    float n = floor(1.0 / squeezed.x);
    float x = 1.0 / squeezed.x - n;
    float y = 1.0 / (n + squeezed.y);
    float z = wrap01(squeezed.z + 0.23 * sin(TWO_PI * x) + 0.17 * sin(TWO_PI * y));
    return float3(x, y, z);
}

float3 cfeInverse(float3 value)
{
    const float epsilon = 0.001;
    float yCoordinate = max(value.y, 1e-5);
    float n = clamp(floor(1.0 / yCoordinate), 1.0, 1000.0);
    float x = 1.0 / max(n + value.x, 1e-5);
    float y = 1.0 / yCoordinate - n;
    float z = wrap01(value.z - 0.23 * sin(TWO_PI * value.x) - 0.17 * sin(TWO_PI * value.y));
    return (float3(x, y, z) - epsilon) / (1.0 - 2.0 * epsilon);
}

// ANO-1 — Anosov Torus
float3 anoForward(float3 color)
{
    float3 x = wrap01(color);
    return wrap01(float3(
        2.0 * x.x + x.y + x.z,
        x.x + x.y + x.z,
        x.x + x.y));
}

float3 anoInverse(float3 value)
{
    float3 y = wrap01(value);
    return wrap01(float3(
        y.x - y.y,
        -y.x + y.y + y.z,
        y.y - y.z));
}

// CAT-2 — Optical Catastrophe
float3 catForward(float3 color)
{
    float3 q = color - 0.5;
    float x = q.x + 0.70 * cube(q.y) + 0.18 * sin(6.0 * PI * q.y);
    float y = q.y + 0.80 * cube(q.z) + 0.24 * sin(4.0 * PI * x);
    float z = q.z + 0.75 * cube(x) - 0.28 * y + 0.12 * sin(TWO_PI * x);
    return float3(x, y, z);
}

float3 catInverse(float3 value)
{
    float z = value.z - 0.75 * cube(value.x) + 0.28 * value.y - 0.12 * sin(TWO_PI * value.x);
    float y = value.y - 0.80 * cube(z) - 0.24 * sin(4.0 * PI * value.x);
    float x = value.x - 0.70 * cube(y) - 0.18 * sin(6.0 * PI * y);
    return float3(x, y, z) + 0.5;
}

float2 rotate2(float2 value, float angle)
{
    float cosine = cos(angle);
    float sine = sin(angle);
    return float2(cosine * value.x - sine * value.y, sine * value.x + cosine * value.y);
}

// BRD-2 — Braid Catastrophe
float3 brdForward(float3 color)
{
    float3 q = color - 0.5;
    float a = 3.6 * sin(TWO_PI * q.z) + 0.9 * sin(6.0 * PI * q.z);
    float2 xy1 = rotate2(q.xy, a);
    float b = 3.2 * sin(TWO_PI * xy1.x) - 0.8 * cos(4.0 * PI * xy1.x);
    float2 yz2 = rotate2(float2(xy1.y, q.z), b);
    float c = 3.8 * sin(TWO_PI * yz2.x) + 1.1 * sin(4.0 * PI * yz2.x);
    float2 zx3 = rotate2(float2(yz2.y, xy1.x), c);
    return float3(zx3.y, yz2.x, zx3.x);
}

float3 brdInverse(float3 value)
{
    float c = 3.8 * sin(TWO_PI * value.y) + 1.1 * sin(4.0 * PI * value.y);
    float2 zx2 = rotate2(float2(value.z, value.x), -c);
    float z2 = zx2.x;
    float x1 = zx2.y;
    float b = 3.2 * sin(TWO_PI * x1) - 0.8 * cos(4.0 * PI * x1);
    float2 yz1 = rotate2(float2(value.y, z2), -b);
    float y1 = yz1.x;
    float z = yz1.y;
    float a = 3.6 * sin(TWO_PI * z) + 0.9 * sin(6.0 * PI * z);
    float2 xy = rotate2(float2(x1, y1), -a);
    return float3(xy, z) + 0.5;
}

// TOR-2 — Integer Torus
float3 torForward(float3 color)
{
    float3 x = wrap01(color);
    return wrap01(float3(
        x.x + x.y + x.z,
        x.x + 2.0 * x.y + x.z,
        x.x + x.y + 2.0 * x.z));
}

float3 torInverse(float3 value)
{
    float3 y = wrap01(value);
    return wrap01(float3(
        3.0 * y.x - y.y - y.z,
        -y.x + y.y,
        -y.x + y.z));
}

// STD-2 — Double Standard
float3 stdForward(float3 color)
{
    float x = wrap01(color.r);
    float p = wrap01(color.g);
    float z = wrap01(color.b);
    float p1 = wrap01(p + (7.6 / TWO_PI) * sin(TWO_PI * x));
    float x1 = wrap01(x + p1);
    float z1 = wrap01(z + 0.30 * sin(TWO_PI * x1) - 0.27 * sin(TWO_PI * p1));
    return float3(x1, p1, z1);
}

float3 stdInverse(float3 value)
{
    float x1 = wrap01(value.x);
    float p1 = wrap01(value.y);
    float z1 = wrap01(value.z);
    float x = wrap01(x1 - p1);
    float p = wrap01(p1 - (7.6 / TWO_PI) * sin(TWO_PI * x));
    float z = wrap01(z1 - 0.30 * sin(TWO_PI * x1) + 0.27 * sin(TWO_PI * p1));
    return float3(x, p, z);
}

// QRO-2 — Quaternion Ribbon
float3 qroRotate(float3 q, float angle)
{
    const float inverseSqrt3 = 0.5773502691896258;
    float3 axis = float3(inverseSqrt3, inverseSqrt3, inverseSqrt3);
    float cosine = cos(angle);
    float sine = sin(angle);
    return q * cosine + cross(axis, q) * sine + axis * dot(axis, q) * (1.0 - cosine);
}

float qroAngle(float3 q)
{
    const float inverseSqrt3 = 0.5773502691896258;
    float rho = length(q);
    float projection = dot(float3(inverseSqrt3, inverseSqrt3, inverseSqrt3), q);
    return 4.2 * safeTanh(2.0 * rho) + 2.4 * sin(4.0 * projection);
}

float3 qroForward(float3 color)
{
    float3 q = color - 0.5;
    return qroRotate(q, qroAngle(q));
}

float3 qroInverse(float3 value)
{
    return qroRotate(value, -qroAngle(value)) + 0.5;
}

// HBP-2 — Hyperbolic Prism
float3 hbpBasisForward(float3 q)
{
    const float inverseSqrt3 = 0.5773502691896258;
    const float inverseSqrt2 = 0.7071067811865475;
    const float inverseSqrt6 = 0.4082482904638630;
    return float3(
        (q.x + q.y + q.z) * inverseSqrt3,
        (q.x - q.z) * inverseSqrt2,
        (q.x - 2.0 * q.y + q.z) * inverseSqrt6);
}

float3 hbpBasisInverse(float3 value)
{
    const float inverseSqrt3 = 0.5773502691896258;
    const float inverseSqrt2 = 0.7071067811865475;
    const float inverseSqrt6 = 0.4082482904638630;
    return float3(
        value.x * inverseSqrt3 + value.y * inverseSqrt2 + value.z * inverseSqrt6,
        value.x * inverseSqrt3 - 2.0 * value.z * inverseSqrt6,
        value.x * inverseSqrt3 - value.y * inverseSqrt2 + value.z * inverseSqrt6);
}

float3 hbpForward(float3 color)
{
    float3 q = hbpBasisForward(color - 0.5);
    float x = safeAsinh(1.6 * q.x) / 1.6;
    float y0 = q.y + 0.32 * sin(PI * x);
    float y = safeAsinh(2.1 * y0) / 2.1;
    float z0 = q.z - 0.28 * cos(PI * y) + 0.14 * sin(PI * x);
    float z = safeAsinh(1.8 * z0) / 1.8;
    return float3(x, y, z);
}

float3 hbpInverse(float3 value)
{
    float z0 = safeSinh(1.8 * value.z) / 1.8;
    float z = z0 + 0.28 * cos(PI * value.y) - 0.14 * sin(PI * value.x);
    float y0 = safeSinh(2.1 * value.y) / 2.1;
    float y = y0 - 0.32 * sin(PI * value.x);
    float x = safeSinh(1.6 * value.x) / 1.6;
    return hbpBasisInverse(float3(x, y, z)) + 0.5;
}

float3 colorForward(float3 color)
{
    if (colorSpace == 1) return rssForward(color);
    if (colorSpace == 2) return fssForward(color);
    if (colorSpace == 3) return cslForward(color);
    if (colorSpace == 4) return hcsForward(color);
    if (colorSpace == 5) return phsForward(color);
    if (colorSpace == 6) return csmForward(color);
    if (colorSpace == 7) return ksmForward(color);
    if (colorSpace == 8) return cfeForward(color);
    if (colorSpace == 9) return anoForward(color);
    if (colorSpace == 10) return catForward(color);
    if (colorSpace == 11) return brdForward(color);
    if (colorSpace == 12) return torForward(color);
    if (colorSpace == 13) return stdForward(color);
    if (colorSpace == 14) return qroForward(color);
    if (colorSpace == 15) return hbpForward(color);
    return color;
}

float3 colorInverse(float3 value)
{
    if (colorSpace == 1) return rssInverse(value);
    if (colorSpace == 2) return fssInverse(value);
    if (colorSpace == 3) return cslInverse(value);
    if (colorSpace == 4) return hcsInverse(value);
    if (colorSpace == 5) return phsInverse(value);
    if (colorSpace == 6) return csmInverse(value);
    if (colorSpace == 7) return ksmInverse(value);
    if (colorSpace == 8) return cfeInverse(value);
    if (colorSpace == 9) return anoInverse(value);
    if (colorSpace == 10) return catInverse(value);
    if (colorSpace == 11) return brdInverse(value);
    if (colorSpace == 12) return torInverse(value);
    if (colorSpace == 13) return stdInverse(value);
    if (colorSpace == 14) return qroInverse(value);
    if (colorSpace == 15) return hbpInverse(value);
    return value;
}

// 波長に見立てた重み。t=0が青、t=1が赤。どの t でも正の値を返すので、
// ずらし量 0 のときは 3 チャンネルとも同じ画素を参照し、完全に入力と一致する。
float3 spectralWeight(float t)
{
    float3 mu = float3(1.0, 0.5, 0.0);
    float3 d = (t - mu) / 0.25;
    return exp(-0.5 * d * d);
}

float falloffValue(float radius)
{
    radius = max(radius, 0.0);
    float exponent = max(falloffPower, 0.0);

    if (falloffMode == 1)
        exponent = max(exponent, 3.0);
    else if (falloffMode == 2)
        exponent = max(exponent, 4.0);
    else if (falloffMode == 3)
        exponent = max(exponent, 6.0);
    else if (falloffMode == 4)
    {
        // Normalized exponential curve. It equals 0 at radius 0 and 1 at radius 1,
        // then rises more sharply than a quadratic curve outside the radius.
        exponent = max(exponent, 2.0);
        // Keep the radius=1 normalization exact for the full exponent range (0..32).
        // Values beyond that are capped only to avoid floating-point overflow.
        float numerator = exp2(min(radius * exponent, 64.0)) - 1.0;
        float denominator = max(exp2(exponent) - 1.0, 1e-5);
        return min(numerator / denominator, 1e6);
    }

    if (exponent <= 0.0)
        return 1.0;
    return min(pow(radius, exponent), 1e6);
}

D2D_PS_ENTRY(main)
{
    float2 p = D2DGetScenePosition().xy;
    float4 source = D2DSampleInputAtPosition(0, p);

    if (mixAmount <= 0 || (aberration == 0 && radialAngle == 0 && scaleAmount == 0))
        return source;

    // Clamp to pixel centers: sampling at the boundary still blends with transparent border texels.
    float2 sampleMin = imageRect.xy + min(0.5, (imageRect.zw - imageRect.xy) * 0.5);
    float2 sampleMax = max(sampleMin, imageRect.zw - 0.5);
    int n = clamp(stepCount, 2, 2048);
    float2 halfSize = max((imageRect.zw - imageRect.xy) * 0.5, 1e-5);
    float2 center = (imageRect.xy + imageRect.zw) * 0.5 + float2(centerOffsetX, centerOffsetY);
    float2 d = p - center;
    float r = length(d);
    float2 dir = r > 1e-5 ? d / r : float2(0, 0);

    //中心で0、画面端の中点で1になる正規化半径。縦横で割るので等高線は画面比と同じ楕円になる
    float rn = length(d / halfSize) / max(radiusScale, 1e-4);
    float falloff = falloffValue(rn);

    float3 sumColor = 0;
    float3 sumCoverage = 0;
    float sumAlpha = 0;

    [loop] for (int i = 0; i < n; ++i)
    {
        float t = (float)i / (float)(n - 1);
        float s = t * 2.0 - 1.0;

        float a = radialAngle * falloff * s;
        float ca = cos(a), sa = sin(a);
        float2 rotated = float2(d.x * ca - d.y * sa, d.x * sa + d.y * ca);
        float scaleShift = scaleAmount * falloff * s;
        // Natural exponential matches the linear slope near zero. Limit the exponent
        // symmetrically to keep reciprocal positive zoom factors finite.
        float zoom = scaleMode == 1 ? exp(clamp(scaleShift, -16.0, 16.0)) : abs(1.0 + scaleShift);
        float2 q = center + rotated * zoom + dir * (aberration * falloff * s);

        float4 smp = D2DSampleInputAtPosition(0, clamp(q, sampleMin, sampleMax));
        float3 straight = smp.a > 0 ? smp.rgb / smp.a : float3(0, 0, 0);
        float3 transformed = colorForward(straight);
        float3 w = spectralWeight(t);

        // Alpha-weight straight color so invisible samples cannot darken visible ones.
        sumColor += transformed * smp.a * w;
        sumCoverage += smp.a * w;
        sumAlpha += smp.a;
    }

    float3 transformedColor = sumColor / max(sumCoverage, 1e-5);
    float3 color = colorInverse(transformedColor);
    float alpha = sumAlpha / (float)n;
    float4 result = float4(saturate(color) * alpha, alpha);

    return lerp(source, result, mixAmount);
}
