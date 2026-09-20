using System.Numerics;
using Vortice.Direct2D1;
using YukkuriMovieMaker.Commons;
using YukkuriMovieMaker.Player.Video;

namespace SaChromaticAberration;

internal sealed class ChromaticAberrationProcessor : IVideoEffectProcessor
{
    readonly IGraphicsDevicesAndContext devices;
    readonly ChromaticAberrationEffect item;
    readonly ChromaticAberrationCustomEffect? effect;
    readonly ID2D1Image? output;
    ID2D1Image? input;

    public ChromaticAberrationProcessor(IGraphicsDevicesAndContext devices, ChromaticAberrationEffect item)
    {
        this.devices = devices;
        this.item = item;

        //ShaderModel非対応環境ではパススルーする
        var effect = new ChromaticAberrationCustomEffect(devices);
        if (!effect.IsEnabled)
        {
            effect.Dispose();
            return;
        }
        this.effect = effect;
        output = effect.Output;
    }

    public ID2D1Image Output => output ?? input ?? throw new InvalidOperationException("入力が未設定です。");

    public void SetInput(ID2D1Image? input)
    {
        this.input = input;
        effect?.SetInput(0, input, true);
    }

    public void ClearInput()
    {
        input = null;
        effect?.SetInput(0, null, true);
    }

    public DrawDescription Update(EffectDescription effectDescription)
    {
        if (effect is null || input is null)
            return effectDescription.DrawDescription;

        var frame = effectDescription.ItemPosition.Frame;
        var length = effectDescription.ItemDuration.Frame;
        var fps = effectDescription.FPS;

        var bounds = devices.DeviceContext.GetImageLocalBounds(input);
        if (!float.IsFinite(bounds.Left) || !float.IsFinite(bounds.Top) || !float.IsFinite(bounds.Right) || !float.IsFinite(bounds.Bottom))
        {
            //無限大の矩形では中心が定まらないのでパススルーする
            effect.MixAmount = 0;
            return effectDescription.DrawDescription;
        }

        var centerX = item.CenterX.GetValue(frame, length, fps);
        var centerY = item.CenterY.GetValue(frame, length, fps);
        var aberration = item.Aberration.GetValue(frame, length, fps);
        var radialAngle = item.Radial.GetValue(frame, length, fps) * Math.PI / 180d;
        var scaleAmount = item.Scale.GetValue(frame, length, fps) / 100d;
        var falloffPower = Math.Clamp(item.Falloff.GetValue(frame, length, fps), 0d, 8d);

        effect.ImageRect = new Vector4(bounds.Left, bounds.Top, bounds.Right, bounds.Bottom);
        effect.CenterOffsetX = (float)centerX;
        effect.CenterOffsetY = (float)centerY;
        effect.Aberration = (float)aberration;
        effect.RadialAngle = (float)radialAngle;
        effect.ScaleAmount = (float)scaleAmount;
        effect.MixAmount = (float)(item.Mix.GetValue(frame, length, fps) / 100d);
        effect.FalloffPower = (float)falloffPower;

        //サンプル間隔が1px未満になる分は描画に効かないので、上限をずれ量に合わせて下げる
        var width = (double)bounds.Right - bounds.Left;
        var height = (double)bounds.Bottom - bounds.Top;
        var maxRadius = Math.Sqrt(width * width + height * height) / 2 + Math.Sqrt(centerX * centerX + centerY * centerY);
        //収差は中心から離れるほど強くなるので、最も強い角を基準にする
        var falloffMax = ChromaticAberrationCustomEffect.Impl.FalloffMax(width, height, falloffPower, centerX, centerY);
        var needed = 2 * Math.Abs(aberration) * falloffMax + 2 * maxRadius * (Math.Abs(scaleAmount) + Math.Abs(radialAngle));
        effect.StepCount = (int)Math.Clamp(Math.Ceiling(needed), 2, item.Steps);

        return effectDescription.DrawDescription;
    }

    public void Dispose()
    {
        ClearInput();
        output?.Dispose();
        effect?.Dispose();
    }
}
