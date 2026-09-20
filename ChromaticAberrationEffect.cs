using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using YukkuriMovieMaker.Commons;
using YukkuriMovieMaker.Controls;
using YukkuriMovieMaker.Exo;
using YukkuriMovieMaker.Player.Video;
using YukkuriMovieMaker.Plugin.Effects;

namespace SaChromaticAberration;

public enum ChromaticScaleMode
{
    [Display(Name = "絶対値（反転なし）")] Absolute = 0,
    [Display(Name = "指数（反転なし）")] Exponential = 1,
}

public enum ChromaticFalloffMode
{
    [Display(Name = "冪乗（設定値）")]
    Power = 0,

    [Display(Name = "三乗")]
    Cubic = 1,

    [Display(Name = "四乗")]
    Quartic = 2,

    [Display(Name = "六乗")]
    Sextic = 3,

    [Display(Name = "指数")]
    Exponential = 4,
}

[VideoEffect("Sa_chromablur", ["フィルタ"], ["Sa_chromablur", "色収差", "chromatic aberration", "プリズム", "RGBずれ", "レンズ"], IsAviUtlSupported = false)]
public sealed class ChromaticAberrationEffect : VideoEffectBase
{
    public override string Label => "Sa_chromablur";

    [Display(Name = "収差", Description = "中心から外側へ色をずらす量", Order = 0)]
    [AnimationSlider("F1", "px", 0, 2000)]
    public Animation Aberration { get; } = new(40, 0, YMM4Constants.VeryLargeValue);

    [Display(Name = "減衰", Description = "中心から離れるほど収差が強くなる度合い。冪乗形式では指数として使います", Order = 1)]
    [AnimationSlider("F2", "", 0, 32)]
    public Animation Falloff { get; } = new(2, 0, 32);

    [Display(Name = "半径", Description = "中心から減衰が広がる範囲。100%が従来の画面基準、値を下げると中心付近で強くなります", Order = 2)]
    [AnimationSlider("F1", "%", 1, 1000)]
    public Animation Radius { get; } = new(100, 1, 10000);

    [Display(Name = "減衰形式", Description = "逆二乗より急な三乗・四乗・六乗や指数形式を選べます", Order = 3)]
    [EnumComboBox]
    public ChromaticFalloffMode FalloffMode { get => falloffMode; set => Set(ref falloffMode, value); }
    ChromaticFalloffMode falloffMode = ChromaticFalloffMode.Power;

    [Display(Name = "ラジアル", Description = "中心まわりにねじりながら色をずらす角度", Order = 4)]
    [AnimationSlider("F1", "°", -720, 720)]
    public Animation Radial { get; } = new(8, -YMM4Constants.VeryLargeValue, YMM4Constants.VeryLargeValue);

    [Display(Name = "スケール", Description = "色ごとに拡大率を変えてずらす量", Order = 5)]
    [AnimationSlider("F1", "%", -300, 300)]
    public Animation Scale { get; } = new(0, -1000, 1000);

    [Display(Name = "中心X", Description = "ずれの中心の横位置。0pxで画像の中央", Order = 6)]
    [AnimationSlider("F1", "px", -4000, 4000)]
    public Animation CenterX { get; } = new(0, -YMM4Constants.VeryLargeValue, YMM4Constants.VeryLargeValue);

    [Display(Name = "中心Y", Description = "ずれの中心の縦位置。0pxで画像の中央", Order = 7)]
    [AnimationSlider("F1", "px", -4000, 4000)]
    public Animation CenterY { get; } = new(0, -YMM4Constants.VeryLargeValue, YMM4Constants.VeryLargeValue);

    [Display(Name = "ステップ数", Description = "分光サンプル数の上限。大きいほど連続的で滑らかですが重くなります", Order = 8)]
    [Range(2, 2048)]
    [DefaultValue(32)]
    [TextBoxSlider("F0", "", 2, 2048)]
    public int Steps { get => steps; set => Set(ref steps, Math.Clamp(value, 2, 2048)); }
    int steps = 32;

    [Display(Name = "強さ", Description = "元の映像との合成量", Order = 9)]
    [AnimationSlider("F1", "%", 0, 100)]
    public Animation Mix { get; } = new(100, 0, 100);

    [Display(Name = "スケール方式", Description = "絶対値は負の倍率を折り返し、指数は倍率が常に正になります。どちらも中心を挟んだ反転を防ぎます", Order = 10)]
    [EnumComboBox]
    public ChromaticScaleMode ScaleMode { get => scaleMode; set => Set(ref scaleMode, value); }
    ChromaticScaleMode scaleMode = ChromaticScaleMode.Absolute;

    public override IEnumerable<string> CreateExoVideoFilters(int keyFrameIndex, ExoOutputDescription exoOutputDescription) => [];

    public override IVideoEffectProcessor CreateVideoEffect(IGraphicsDevicesAndContext devices) => new ChromaticAberrationProcessor(devices, this);

    protected override IEnumerable<IAnimatable> GetAnimatables() => [Aberration, Falloff, Radius, Radial, Scale, CenterX, CenterY, Mix];
}
