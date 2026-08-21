# glTF-Maya-Exporter

Maya 用 glTF 2.0 / VRM エクスポータ(v1.6.0 / Maya 2017–2027 対応)

## インストール方法

1. `releases/Maya{バージョン}/` の `glTFExporter.mll`(VRM 用は `vrmExporter.mll`)を
   `C:\Users\[ユーザー名]\Documents\maya\[バージョン]\plug-ins` へコピー(無ければ作成)
2. `releases/scripts/` の `*.mel` を
   `C:\Users\[ユーザー名]\Documents\maya\[バージョン]\scripts` へコピー
3. Maya を起動し、ウインドウ → 設定/プリファレンス → プラグインマネージャ でロード
4. ファイル → すべて書き出し で、ファイルの種類に GLTF/GLB/VRM Export を選択

## 対応機能

- 出力形式: glTF 2.0(`.gltf` + `.bin` / `.glb`)、VRM
- メッシュ
- トランスフォーム / スケルトン
- スキンウェイト
- ブレンドシェイプ
- キーフレームアニメーション(移動 / 回転 / スケール / ブレンドシェイプ)
- マテリアル: Lambert / Phong / PhongE、aiStandardSurface、aiStandardHair、
  StingrayPBS、SurfaceShader(Unlit)
- テクスチャ: ベースカラー / ノーマル / エミッシブ
- オブジェクトの Double Sided 設定(マテリアルの doubleSided として出力)
- Draco 圧縮
- テクスチャ形式変換(JPEG / PNG)

## 非対応

- metallic / roughness / AO のテクスチャ。テクスチャを接続していても、
  マテリアルの数値がモデル全体に一律で出力される
- Diffuse Roughness
- macOS / Linux での動作検証(コードは維持)
- Maya 2017–2021 用のビルド済みバイナリ(ソース互換のみ。ビルドには
  対応する旧 Visual Studio が必要)

## ビルド方法

```
git submodule update --init --recursive
vc2022setup.bat 2024        (対象 Maya バージョンを指定)
cmake --build build2024 --config Release
```

## 提供条件

本ソフトウェアは現状有姿で提供され、明示・黙示を問わずいかなる保証も
ありません。利用により生じた損害について作者および配布者は責任を負いません。
ライセンス: MIT License
