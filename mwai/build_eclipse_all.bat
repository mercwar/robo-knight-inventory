@echo off
setlocal EnableDelayedExpansion
title MSVC Win64 Project Toolchain Compiler Engine
cd /d "%~dp0"

echo ============================================================
echo         MSVC WIN64 PROJECT COMPILATION TOOLCHAIN
echo ============================================================
echo.

:: 1. Automated Detection Loop for MSVC vcvars64.bat Location via vswhere or fallback paths
set "VCVARS_PATH="
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
    for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
        if exist "%%i\VC\Auxiliary\Build\vcvars64.bat" (
            set "VCVARS_PATH=%%i\VC\Auxiliary\Build\vcvars64.bat"
        )
    )
)

if not defined VCVARS_PATH (
    if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
        set "VCVARS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    ) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" (
        set "VCVARS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" (
        set "VCVARS_PATH=C:\Program Files\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
    )
)

if not defined VCVARS_PATH (
    echo [CRITICAL ERROR] Could not find vcvars64.bat on this machine.
    echo Please install Visual Studio C++ Desktop Development components.
    echo.
    pause
    exit /b 1
)

echo [*] Initializing MSVC x64 build variables via:
echo     "!VCVARS_PATH!"
echo.
call "!VCVARS_PATH!" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Failed to properly initialize MSVC environment variables.
    pause
    exit /b %errorlevel%
)

echo ------------------------------------------------------------
echo Processing native C compilation blocks side-by-side...
echo ------------------------------------------------------------
echo.

:: 2. Compile unzipcab.c to unzipcab.dll
if exist "unzipcab.c" (
    echo [1/3] Compiling module: unzipcab.c --^> unzipcab.dll
    cl.exe /LD /O2 /W4 /D_AMD64_ /D_WIN64 /DUNICODE /D_UNICODE unzipcab.c /link /OUT:unzipcab.dll /SUBSYSTEM:WINDOWS /MACHINE:X64 shell32.lib
    if !errorlevel! neq 0 (
        echo [COMPILE FAILED] unzipcab.c encountered errors.
        goto :BUILD_ERROR
    )
) else (
    echo [SKIP] unzipcab.c source not found in this folder.
)
echo.

:: 3. Compile mwaireg.c to mwreg.dll
if exist "mwaireg.c" (
    echo [2/3] Compiling module: mwaireg.c --^> mwaireg.dll
    cl.exe /LD /O2 /W4 /D_AMD64_ /D_WIN64 /DUNICODE /D_UNICODE mwaireg.c /link /OUT:mwaireg.dll /SUBSYSTEM:WINDOWS /MACHINE:X64 shell32.lib cabinet.lib wintrust.lib crypt32.lib
    if !errorlevel! neq 0 (
        echo [COMPILE FAILED] mwaireg.c encountered errors.
        goto :BUILD_ERROR
    )
) else (
    echo [SKIP] mwaireg.c source not found in this folder.
)
echo.

:: 4. Compile mwai.c to mwai.exe
if exist "mwai.c" (
    echo [3/3] Compiling application: mwai.c --^> mwai.exe
    cl.exe /O2 /W4 /D_AMD64_ /D_WIN64 /DUNICODE /D_UNICODE mwai.c /link /SUBSYSTEM:CONSOLE /MACHINE:X64
    if !errorlevel! neq 0 (
        echo [COMPILE FAILED] mwai.c encountered errors.
        goto :BUILD_ERROR
    )
) else (
    echo [SKIP] mwai.c source not found in this folder.
)
echo.

:: 5. Clean up loose intermediate files
echo [*] Cleaning intermediate cache files...
del /q *.obj *.exp >nul 2>nul

echo.
echo ============================================================
echo SUCCESS: All target components compiled successfully!
echo ============================================================
echo.
pause
exit /b 0

:BUILD_ERROR
echo.
echo [CRITICAL FAILURE] Compilation chain halted due to an error above.
pause
exit /b 1