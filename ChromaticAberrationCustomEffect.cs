using System.Numerics;
using System.Runtime.InteropServices;
using Vortice;
using Vortice.Direct2D1;
using YukkuriMovieMaker.Commons;
using YukkuriMovieMaker.Player.Video;

namespace SaChromaticAberration;

internal sealed class ChromaticAberrationCustomEffect(IGraphicsDevicesAndContext devices)
    : D2D1CustomShaderEffectBase(Create<ChromaticAberrationCustomEffect.Impl>(devices))
{
    public Vector4 ImageRect { set => SetValue((int)Impl.Properties.ImageRect, value); }
    public float CenterOffsetX { set => SetValue((int)Impl.Properties.CenterOffsetX, value); }
    public float CenterOffsetY { set => SetValue((int)Impl.Properties.CenterOffsetY, value); }
    public float Aberration { set => SetValue((int)Impl.Properties.Aberration, value); }
    public float RadialAngle { set => SetValue((int)Impl.Properties.RadialAngle, value); }
    public float ScaleAmount { set => SetValue((int)Impl.Properties.ScaleAmount, value); }
    public float MixAmount { set => SetValue((int)Impl.Properties.MixAmount, value); }
    public int StepCount { set => SetValue((int)Impl.Properties.StepCount, value); }
    public float FalloffPower { set => SetValue((int)Impl.Properties.FalloffPower, value); }

    [CustomEffect(1)]
    internal sealed class Impl : D2D1CustomShaderEffectImplBase<Impl>
    {
        Constants constants;

        [CustomEffectProperty(PropertyType.Vector4, (int)Properties.ImageRect)]
        public Vector4 ImageRect { get => constants.ImageRect; set { constants.ImageRect = value; UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Float, (int)Properties.CenterOffsetX)]
        public float CenterOffsetX { get => constants.CenterOffsetX; set { constants.CenterOffsetX = value; UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Float, (int)Properties.CenterOffsetY)]
        public float CenterOffsetY { get => constants.CenterOffsetY; set { constants.CenterOffsetY = value; UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Float, (int)Properties.Aberration)]
        public float Aberration { get => constants.Aberration; set { constants.Aberration = value; UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Float, (int)Properties.RadialAngle)]
        public float RadialAngle { get => constants.RadialAngle; set { constants.RadialAngle = value; UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Float, (int)Properties.ScaleAmount)]
        public float ScaleAmount { get => constants.ScaleAmount; set { constants.ScaleAmount = value; UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Float, (int)Properties.MixAmount)]
        public float MixAmount { get => constants.MixAmount; set { constants.MixAmount = Math.Clamp(value, 0f, 1f); UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Int32, (int)Properties.StepCount)]
        public int StepCount { get => constants.StepCount; set { constants.StepCount = Math.Clamp(value, 2, 512); UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Float, (int)Properties.FalloffPower)]
        public float FalloffPower { get => constants.FalloffPower; set { constants.FalloffPower = Math.Clamp(value, 0f, 8f); UpdateConstants(); } }

        public Impl() : base(ShaderResourceLoader.Get("ChromaticAberration")) { }

        protected override void UpdateConstants() => drawInformation?.SetPixelShaderConstantBuffer(constants);

        public override void MapInputRectsToOutputRect(RawRect[] inputRects, RawRect[] inputOpaqueSubRects, out RawRect outputRect, out RawRect outputOpaqueSubRect)
        {
            inputRect = inputRects[0];
            // Edge extension is only used inside the original image footprint.
            outputRect = inputRects[0];
            outputOpaqueSubRect = default;
        }

        public override void MapOutputRectToInputRects(RawRect outputRect, RawRect[] inputRects)
        {
            // Channel separation and edge clamping can read any part of the source,
            // including pixels far outside a requested output tile. Request the complete input.
            inputRects[0] = inputRect;
        }

        [StructLayout(LayoutKind.Sequential)]
        struct Constants
        {
            public Vector4 ImageRect;
            public float CenterOffsetX;
            public float CenterOffsetY;
            public float Aberration;
            public float RadialAngle;
            public float ScaleAmount;
            public float MixAmount;
            public int StepCount;
            public float FalloffPower;
        }

        internal enum Properties
        {
            ImageRect = 0,
            CenterOffsetX = 1,
            CenterOffsetY = 2,
            Aberration = 3,
            RadialAngle = 4,
            ScaleAmount = 5,
            MixAmount = 6,
            StepCount = 7,
            FalloffPower = 8,
        }
    }
}
