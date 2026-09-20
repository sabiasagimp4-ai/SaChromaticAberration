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
float2 _constantPadding;

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

        float a = radialAngle * s;
        float ca = cos(a), sa = sin(a);
        float2 rotated = float2(d.x * ca - d.y * sa, d.x * sa + d.y * ca);
        float2 q = center + rotated * (1.0 + scaleAmount * s) + dir * (aberration * falloff * s);

        float4 smp = D2DSampleInputAtPosition(0, clamp(q, sampleMin, sampleMax));
        float3 straight = smp.a > 0 ? smp.rgb / smp.a : float3(0, 0, 0);
        float3 w = spectralWeight(t);

        // Alpha-weight straight color so invisible samples cannot darken visible ones.
        sumColor += straight * smp.a * w;
        sumCoverage += smp.a * w;
        sumAlpha += smp.a;
    }

    float3 color = sumColor / max(sumCoverage, 1e-5);
    float alpha = sumAlpha / (float)n;
    float4 result = float4(saturate(color) * alpha, alpha);

    return lerp(source, result, mixAmount);
}
