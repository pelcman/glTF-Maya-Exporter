# glTF-Maya-Exporter

glTF 2.0 / VRM exporter for Maya (v1.6.0, Maya 2017–2027)

## Installation

1. Copy `glTFExporter.mll` (and `vrmExporter.mll` for VRM) from
   `releases/Maya{version}/` into
   `C:\Users\[account]\Documents\maya\[version]\plug-ins` (create if missing)
2. Copy `releases/scripts/*.mel` into
   `C:\Users\[account]\Documents\maya\[version]\scripts`
3. Start Maya and load the plug-ins in
   Windows > Settings/Preferences > Plug-in Manager
4. Use File > Export All with file type GLTF/GLB/VRM Export

## Supported

- Output: glTF 2.0 (`.gltf` + `.bin` / `.glb`), VRM
- Meshes
- Transforms / skeletons
- Skin weights
- Blend shapes
- Keyframe animation (translate / rotate / scale / blend shapes)
- Materials: Lambert / Phong / PhongE, aiStandardSurface, aiStandardHair,
  StingrayPBS, SurfaceShader (unlit)
- Textures: base color / normal / emissive
- Per-object Double Sided flag (exported as the material doubleSided flag)
- Draco compression
- Texture format conversion (JPEG / PNG)

## Not supported

- Metallic / roughness / AO textures. Even when a texture is connected,
  the material's numeric value is exported uniformly for the whole model
- Diffuse roughness
- macOS / Linux verification (code paths are kept)
- Prebuilt binaries for Maya 2017–2021 (source compatibility only;
  building requires the matching older Visual Studio)

## How to Build

```
git submodule update --init --recursive
vc2022setup.bat 2024        (pass the target Maya version)
cmake --build build2024 --config Release
```

## Terms

This software is provided as is, without warranty of any kind, express or
implied. The authors and distributors accept no liability for any damage
arising from its use. License: MIT License
