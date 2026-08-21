@echo off
rem Usage: vc2022setup.bat [MayaVersion]   (default: 2024)
set MAYA_VERSION=%1
if "%MAYA_VERSION%"=="" set MAYA_VERSION=2024

cmake.exe -G "Visual Studio 17 2022" -A x64 -B build%MAYA_VERSION% -S . -DGLTF_MAYA_EXPORTER_MAYA_VERSION=%MAYA_VERSION%
