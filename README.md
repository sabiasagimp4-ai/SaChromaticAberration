# 色収差 (SaChromaticAberration)

YMM4 用の映像エフェクトプラグインです。Crate's Chromatic Aberration と同じ考え方で、
波長ごとに参照位置をずらした複数サンプルを合成し、プリズム状の色収差を作ります。

## パラメーター

| 名前 | 内容 |
| --- | --- |
| 収差 | 中心から外側へ色をずらす量 (px)。画面端の中点での値で、中心では 0、四隅ではさらに大きくなります。効果の主役。 |
| 減衰 | 中心からの距離に対する収差の増え方 (指数)。2 で逆二乗式 = 中心が鮮明で周辺ほど大きく滲む、実レンズに近い見た目。0 にすると全面同じ量ずれます。 |
| ラジアル | 中心まわりにねじりながらずらす角度 (°)。渦巻き状の収差。 |
| スケール | 色ごとに拡大率を変えてずらす量 (%)。奥行きのあるズレ。 |
| 中心X / 中心Y | ずれの中心位置 (px)。0px で画像中央。YMM4 の拡大縮小より前の、素材のピクセル空間で数えます。 |
| ステップ数 | 分光サンプル数の上限 (2〜512)。少ないとレトロな階調、多いと滑らか。 |
| 強さ | 元の映像との合成量 (%)。 |

正規化半径は縦横それぞれの半分の長さで割って求めるので、収差の等高線は画像と同じ縦横比の楕円になります。
画面端の中点が 1.0、四隅が約 1.41 で、減衰 2 のときの四隅の収差量は設定値の約 2 倍です。

強い収差のレンズらしい見た目にするには、収差 60px / 減衰 2.0 / ラジアル 5〜15° あたりが目安です。
参考画像のような柔らかい弧を出すには、素材自体がボケている必要があります。
細部が残っている素材に同じ設定を当てると、虹色は同じでも細かい模様がそのまま残り、より賑やかな絵になります。

収差・ラジアル・スケールがすべて 0 のときは、出力が入力と完全に一致します
(分光の重みをチャンネルごとに正規化しているため)。

サンプル数はずれ量から必要数を計算して自動で間引きます。ステップ数は上限としてだけ働くので、
大きい値を入れても、ずれが小さいフレームでは描画コストは増えません
(ずれが 0 のフレームは 2 サンプルまで落ちます)。

## ビルド

.NET 10 SDK と Windows SDK (fxc.exe) が必要です。

```powershell
$Ymm4DirPath = 'D:\YukkuriMovieMaker_v4_Lite\'
$FxcPath = 'C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\fxc.exe'
$D2DIncludePath = 'C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\um'
dotnet build .\SaChromaticAberration.csproj -c Release "-p:YMM4DirPath=$Ymm4DirPath" "-p:FxcPath=$FxcPath" "-p:D2DIncludePath=$D2DIncludePath"
```

## インストール

`bin\Release\net10.0-windows10.0.19041.0\SaChromaticAberration.dll` を
YMM4 の `user\plugin\SaChromaticAberration\` にコピーして YMM4 を再起動します。

## 構成

- `Shaders/ChromaticAberration.hlsl` — 分光サンプリングのピクセルシェーダー (ps_4_0)
- `ChromaticAberrationCustomEffect.cs` — D2D カスタムエフェクトと定数バッファ、描画矩形の拡張
- `ChromaticAberrationProcessor.cs` — フレームごとのパラメーター更新
- `ChromaticAberrationEffect.cs` — YMM4 のエフェクト定義 (UI)

## 検証状況

インストール済み YMM4 Lite 4.55.1.1 の DLL を参照した Release ビルドは成功しています。
YMM4 上での読み込み・実描画は未検証です。
