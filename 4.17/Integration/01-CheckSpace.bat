@echo off
    setlocal enableextensions disabledelayedexpansion

    call :checkFreeSpace d: 80000000000 && echo OK || echo No space

    if errorlevel 1 (
        echo No space
    ) else (
        echo OK
    )

    goto :eof

:checkFreeSpace drive spaceRequired
    setlocal enableextensions disabledelayedexpansion
    set "pad=0000000000000000000000000"
    set "required=%pad%%~2"
    for %%d in ("%~1\.") do for /f "tokens=3" %%a in ('
        dir /a /-c "%%~fd" 2^>nul ^| findstr /b /l /c:"  " 
    ') do set "freeSpace=%pad%%%a"
    if "%freeSpace:~-25%" geq "%required:~-25%" exit /b 0
    exit /b 1