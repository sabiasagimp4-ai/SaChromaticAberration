using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using YukkuriMovieMaker.Commons;
using YukkuriMovieMaker.Controls;
using YukkuriMovieMaker.Exo;
using YukkuriMovieMaker.Player.Video;
using YukkuriMovieMaker.Plugin.Effects;

namespace SaChromaticAberration;

[VideoEffect("色収差", ["フィルタ"], ["色収差", "chromatic aberration", "プリズム", "RGBずれ", "レンズ"], IsAviUtlSupported = false)]
public sealed class ChromaticAberrationEffect : VideoEffectBase
{
    public override string Label => "色収差";

    [Display(Name = "収差", Description = "中心から外側へ色をずらす量", Order = 0)]
    [AnimationSlider("F1", "px", 0, 300)]
    public Animation Aberration { get; } = new(40, 0, YMM4Constants.VeryLargeValue);

    [Display(Name = "減衰", Description = "中心から離れるほど収差が強くなる度合い。2 で距離の二乗に比例 (中心が鮮明、周辺が大きく滲む)。0 で全面均一", Order = 1)]
    [AnimationSlider("F2", "", 0, 4)]
    public Animation Falloff { get; } = new(2, 0, 8);

    [Display(Name = "ラジアル", Description = "中心から色をずらす方向。画像全体は回転しません", Order = 2)]
    [AnimationSlider("F1", "°", -180, 180)]
    public Animation Radial { get; } = new(8, -YMM4Constants.VeryLargeValue, YMM4Constants.VeryLargeValue);

    [Display(Name = "スケール", Description = "色ごとに拡大率を変えてずらす量", Order = 3)]
    [AnimationSlider("F1", "%", -50, 50)]
    public Animation Scale { get; } = new(0, -100, 100);

    [Display(Name = "中心X", Description = "ずれの中心の横位置。0pxで画像の中央", Order = 4)]
    [AnimationSlider("F1", "px", -1000, 1000)]
    public Animation CenterX { get; } = new(0, -YMM4Constants.VeryLargeValue, YMM4Constants.VeryLargeValue);

    [Display(Name = "中心Y", Description = "ずれの中心の縦位置。0pxで画像の中央", Order = 5)]
    [AnimationSlider("F1", "px", -1000, 1000)]
    public Animation CenterY { get; } = new(0, -YMM4Constants.VeryLargeValue, YMM4Constants.VeryLargeValue);

    [Display(Name = "ステップ数", Description = "色を分割するサンプル数の上限。少ないとレトロな階調、多いと滑らか。ずれ量に対して過剰な分は自動で間引く", Order = 6)]
    [Range(2, 512)]
    [DefaultValue(32)]
    [TextBoxSlider("F0", "", 2, 512)]
    public int Steps { get => steps; set => Set(ref steps, Math.Clamp(value, 2, 512)); }
    int steps = 32;

    [Display(Name = "強さ", Description = "元の映像との合成量", Order = 7)]
    [AnimationSlider("F1", "%", 0, 100)]
    public Animation Mix { get; } = new(100, 0, 100);

    public override IEnumerable<string> CreateExoVideoFilters(int keyFrameIndex, ExoOutputDescription exoOutputDescription) => [];

    public override IVideoEffectProcessor CreateVideoEffect(IGraphicsDevicesAndContext devices) => new ChromaticAberrationProcessor(devices, this);

    protected override IEnumerable<IAnimatable> GetAnimatables() => [Aberration, Falloff, Radial, Scale, CenterX, CenterY, Mix];
}
