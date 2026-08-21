# AGENTS.md — 作業エージェント向け実務ガイド

このファイルは、AI エージェント(Claude Code 等)がこのリポジトリで作業する際の
実務ルール。背景・設計・ロードマップは [CLAUDE.md](CLAUDE.md) を先に読むこと。

## 鉄則

1. **最小差分。** リファクタリング目的の変更はしない。フォーマッタを走らせない
   (`.clang-format` はあるが、触った行以外を再整形しない)。
2. **submodule(src/KashikaNativeLib 以下)に直接コミットしない。**
   どうしても必要な場合はフォークを作って `.gitmodules` を差し替え、その旨を
   CLAUDE.md に記録する。
3. **Maya バージョン分岐は `#if MAYA_API_VERSION >= 20XX0000`。**
   旧バージョン(2017)のコードパスを削除しない。
4. **ビルドが通らない状態でコミットしない。** 例外はドキュメントのみの変更。
5. **勝手に外部ライブラリを更新しない。** draco/glm/picojson の更新は影響が
   大きいため、必要になった時点で理由をコミットメッセージに明記して行う。

## ビルド・検証コマンド

```powershell
$cmake = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"

# 構成(Maya バージョンごとに build ディレクトリを分ける)
& $cmake -G "Visual Studio 17 2022" -A x64 -B build2024 -S . `
    -DGLTF_MAYA_EXPORTER_MAYA_PATH="C:/Program Files/Autodesk/Maya2024"

# ビルド
& $cmake --build build2024 --config Release

# スモークテスト(プラグインロード+ポリキューブを GLB エクスポート)
& "C:\Program Files\Autodesk\Maya2024\bin\mayapy.exe" スクリプト.py
```

- 検証対象 Maya: 2022 / 2023 / 2024(インストール先 `C:\Program Files\Autodesk\Maya{ver}`)。
  フェーズ 2 では 2025 / 2026 / 2027 も同様に。
- 2017〜2021 は SDK がローカルに無い。これらへの影響はコードレビュー
  (`MAYA_API_VERSION` ガードの維持)で担保する。
- ビルド成果物(`build*` ディレクトリ)はコミットしない(.gitignore 済みか確認)。

## Git 運用ルール

- ブランチ: `feature/<目的>` を `development` から生やす。
  現行作業ブランチ: `feature/maya2017-2024-support`
- コミットメッセージ: 英語 1 行サマリ(命令形)+ 必要なら本文。
  例: `Add Maya version-aware output directories to CMake`
- こまめにコミットする。「CMake 修正」「コンパイルエラー修正(ファイル単位/
  原因単位)」「ドキュメント更新」は必ず別コミット。
- push: `git push -u origin <branch>`。動作確認が済んだら `development` への
  マージ(または PR)を行う。force push はしない。

## 変更時のチェックリスト

- [ ] `MAYA_API_VERSION` ガードで旧バージョンのソース互換を壊していないか
- [ ] glTFExporter / vrmExporter 両ターゲットがビルドできるか(同一ソース共有のため)
- [ ] Win32 以外(APPLE/UNIX)の分岐を壊していないか(ビルド確認は不可、目視レビュー)
- [ ] mayapy スモークテストが 2022/2023/2024 で通るか
- [ ] README.md / docs / CLAUDE.md のバージョン表記の更新が必要か

## トラブルシューティングの記録

作業中に得た知見(ビルドエラーと解決方法など)は、このセクションに追記して
次のエージェント/人間に引き継ぐこと。

- (2026-08-21) CMake 3.28(VS2022 同梱)を使用。`cmake_minimum_required` が
  3.5 未満だと非推奨警告が出る。
- (2026-08-21) submodule 初期化には `git submodule update --init --recursive`
  が必須(draco/glm/picojson は KashikaNativeLib の入れ子 submodule)。
