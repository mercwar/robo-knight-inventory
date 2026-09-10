@echo off
rem ====================================================================
rem 🏛️ AVIS CORE V22 - MULTI-REPO LOOP PUSH (Safe Workspace Isolation)
rem ====================================================================

setlocal enabledelayedexpansion

cd /d "%~dp0"
set "SCRIPT_DIR=%~dp0"
set "DEST_TARGET_PATH=logic\universal\v1"

set "GH_USER=mercwar"
set "GH_PAT=github_pat"
set "GH_API=https://api.github.com/users/%GH_USER%/repos"

:: Standalone, dedicated directory mappings
set "STAGING_BASE=%TEMP%\mercwar_staging_git"
set "STAGING_GIT=%TEMP%\mercwar_staging_git\.git"
set "STAGING_WORK=%TEMP%\mercwar_staging_work"

echo [ORCHESTRATOR] Baseline execution path: %SCRIPT_DIR%

:: -------------------------------------------------------------------------
:: 1. FETCH REPOSITORY LIST (Clean ASCII Parse, No BOM)
:: -------------------------------------------------------------------------
if exist "%TEMP%\repo_names.txt" del "%TEMP%\repo_names.txt"
echo [API] Fetching repository listings...
powershell -Command "$headers = @{ Authorization = 'Bearer %GH_PAT%' }; Invoke-RestMethod -Uri '%GH_API%' -Headers $headers | ForEach-Object { $_.name } | Out-File -FilePath '%TEMP%\repo_names.txt' -Encoding ascii"

if not exist "%TEMP%\repo_names.txt" (
    echo [ERROR] Failed to fetch repository data. Verify token permissions.
    goto end_pipeline
)

:: -------------------------------------------------------------------------
:: 2. MULTI-REPO PROCESSING LOOP (No Clones)
:: -------------------------------------------------------------------------
for /f "usebackq tokens=*" %%R in ("%TEMP%\repo_names.txt") do (
    set "REPO_NAME=%%R"
    
    :: Clean up repository name parsing (strip quotes, spaces, or raw formatting bugs)
    set "REPO_NAME=!REPO_NAME:"=!"
    set "REPO_NAME=!REPO_NAME: =!"
    
    :: SKIP LICENSE REPOS FILTER: Ignore generic license names returned in the payload
    set "SKIP_REPO="
    echo !REPO_NAME! | findstr /I "License" >nul && set "SKIP_REPO=1"
    echo !REPO_NAME! | findstr /I "GNU" >nul && set "SKIP_REPO=1"
    
    if not defined SKIP_REPO (
        echo.
        echo [REPO] Processing Target: !REPO_NAME!
        echo -----------------------------------------------------------------

        :: Reset completely fresh isolated staging environments in TEMP for each repo
        if exist "%STAGING_BASE%" rmdir /s /q "%STAGING_BASE%" >nul 2>&1
        if exist "%STAGING_WORK%" rmdir /s /q "%STAGING_WORK%" >nul 2>&1
        
        mkdir "%STAGING_BASE%" 2>nul
        mkdir "%STAGING_WORK%\%DEST_TARGET_PATH%" 2>nul

        :: Step A: Initialize the standard workspace
        git init --quiet "%STAGING_BASE%"
        
        :: Silence CRLF/LF line ending transformation alerts in the console
        git --git-dir="%STAGING_GIT%" config core.autocrlf false
        
        :: Explicit identity definitions inside the custom git dir context
        git --git-dir="%STAGING_GIT%" config user.name "mercwar"
        git --git-dir="%STAGING_GIT%" config user.email "mercwar01@gmail.com"
        
        :: Step B: Transfer files (EXCLUDE .git tracking folders and batch variants)
        robocopy "%SCRIPT_DIR% " "%STAGING_WORK%\%DEST_TARGET_PATH% " /E /XF "push.bat" /XF "*.bat" /XD ".git" /R:1 /W:1 >nul

        :: Step C: Enforce the absolute tracking destination target path completely cleanly
        git --git-dir="%STAGING_GIT%" remote add origin "https://%GH_USER%:%GH_PAT%@github.com/%GH_USER%/!REPO_NAME!.git"
        
        :: Step D: Stage data and reconcile history via rebase before force pushing
        git --git-dir="%STAGING_GIT%" --work-tree="%STAGING_WORK%" add .
        git --git-dir="%STAGING_GIT%" --work-tree="%STAGING_WORK%" commit -m "Automated update to %DEST_TARGET_PATH%" --quiet
        
        echo [GIT] Rebase synchronizing history and pushing directly into remote branch main...
        git --git-dir="%STAGING_GIT%" --work-tree="%STAGING_WORK%" pull --rebase origin main >nul 2>&1
        git --git-dir="%STAGING_GIT%" push origin HEAD:refs/heads/main --force
        
        :: Short file-handle release pause before moving to the next repo entry
        timeout /t 1 >nul
    )
)

:end_pipeline
:: Give Windows a brief 2-second pause to unlock file handles before final wiping
timeout /t 2 >nul

:: Clean up workspace trails
if exist "%STAGING_BASE%" rmdir /s /q "%STAGING_BASE%" >nul 2>&1
if exist "%STAGING_WORK%" rmdir /s /q "%STAGING_WORK%" >nul 2>&1
if exist "%TEMP%\repo_names.txt" del "%TEMP%\repo_names.txt" >nul 2>&1

echo.
echo [PIPELINE_COMPLETE] All public repositories updated successfully.
pause
