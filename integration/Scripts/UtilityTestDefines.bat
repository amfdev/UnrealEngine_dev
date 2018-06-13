@ECHO %Verbose%

SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 GOTO :error
@ECHO Command line extensions enabled

SETLOCAL EnableDelayedExpansion
IF ERRORLEVEL 1 GOTO :error
@ECHO Delayed expansion enabled

FSUTIL DIRTY QUERY %systemdrive% >nul
if %errorlevel% == 0 (
    @ECHO Running with administrator rights.
) else (
    @ECHO Error: administrator rights required!
    EXIT /B 1
)

:done
    @ECHO:
    @ECHO Neccessary defines tested successfully
    EXIT /B 0

:error
    @ECHO Error: failed to test defines!
    EXIT /B 1