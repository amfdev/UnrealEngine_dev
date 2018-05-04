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

@ECHO Generate UnrealEngine project files
CALL GenerateProjectFiles.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Start building UnrealEngine

TIME /T > build_time_begin.txt
%msbuild% /target:%target% %maxcpucount% /property:Configuration=%configuration%;Platform=%platform% %parameters% %solution%
IF ERRORLEVEL 1 GOTO :error
TIME /T > build_time_end.txt

:done
    @ECHO UnrealEngine build completed
    EXIT /B 0

:error
    @ECHO Error: failed to build UnrealEngine
    EXIT /B 1