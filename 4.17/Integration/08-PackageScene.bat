@ECHO OFF
SETLOCAL

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
SET Solution=UE4.sln
SET Configuration="Development Editor"
SET Platform="Win64"

pushd %~dp0
CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

@ECHO Build scene...
"%CD%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="..\TestsProjects\FPSProject\FPSProject.uproject" -noP4 -platform=Win64 -clientconfig=Development -serverconfig=Development -cook -allmaps -NoCompile -stage -pak -archive -archivedirectory="Output Directory"
IF ERRORLEVEL 1 GOTO :error

@ECHO Prepare scene pack...
"%CD%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="..\TestsProjects\FPSProject\FPSProject.uproject" -noP4 -platform=Win64 -clientconfig=Development -serverconfig=Development -cook -allmaps -NoCompile -stage -pak -archive -archivedirectory="Output Directory"
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Scene deploy cussefull
    EXIT /B 0

:error
    @ECHO Error: failed deploy scene
    EXIT /B 1