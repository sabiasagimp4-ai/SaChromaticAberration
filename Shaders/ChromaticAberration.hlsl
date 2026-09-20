#define D2D_ENTRY main
#include <d2d1effecthelpers.hlsli>

float4 imageRect;    // left, top, right, bottom (シーン座標)
float centerOffsetX; // 中心のずらし量(px)
float centerOffsetY;
float aberration;    // 半径方向のずらし量(px)
float radialAngle;   // 色の分離方向(rad)
float scaleAmount;   // 拡大方向のずらし量(比率)
float mixAmount;     // 合成量 0..1
int stepCount;       // 旧設定との互換用。現在はRGB 3サンプル固定
float falloffPower;  // 中心からの距離に対する収差の増え方。2で距離の二乗に比例

D2D_PS_ENTRY(main)
{
    float2 p = D2DGetScenePosition().xy;
    float4 source = D2DSampleInputAtPosition(0, p);

    if (mixAmount <= 0 || (aberration == 0 && radialAngle == 0 && scaleAmount == 0))
        return source;

    // Clamp to pixel centers: sampling at the boundary still blends with transparent border texels.
    float2 sampleMin = imageRect.xy + min(0.5, (imageRect.zw - imageRect.xy) * 0.5);
    float2 sampleMax = max(sampleMin, imageRect.zw - 0.5);
    float2 halfSize = max((imageRect.zw - imageRect.xy) * 0.5, 1e-5);
    float2 center = (imageRect.xy + imageRect.zw) * 0.5 + float2(centerOffsetX, centerOffsetY);
    float2 d = p - center;
    float r = length(d);
    float2 dir = r > 1e-5 ? d / r : float2(0, 0);

    //中心で0、画面端の中点で1になる正規化半径。縦横で割るので等高線は画面比と同じ楕円になる
    float rn = length(d / halfSize);
    float falloff = pow(rn, falloffPower);

    // Radial is the direction of the separation. Rotate the displacement vector,
    // rather than rotating the complete image for every spectral sample.
    float ca = cos(radialAngle), sa = sin(radialAngle);
    float2 separationDir = float2(dir.x * ca - dir.y * sa, dir.x * sa + dir.y * ca);

    float2 qRed = center + d * (1.0 + scaleAmount) + separationDir * (aberration * falloff);
    float2 qGreen = center + d;
    float2 qBlue = center + d * (1.0 - scaleAmount) - separationDir * (aberration * falloff);

    float4 redSample = D2DSampleInputAtPosition(0, clamp(qRed, sampleMin, sampleMax));
    float4 greenSample = D2DSampleInputAtPosition(0, clamp(qGreen, sampleMin, sampleMax));
    float4 blueSample = D2DSampleInputAtPosition(0, clamp(qBlue, sampleMin, sampleMax));

    // D2D inputs are premultiplied. Unpremultiply each sample before selecting
    // its channel, then restore the original pixel alpha.
    float red = redSample.a > 1e-5 ? redSample.r / redSample.a : 0.0;
    float green = greenSample.a > 1e-5 ? greenSample.g / greenSample.a : 0.0;
    float blue = blueSample.a > 1e-5 ? blueSample.b / blueSample.a : 0.0;
    float alpha = source.a;
    float4 result = float4(saturate(float3(red, green, blue)) * alpha, alpha);

    return lerp(source, result, mixAmount);
}
