# glTF-Maya-Exporter

Maya 用 glTF 2.0 / VRM エクスポータ(v1.6.0 / Maya 2017–2027 対応)

## インストール方法

1. `releases/Maya{バージョン}/` の `glTFExporter.mll`(VRM 用は `vrmExporter.mll`)を
   `C:\Users\[ユーザー名]\Documents\maya\[バージョン]\plug-ins` へコピー(無ければ作成)
2. `releases/scripts/` の `*.mel` を
   `C:\Users\[ユーザー名]\Documents\maya\[バージョン]\scripts` へコピー
3. Maya を起動し、ウインドウ → 設定/プリファレンス → プラグインマネージャ でロード
4. 「ファイル → すべて書き出し」でファイルの種類に GLTF/GLB/VRM Export を選択

## 仕様

- 出力形式: glTF 2.0(`.gltf` + `.bin` / `.glb`)、VRM
- メッシュ、トランスフォーム/スケルトン、スキンウェイト、ブレンドシェイプ、
  キーフレームアニメーション(回転は 360° 超も適応リサンプリングで正しく出力)
- マテリアル: Lambert / Phong / PhongE、aiStandardSurface、aiStandardHair、
  StingrayPBS、SurfaceShader(Unlit)
- オブジェクトの Double Sided 設定をマテリアルの `doubleSided` に反映
- Draco 圧縮、テクスチャ形式変換(JPEG / PNG)

## 制限

- Diffuse Roughness は glTF 仕様(Lambert 拡散)のため出力不可
- StingrayPBS の metallic / roughness / AO マップは未対応(スカラー値を出力)
- metalness 等がテクスチャ駆動の場合もスカラー値を出力
- 動作検証は Windows のみ(macOS / Linux はコード維持のみ)
- Maya 2017–2021 はソース互換のみ(バイナリは対応する旧 Visual Studio でのビルドが必要)

## ビルド方法

```
git submodule update --init --recursive
vc2022setup.bat 2024        (対象 Maya バージョンを指定)
cmake --build build2024 --config Release
```

## 提供条件(現状有姿)

本ソフトウェアは**現状有姿(AS IS)**で提供されます。明示・黙示を問わず
いかなる保証も行わず、利用により生じた損害について作者および配布者は
一切の責任を負いません。ライセンス: MIT License
