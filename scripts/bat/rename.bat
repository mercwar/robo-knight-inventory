@echo off
cd /d "%~dp0"
for %%f in ("new *.*") do (
    set "fname=%%f"
    setlocal enabledelayedexpansion
    set "newname=!fname:new ="!"
    ren "%%f" "!newname!"
    endlocal
)
pause
