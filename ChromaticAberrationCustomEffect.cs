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
    public float RadiusScale { set => SetValue((int)Impl.Properties.RadiusScale, value); }
    public int FalloffMode { set => SetValue((int)Impl.Properties.FalloffMode, value); }
    public int ScaleMode { set => SetValue((int)Impl.Properties.ScaleMode, value); }
    public int FalloffTarget { set => SetValue((int)Impl.Properties.FalloffTarget, value); }

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
        public int StepCount { get => constants.StepCount; set { constants.StepCount = Math.Clamp(value, 2, 2048); UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Float, (int)Properties.FalloffPower)]
        public float FalloffPower { get => constants.FalloffPower; set { constants.FalloffPower = Math.Clamp(value, 0f, 32f); UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Float, (int)Properties.RadiusScale)]
        public float RadiusScale { get => constants.RadiusScale; set { constants.RadiusScale = Math.Clamp(value, 0.01f, 100f); UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Int32, (int)Properties.FalloffMode)]
        public int FalloffMode { get => constants.FalloffMode; set { constants.FalloffMode = Math.Clamp(value, 0, 4); UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Int32, (int)Properties.ScaleMode)]
        public int ScaleMode { get => constants.ScaleMode; set { constants.ScaleMode = Math.Clamp(value, 0, 1); UpdateConstants(); } }

        [CustomEffectProperty(PropertyType.Int32, (int)Properties.FalloffTarget)]
        public int FalloffTarget { get => constants.FalloffTarget; set { constants.FalloffTarget = Math.Clamp(value, 0, 3); UpdateConstants(); } }

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
            // Rotation and edge clamping can read any part of the source, including
            // pixels far outside a requested output tile. Request the complete input.
            inputRects[0] = inputRect;
        }

        /// <summary>収差量に掛かる距離係数の最大値。正規化半径が最大になるのは中心から最も遠い角。</summary>
        internal static double FalloffMax(double width, double height, double power, double offsetX = 0, double offsetY = 0)
        {
            var nx = 1 + Math.Abs(offsetX) / Math.Max(width / 2, 1e-5);
            var ny = 1 + Math.Abs(offsetY) / Math.Max(height / 2, 1e-5);
            return Math.Pow(Math.Sqrt(nx * nx + ny * ny), power);
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
            public float RadiusScale;
            public int FalloffMode;
            public int ScaleMode;
            public int FalloffTarget;
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
            RadiusScale = 9,
            FalloffMode = 10,
            ScaleMode = 11,
            FalloffTarget = 12,
        }
    }
}
