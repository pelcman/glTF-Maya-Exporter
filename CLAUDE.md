# CLAUDE.md — glTF-Maya-Exporter 保守・改修ガイド

Maya 用 glTF 2.0 / VRM エクスポータ(KASHIKA, Inc. 製、MIT License)のフォーク。
オリジナルは Maya 2017/2018 対応のままメンテナンスが停止しており、本フォーク
(pelcman/glTF-Maya-Exporter)で **Maya 2024 まで(最終的には 2027 まで)** の
サポートを目指す。

## 改修の基本方針

1. **元の構造を壊さない。** レイヤ構成・ファイル配置・命名はそのまま維持し、
   最小限の差分で新しい Maya / ツールチェーンに追従する。
2. **バージョン分岐は `MAYA_API_VERSION` の `#if` ガードで行う。**
   (例: `#if MAYA_API_VERSION >= 20180000`)。旧バージョン(2017〜)の
   ソース互換を保ったままビルドできる状態を維持する。
3. **ビルドシステム(CMake)側でバージョン差を吸収する。** ソースへの変更より
   CMakeLists.txt の変更を優先する。
4. **コミットは小さく、目的単位で。** ビルド修正・機能修正・ドキュメントは
   別コミットにする。

## アーキテクチャ

```
src/
├─ glTFExporter/            … Maya プラグイン層(Maya API に依存するのはここだけ)
│  ├─ glTFExporterRegister.cpp  glTF/GLB 用プラグイン登録 (initializePlugin)
│  ├─ vrmExporterRegister.cpp   VRM 用プラグイン登録(同一ソースを ENABLE_VRM で分岐)
│  ├─ glTFTranslator.cpp/.h     MPxFileTranslator 実装(薄いラッパ)
│  ├─ glTFExporter.cpp/.h       本体。Maya シーンを走査して kml のシーングラフへ変換
│  │                            (メッシュ/マテリアル/スキン/ブレンドシェイプ/アニメ)
│  └─ ProgressWindow, murmur3   補助
├─ KashikaNativeLib/        … git submodule(kashikacojp/KashikaNativeLib)
│  ├─ src/kml/               Maya 非依存のコア。シーングラフ(Node/Mesh/Material/
│  │                         Transform)、glTF2 シリアライズ、GLB 変換、Draco 圧縮、
│  │                         メッシュユーティリティ(三角化・マテリアル分割・法線計算)
│  ├─ src/kil/               画像ライブラリ。テクスチャのコピー/フォーマット変換/
│  │                         リサイズ(Windows: GDI+、その他: stb)
│  └─ externals/             draco 1.3.3 / glm / picojson(いずれも submodule)
├─ cppexporter/             … Maya 非依存の C++ インターフェース(既定 OFF)
releases/scripts/           … エクスポートオプション UI(MEL)。registerFileTranslator の
                               optionScript として読み込まれる
docs/                       … 配布用 README(ja/en)
```

設計思想: **Maya 依存層(glTFExporter)と glTF 出力層(kml/kil)の分離**。
Maya のバージョンアップ対応は原則 `src/glTFExporter/` と CMakeLists.txt のみで
完結させ、kml/kil には手を入れない。プラグインは同一ソースから glTFExporter.mll
(glTF/GLB)と vrmExporter.mll(VRM、`ENABLE_VRM=1`)の 2 つを生成する。

## ビルド方法(Windows)

```powershell
# 初回のみ
git submodule update --init --recursive

# CMake は VS2022 同梱のものを使用(PATH に無い場合)
$cmake = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"

# Maya バージョンごとにビルドディレクトリを分ける
& $cmake -G "Visual Studio 17 2022" -A x64 -B build2024 -S . `
    -DGLTF_MAYA_EXPORTER_MAYA_PATH="C:/Program Files/Autodesk/Maya2024"
