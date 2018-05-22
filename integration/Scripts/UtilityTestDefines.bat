@ECHO OFF

SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 GOTO :noExt
@ECHO Command line extensions found
GOTO checkRights

:noExt
    @ECHO Unable to enable extensions
    EXIT /B 1

:checkRights
FSUTIL DIRTY QUERY %systemdrive% >nul
if %errorlevel% == 0 (
    @ECHO Running with administrator rights.
) else (
    @ECHO Error: administrator rights required!
    EXIT /B 1
)

:done
    @ECHO Neccessary defines tested successfully!
    EXIT /B 0

:error
    @ECHO Error: failed to test defines
    EXIT /B 1