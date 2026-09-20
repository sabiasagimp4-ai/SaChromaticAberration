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
int colorSpaceMode; // 0=RGB, 1=TOS-1, 2=LRS-1, 3=MOS-1, 4=RSS-1, 5=HCS-1

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


float asinhSafe(float x)
{
    return log(x + sqrt(x * x + 1.0));
}

float sinhSafe(float x)
{
    float a = clamp(x, -20.0, 20.0);
    return 0.5 * (exp(a) - exp(-a));
}

// Opponent basis used by several experimental spaces.
// x = R-G, y = (R+G)/2-B, z = mean luminance-like component.
float3 rgbToOpponent(float3 c)
{
    return float3(c.r - c.g, (c.r + c.g) * 0.5 - c.b, (c.r + c.g + c.b) / 3.0);
}

float3 opponentToRgb(float3 o)
{
    float A = o.x;
    float B = o.y;
    float L = o.z;
    return float3(
        L + B / 3.0 + A / 2.0,
        L + B / 3.0 - A / 2.0,
        L - 2.0 * B / 3.0);
}

float3 forwardColorSpace(float3 rgb)
{
    if (colorSpaceMode == 0)
        return rgb;

    if (colorSpaceMode == 1)
    {
        // TOS-1: opponent chroma is bent by luminance and chroma magnitude.
        float3 o = rgbToOpponent(rgb);
        float rho = length(o.xy);
        float phi = atan2(o.y, o.x);
        float rw = pow(max(rho, 0.0), 0.65);
        float den = asinhSafe(1.5);
        float Z = asinhSafe(3.0 * (o.z - 0.5)) / den;
        float theta = phi + 1.1 * sin(3.14159265 * Z) + 1.8 * rw * rw;
        return float3(rw * cos(theta), rw * sin(theta), Z);
    }

    if (colorSpaceMode == 2)
    {
        // LRS-1: multiplicative RGB relationships become additive log-ratio axes.
        const float eps = 1e-4;
        float3 q = log(max(rgb, 0.0) + eps);
        float U = q.r - q.g;
        float V = (q.r + q.g) * 0.5 - q.b;
        float W = (q.r + q.g + q.b) / 3.0;
        return float3(U, V, W);
    }

    if (colorSpaceMode == 3)
    {
        // MOS-1: Möbius transform on the opponent-color plane.
        float3 o = rgbToOpponent(rgb);
        float A = o.x;
        float B = o.y;
        const float cr = 0.45;
        const float ci = 0.25;
        float dr = 1.0 + cr * A - ci * B;
        float di = cr * B + ci * A;
        float den = max(dr * dr + di * di, 1e-6);
        float X = (A * dr + B * di) / den;
        float Y = (B * dr - A * di) / den;
        return float3(X, Y, o.z);
    }

    if (colorSpaceMode == 4)
    {
        // RSS-1: triangular reversible sine shears.
        float3 o = rgbToOpponent(rgb);
        float X = o.x + 0.35 * sin(6.28318531 * o.z);
        float Y = o.y + 0.45 * sin(3.14159265 * X);
        float Z = o.z + 0.18 * sin(6.28318531 * Y);
        return float3(X, Y, Z);
    }

    // HCS-1: strongly mixed axes followed by hyperbolic compression.
    float3 q = rgb - 0.5;
    float3 y = float3(
        1.15 * q.r - 0.65 * q.g + 0.20 * q.b,
       -0.20 * q.r + 1.30 * q.g - 0.70 * q.b,
        0.75 * q.r + 0.15 * q.g - 0.55 * q.b);
    return float3(
        asinhSafe(2.6 * y.x) / 2.6,
        asinhSafe(2.6 * y.y) / 2.6,
        asinhSafe(2.6 * y.z) / 2.6);
}

float3 inverseColorSpace(float3 c)
{
    if (colorSpaceMode == 0)
        return c;

    if (colorSpaceMode == 1)
    {
        float rw = length(c.xy);
        float theta = atan2(c.y, c.x);
        float rho = pow(max(rw, 0.0), 1.0 / 0.65);
        float phi = theta - 1.1 * sin(3.14159265 * c.z) - 1.8 * rw * rw;
        float A = rho * cos(phi);
        float B = rho * sin(phi);
        float L = 0.5 + sinhSafe(c.z * asinhSafe(1.5)) / 3.0;
        return opponentToRgb(float3(A, B, L));
    }

    if (colorSpaceMode == 2)
    {
        const float eps = 1e-4;
        float a = c.z + c.y / 3.0 + c.x / 2.0;
        float b = c.z + c.y / 3.0 - c.x / 2.0;
        float d = c.z - 2.0 * c.y / 3.0;
        return exp(float3(a, b, d)) - eps;
    }

    if (colorSpaceMode == 3)
    {
        const float cr = 0.45;
        const float ci = 0.25;
        float X = c.x;
        float Y = c.y;
        float dr = 1.0 - cr * X + ci * Y;
        float di = -cr * Y - ci * X;
        float den = max(dr * dr + di * di, 1e-6);
        float A = (X * dr + Y * di) / den;
        float B = (Y * dr - X * di) / den;
        return opponentToRgb(float3(A, B, c.z));
    }

    if (colorSpaceMode == 4)
    {
        float L = c.z - 0.18 * sin(6.28318531 * c.y);
        float B = c.y - 0.45 * sin(3.14159265 * c.x);
        float A = c.x - 0.35 * sin(6.28318531 * L);
        return opponentToRgb(float3(A, B, L));
    }

    float3 y = float3(
        sinhSafe(2.6 * c.x) / 2.6,
        sinhSafe(2.6 * c.y) / 2.6,
        sinhSafe(2.6 * c.z) / 2.6);

    float3 q = float3(
        1.24553344 * y.x + 0.66870852 * y.y - 0.39816233 * y.z,
        1.29657989 * y.x + 1.59775396 * y.y - 1.56202144 * y.z,
        2.05206738 * y.x + 1.34762634 * y.y - 2.78713629 * y.z);
    return q + 0.5;
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
        float3 transformed = forwardColorSpace(straight);
        float3 w = spectralWeight(t);

        // Apply the original spectral weighting to the selected color-space axes.
        // RGB mode is exactly the previous behavior.
        sumColor += transformed * smp.a * w;
        sumCoverage += smp.a * w;
        sumAlpha += smp.a;
    }

    float3 transformedColor = sumColor / max(sumCoverage, 1e-5);
    float3 color = inverseColorSpace(transformedColor);
    float alpha = sumAlpha / (float)n;
    float4 result = float4(saturate(color) * alpha, alpha);

    return lerp(source, result, mixAmount);
}
