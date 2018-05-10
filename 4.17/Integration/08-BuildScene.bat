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
SET Configuration="Shipping"
SET Platform="Win64"

pushd %~dp0
CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

TIME /T > build_time_begin.txt
"%CD%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="..\TestsProjects\PlainScreen\PlainScreen.uproject" -noP4 -platform=Win64 -clientconfig=Shipping -serverconfig=Shipping -cook -allmaps -build -stage -pak -archive -archivedirectory="Output Directory"
IF ERRORLEVEL 1 GOTO :error
TIME /T > build_time_end.txt

:done
    @ECHO UnrealEngine setup completed
    EXIT /B 0

:error
    @ECHO Error: failed to setup UnrealEngine
    EXIT /B 1