& $cmake --build build2024 --config Release
```

成果物: `build{ver}/Release/glTFExporter.mll`, `vrmExporter.mll`
インストール: `.mll` を `plug-ins/`、`releases/scripts/*.mel` を `scripts/` へ配置。
配布用バイナリは `releases/Maya{ver}/` に格納(リリース時に全バージョン分を
再ビルドして更新すること)
(`MAYA_MODULE_PATH` 併用可)。

### 動作確認(mayapy)

Maya を GUI 起動せずに検証できる:

```powershell
& "C:\Program Files\Autodesk\Maya2024\bin\mayapy.exe" -c @"
import maya.standalone; maya.standalone.initialize()
import maya.cmds as cmds
cmds.loadPlugin(r'<build>/Release/glTFExporter.mll')
cmds.polyCube(); cmds.file(rename=r'<tmp>/test.ma')
cmds.file(r'<tmp>/out.glb', force=True, options='', type='GLB Export', pr=True, ea=True)
"@
```

## Maya バージョン対応の要点

| Maya | Windows ツールチェーン | 備考 |
|------|----------------------|------|
| 2017 | VS2012 (v110) | ソース互換のみ維持。v143 バイナリは ABI 非互換のため実バイナリは旧 VS が必要 |
| 2018–2019 | VS2015 (v140) | v140〜v143 は ABI 互換。v143 ビルドでも概ね動作 |
| 2020 | VS2017 (v141) | 同上 |
| 2022 | VS2019 (v142) | 本マシンで実ビルド検証済み対象 |
| 2023 | VS2019 (v142) | 同上 |
| 2024 | VS2022 (v143) | 同上。公式要件が VS2022 |
| 2025–2027 | VS2022 (v143) | 本マシンで実ビルド検証済み対象 |

- Maya SDK ヘッダ/ライブラリはこのマシンでは各 Maya インストール直下の
  `include/` `lib/` に存在する(2022〜2027 を確認済み)。2017〜2021 の SDK は
  ローカルに無いため、**旧バージョンはソース互換の維持のみ**(`MAYA_API_VERSION`
  ガードを壊さない)とし、実ビルド検証は 2022/2023/2024 で行う。
- プラグイン API は `MPxFileTranslator` ベースの古く安定した API のみを使用して
  おり、Maya 側の破壊的変更の影響は小さい。主な作業はツールチェーン追従
  (CMake、C++ 標準、externals の新 MSVC 対応)。

## 既知の制約・注意点

- **KashikaNativeLib submodule はフォーク pelcman/KashikaNativeLib を参照**
  (2026-08-21 に doubleSided 対応のため切り替え。上流 kashikacojp には push
  権限が無い)。submodule の変更は必ずフォークへ push してから本体の参照を
  更新すること。push されていない submodule コミットの参照は他環境で
  clone できなくなるので禁止。
- draco は 1.3.3(2018 年)固定。新しい MSVC での警告/エラーが出た場合も
  draco 本体の更新は最終手段(glTF 側の API が変わるため)。
- `cppexporter`(`GLTF_MAYA_EXPORTER_BUILD_CPP_INTERFACE`)は既定 OFF。壊さない
  程度に維持すればよい。
- 文字コード: ソースは UTF-8、MSVC の警告 4819 は既存方針どおり抑制。

## 作業ロードマップ

### フェーズ 1: Maya 2017〜2024 対応(完了 2026-08-21)
- [x] リポジトリ調査、CLAUDE.md / AGENTS.md 整備
- [x] CMake 近代化(cmake_minimum_required 3.15、VS2022 ジェネレータ対応、
      `GLTF_MAYA_EXPORTER_MAYA_VERSION` によるパスのバージョン変数化)
- [x] Maya 2022/2023/2024 でのビルド確認 — **ソース修正は不要だった**
      (C++11 のままエラーなし。C4996 非推奨警告のみ、フェーズ 2 で棚卸し)
- [x] mayapy による 2022/2023/2024 のロード+エクスポート動作確認(全パス)
- [x] README / docs のサポートバージョン更新

### フェーズ 2: Maya 2025〜2027 対応(完了 2026-08-21)
- [x] 2025/2026/2027 でのビルド確認 — **ソース修正は不要だった**(エラーなし)
- [x] mayapy による 2025/2026/2027 のロード+エクスポート動作確認(全パス)
- [x] 非推奨 API の棚卸し — 2027 SDK でも既存の非推奨 API
      (findPlug 1 引数版、MFileObject::name/fullName、MItGeometry::component)
      は削除されておらずビルド可。将来削除された場合は `MAYA_API_VERSION`
      ガードで新 API に切り替えること
- [x] C++17 への引き上げは不要だった(MSVC は実質 C++14 でコンパイル)

### 修正済みの既知問題
- [x] (2026-08-21) **360° 以上の回転キーアニメーションが再現されない問題**
      (Maya はオイラー角補間、glTF はクォータニオン補間のため)。
      全フレームベイクではなく、キー区間のオイラー角変化量が 45° を超える
      場合のみ中点分割で適応的にサンプルを追加し、併せて連続キー間の
      クォータニオン符号を揃える半球補正を実装(glTFExporter.cpp の
      回転アニメーション出力部)。小さい回転ではキー数は増えない。

- [x] (2026-08-21) **オブジェクトごとの Double Sided 設定が glTF に出力されない問題**。
      Maya はメッシュシェイプ単位、glTF はマテリアル単位のため、「そのマテリアルを
      使うメッシュのどれかが Double Sided なら material.doubleSided = true」(OR)で
      マッピング。JSON 出力側は KashikaNativeLib(フォーク)の変更。
- [x] (2026-08-21) **aiStandardSurface の roughness がパラメータの組み合わせで
      正しく出力されない問題**。従来は specularRoughness を無条件出力していたが、
      スペキュラローブの存在量 `clamp(max(metalness, specularWeight))` で
      `mix(1.0, specularRoughness, lobe)` にブレンドする式に変更。
      Metalness=0 かつ SpecularWeight=0 → 1.0(ハイライト消滅)、Metalness=1 →
      specularRoughness 有効、既定値(SpecularWeight=1)は従来と同一出力。
      Diffuse Roughness は glTF のディフューズが Lambert 固定のため表現不可
      (LTE 拡張には生値が入っている)。

### 今後の課題(必要になったら)
- [ ] 非推奨 API の置き換え(上記 4 種、`MAYA_API_VERSION >= 20190000` ガード付きで)
- [ ] macOS / Linux でのビルド検証
- [x] StingrayPBS マテリアル対応(2026-08-21 実装)。base_color/metallic/
      roughness/emissive のスカラーと、カラー・ノーマル・エミッシブの各マップに
      対応。metallic/roughness マップは glTF 側が 1 枚への合成を要求するため
      未対応(スカラー値を出力)。検出は従来の `graph=="stingray"` 比較が現行
      Maya では機能しないため、ノードタイプ名 `StingrayPBS` で行う。
      mayapy でのテスト時は `cmds.shaderfx(sfxnode=..., initShaderAttributes=True)`
      で動的属性の初期化が必要(GUI では自動)。

## Git 運用

- ベースブランチ: `development`(このフォークの既定ブランチ)
- 作業ブランチ: `feature/maya2017-2024-support` など目的別に作成
- コミット単位: 「1 コミット = 1 論理変更」。ビルドが通る状態でコミットする
- push 先: `origin` = https://github.com/pelcman/glTF-Maya-Exporter.git
