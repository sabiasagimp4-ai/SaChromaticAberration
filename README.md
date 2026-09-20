# 色収差 (SaChromaticAberration)

YMM4用の映像エフェクトです。画面の中心から外側へ、赤・緑・青の位置を少しずつずらします。ラジアルやスケールを加えると、ねじれやプリズムのような見た目も作れます。

## パラメーター

| 名前 | 内容 |
| --- | --- |
| 収差 | 色をずらす量。大きいほど色が離れます。 |
| 減衰 | 外側に向かって効果を強くする度合い。 |
| 半径 | 効果が広がる範囲。小さくすると中心付近に集まります。 |
| 減衰形式 | 効果の変化のしかた。 |
| ラジアル | 色ずれに回転を加えます。 |
| スケール | 色ごとに拡大率を変えます。 |
| 中心X / 中心Y | 効果の中心を動かします。0で画面中央です。 |
| ステップ数 | 滑らかさ。大きいほど滑らかですが重くなります。 |
| 強さ | 元の映像との混ぜ具合です。 |
| スケール方式 | 「絶対値（反転なし）」を基本にしています。 |

初期値は、収差40px・減衰2・半径100%・ラジアル8°・ステップ数32です。まずは収差とラジアルを少しずつ動かすと変化を確認しやすくなります。

## 写真サンプル

教室の写真を1920×1080に整え、設定を変えて比較しました。左上が元画像です。

![色収差サンプル](docs/samples/IMG_0235/gallery.jpg)

[個別画像と設定CSV](docs/samples/IMG_0235/)

## インストール

ビルドした `SaChromaticAberration.dll` を、YMM4の

`user\\plugin\\SaChromaticAberration\\`

にコピーしてYMM4を再起動してください。

## ビルド

.NET 10 SDK、Windows SDK、YMM4本体のDLLが必要です。

```powershell
$Ymm4DirPath = 'D:\\YukkuriMovieMaker_v4_Lite\\'
$FxcPath = 'C:\\Program Files (x86)\\Windows Kits\\10\\bin\\10.0.26100.0\\x64\\fxc.exe'
$D2DIncludePath = 'C:\\Program Files (x86)\\Windows Kits\\10\\Include\\10.0.26100.0\\um'

dotnet build .\\SaChromaticAberration.csproj -c Release \\
  "-p:YMM4DirPath=$Ymm4DirPath" \\
  "-p:FxcPath=$FxcPath" \\
  "-p:D2DIncludePath=$D2DIncludePath"
```

## ファイル

- `ChromaticAberrationEffect.cs` — YMM4側の設定画面
- `ChromaticAberrationProcessor.cs` — フレームごとの処理
- `Shaders/ChromaticAberration.hlsl` — 色ずれの計算

YMM4 Lite 4.55.1.1のDLLを参照したReleaseビルドで確認しています。YMM4上での動作確認は環境によって異なります。
