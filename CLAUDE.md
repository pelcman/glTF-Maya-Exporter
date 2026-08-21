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
scripts/                    … エクスポートオプション UI(MEL)。registerFileTranslator の
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
インストール: `.mll` を `plug-ins/`、`scripts/*.mel` を `scripts/` へ配置
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
| 2025–2027 | VS2022 (v143) | 第 2 フェーズで対応予定 |

- Maya SDK ヘッダ/ライブラリはこのマシンでは各 Maya インストール直下の
  `include/` `lib/` に存在する(2022〜2027 を確認済み)。2017〜2021 の SDK は
  ローカルに無いため、**旧バージョンはソース互換の維持のみ**(`MAYA_API_VERSION`
  ガードを壊さない)とし、実ビルド検証は 2022/2023/2024 で行う。
- プラグイン API は `MPxFileTranslator` ベースの古く安定した API のみを使用して
  おり、Maya 側の破壊的変更の影響は小さい。主な作業はツールチェーン追従
  (CMake、C++ 標準、externals の新 MSVC 対応)。

## 既知の制約・注意点

- **KashikaNativeLib は kashikacojp 所有の submodule。** push 権限が無いため、
  submodule 内の修正が必要になった場合はフォーク(例: pelcman/KashikaNativeLib)
  を作成して `.gitmodules` の URL を差し替えること。submodule 内のみのコミットは
  他環境で再現できないので禁止。
- draco は 1.3.3(2018 年)固定。新しい MSVC での警告/エラーが出た場合も
  draco 本体の更新は最終手段(glTF 側の API が変わるため)。
- `cppexporter`(`GLTF_MAYA_EXPORTER_BUILD_CPP_INTERFACE`)は既定 OFF。壊さない
  程度に維持すればよい。
- 文字コード: ソースは UTF-8、MSVC の警告 4819 は既存方針どおり抑制。

## 作業ロードマップ

### フェーズ 1: Maya 2017〜2024 対応(現在)
- [x] リポジトリ調査、CLAUDE.md / AGENTS.md 整備
- [ ] CMake 近代化(cmake_minimum_required 引き上げ、VS2022 ジェネレータ対応、
      Maya パスのバージョン変数化、C++ 標準の引き上げ)
- [ ] Maya 2022/2023/2024 でのビルド確認と、必要なコンパイルエラー修正
      (externals 含む。修正は最小限・ガード付きで)
- [ ] mayapy による 2022/2023/2024 のロード+エクスポート動作確認
- [ ] README / docs のサポートバージョン更新

### フェーズ 2: Maya 2025〜2027 対応(フェーズ 1 完了後)
- [ ] 2025/2026/2027 でのビルド確認(SDK はローカルにあり)
- [ ] 新 API 警告・非推奨 API の棚卸し(特に 2026/2027 での deprecation)
- [ ] 必要なら C++17 への引き上げと externals 更新の検討

## Git 運用

- ベースブランチ: `development`(このフォークの既定ブランチ)
- 作業ブランチ: `feature/maya2017-2024-support` など目的別に作成
- コミット単位: 「1 コミット = 1 論理変更」。ビルドが通る状態でコミットする
- push 先: `origin` = https://github.com/pelcman/glTF-Maya-Exporter.git
