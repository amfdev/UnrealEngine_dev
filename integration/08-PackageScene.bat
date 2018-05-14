@ECHO OFF
SETLOCAL

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
)

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

:checkRights
FSUTIL DIRTY QUERY %systemdrive% >nul
if %errorlevel% == 0 (
    echo Running with administrator rights.
) else (
    ECHO Error: administrator rights required!
    GOTO :error
)

SET Target=build
SET MaxCPUCount=/maxcpucount
SET Configuration="Development"
SET Platform="Win64"

pushd %~dp0
CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

@ECHO Prepare scene pack...
"%CD%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="..\TestsProjects\PlainScreen\PlainScreen.uproject" -noP4 -platform=%Platform% -clientconfig=%Configuration% -serverconfig=%Configuration% -cook -allmaps -NoCompile -stage -archive -archivedirectory="%UE_VERSION%_%Configuration%_%Platform%"
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Scene deploy cussefull
    EXIT /B 0

:error
    @ECHO Error: failed deploy scene
    EXIT /B 1