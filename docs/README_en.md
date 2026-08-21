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

## Specifications

- Output: glTF 2.0 (`.gltf` + `.bin` / `.glb`), VRM
- Meshes, transforms/skeletons, skin weights, blend shapes, and keyframe
  animations (rotations beyond 360° export correctly via adaptive resampling)
- Materials: Lambert / Phong / PhongE, aiStandardSurface, aiStandardHair,
  StingrayPBS, SurfaceShader (unlit)
- Per-object Double Sided flag mapped to the material `doubleSided` flag
- Draco compression, texture format conversion (JPEG / PNG)

## Limitations

- Diffuse roughness cannot be exported (glTF diffuse is Lambertian)
- **Metallic / roughness / AO textures are not exported.**
  Even when a texture is connected to these inputs (StingrayPBS maps,
  a texture on aiStandardSurface metalness, etc.), the exported glTF
  applies the material's single numeric value uniformly to the whole
  model - per-area variation such as "only this part is metallic or
  rough" is lost, so pick a representative value where needed.
  Base color / normal / emissive textures are exported.
  (glTF only accepts metallic and roughness packed together into one
  metallicRoughnessTexture; merging separate images is not implemented.)
- Verified on Windows only (macOS / Linux code paths are kept but untested)
- Maya 2017–2021: source compatibility only; binaries require the matching
  older Visual Studio toolchain

## How to Build

```
git submodule update --init --recursive
vc2022setup.bat 2024        (pass the target Maya version)
cmake --build build2024 --config Release
```

## Provided As Is

This software is provided **AS IS**, without warranty of any kind, express
or implied. The authors and distributors accept no liability for any damage
arising from its use. License: MIT License
