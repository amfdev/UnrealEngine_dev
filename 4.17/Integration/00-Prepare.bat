ECHO OFF

FSUTIL DIRTY QUERY %systemdrive% >nul
if %errorlevel% == 0 (
    echo Running with administrator rights.
) else (
    ECHO Error: administrator rights are required.
    EXIT /B 1
)

rem RD /S /Q .\UnrealEngine-4.17
rem RD /S /Q .\AmfMedia-4.17