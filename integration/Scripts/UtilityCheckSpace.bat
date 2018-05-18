rem @ECHO OFF
@ECHO Test for free 80Gb to prepare and build UnrealEngine

setlocal enableextensions disabledelayedexpansion

CALL :checkFreeSpace %CD% 80000000000
IF ERRORLEVEL 1 (
    @ECHO Error: no enough space!
    EXIT /B 1
) ELSE (
    @ECHO Enough space found.
)

EXIT /B 0

:checkFreeSpace drive spaceRequired
    setlocal enableextensions disabledelayedexpansion
    set "pad=0000000000000000000000000"
    set "required=%pad%%~2"
    for %%d in ("%~1\.") do for /f "tokens=3" %%a in ('
        dir /a /-c "%%~fd" 2^>nul ^| findstr /b /l /c:"  " 
    ') do set "freeSpace=%pad%%%a"
    if "%freeSpace:~-25%" geq "%required:~-25%" exit /b 0
    exit /b 1