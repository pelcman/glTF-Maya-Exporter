# glTF-Maya-Exporter

## Maya glTF 2.0 Exporter

Documentation: [日本語 (README_ja.md)](docs/README_ja.md) / [English (README_en.md)](docs/README_en.md)

Prebuilt binaries for Maya 2022-2027 are in the [releases/](releases/)
folder of this repository (see "How to Install" below).

## Version
1.6.0

### Changes in 1.6.0 (this fork)

- Support Maya 2017 through 2027 (CMake + VS2022 based build)
- Fix rotation animations spanning 180+ degrees / multiple turns
  (adaptive resampling; no need to bake animations before export)
- Map Maya's per-object Double Sided flag to glTF `material.doubleSided`
- Derive `roughnessFactor` from the aiStandardSurface specular lobe
  (metalness / specular weight combinations now export correctly)
- Support StingrayPBS materials (previously an unimplemented stub)

## Introduction
This is the glTF 2.0 exporter for AUTODESK MAYA (
https://www.autodesk.co.jp/products/maya/). 

This repositry contains mel scripts and C++ source codes.


## Support Maya version

We support MAYA2017 through MAYA2027 on Windows (build-verified with
Maya 2022/2023/2024/2025/2026/2027 + Visual Studio 2022; Maya 2017-2021
keep source compatibility via `MAYA_API_VERSION` guards but require their
matching older toolchains for binary compatibility).

macOS and Linux code paths are kept intact but are not currently verified.


## Support features

- [x] Export mesh

- [x] Material Lambert, phong, phongE

- [x] Material Parameters: baseColor, Roughness

- [x] Bump mapping support (with Bump2d node)

- [x] Material aiStandardSurface (USE: GLTF_MAYA_EXPORTER_SUPPORT_LTE_PBR_MATERIAL is ON)

- [x] Material aiStandardHair (USE: GLTF_MAYA_EXPORTER_SUPPORT_LTE_PBR_MATERIAL is ON)

- [x] Material StingrayPBS (base color/normal/emissive maps; metallic and roughness as scalar values)

- [x] Transform/Skeleton

- [x] Mac support

- [x] Linux support

- [x] VRM format (https://dwango.github.io/vrm/)

- [x] Substance Painter Texture Node (NEED option => Automatic connections : true)

- [x] SkinMesh animation

- [x] Blend shape animation

## How to Install (prebuilt binaries)

The `releases/` folder contains ready-to-use binaries:

```
releases/
├─ scripts/        Export option UIs (copy for every Maya version)
├─ Maya2022/       glTFExporter.mll / vrmExporter.mll for Maya 2022
├─ ...
└─ Maya2027/       glTFExporter.mll / vrmExporter.mll for Maya 2027
```

- 1: Copy `releases/Maya{version}/*.mll` into
  `C:\Users\[account]\Documents\maya\[version]\plug-ins`
  (create the folder if it does not exist)

- 2: Copy `releases/scripts/*.mel` into
  `C:\Users\[account]\Documents\maya\[version]\scripts`
  (`ja_JP\scripts` / `en_US\scripts` also work)

- 3: Start Maya and enable the plug-ins in
  Windows > Settings/Preferences > Plug-in Manager

See [docs/README_ja.md](docs/README_ja.md) / [docs/README_en.md](docs/README_en.md) for details.

## How to Build

### Generate project file by CMake

- 1: Get submodules. `$git submodule update --init --recursive`

- 2: Configure for your Maya version (Windows example, VS2022):
  `$cmake -G "Visual Studio 17 2022" -A x64 -B build2024 -S . -DGLTF_MAYA_EXPORTER_MAYA_VERSION=2024`
  (or run `vc2022setup.bat [MayaVersion]`)

- 3: Build it: `$cmake --build build2024 --config Release`

- 4: Artifacts: `build2024/Release/glTFExporter.mll` and `vrmExporter.mll`

If Maya is installed in a non-standard location, set
`GLTF_MAYA_EXPORTER_MAYA_PATH` instead.

### Use Visual Studio (deprecated)

- 1: Requirements: Visual studio 2017.

- 2: Generate Draco solution: RUN externals/build_draco2017.bat

- 3: Build draco project: Open externals/draco/build/draco.sln and build it.

- 4: Install target maya version on your system. (ex. C:\Program Files\Autodesk\Maya2018 )

- 5: Open solution file: /windows/glTFExporter/glTFExporter.sln

- 6: Select target version from configuration and build it.


## Externals modules

- draco: https://github.com/google/draco/

- glm: https://github.com/g-truc/glm

- picojson: https://github.com/kazuho/picojson/


## License

This software is MIT License.
Copyright (c) 2018 Kashika, Inc.

aiStanradHair and aiStandardSurface shader parameter exporter by Light Transport Entertainment, Inc.
