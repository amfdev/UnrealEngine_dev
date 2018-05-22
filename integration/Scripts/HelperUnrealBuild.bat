rem @ECHO OFF
SETLOCAL

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

IF NOT DEFINED UnrealConfiguration (
    @ECHO Error: UnrealConfiguration variable undefined!
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

CALL Scripts\UtilitySetupMSBuildExe.bat
IF ERRORLEVEL 1 GOTO :error

SET Target=build
SET MaxCPUCount=/maxcpucount
SET Solution=UE4.sln
SET Platform=Win64

rem pushd %~dp0
CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

@ECHO Start building UnrealEngine
rem %MSBUILD_EXE% /target:%target% %maxcpucount% /property:Configuration="%UnrealConfiguration%";Platform=%platform% %parameters% %solution%
rem IF ERRORLEVEL 1 GOTO :error

@ECHO Copy prerequirements
ROBOCOPY %CD%\%UnrealHome%\Engine\Extras\Redist\en-us\ %CD%\Deploy\Prerequirements\%UE_VERSION% /E
IF ERRORLEVEL 1 (
    @ECHO Todo: investigate why robocopy returns error
    rem GOTO :error
)

:done
    @ECHO UnrealEngine build completed
    EXIT /B 0

:error
    @ECHO Error: failed to build UnrealEngine
    EXIT /B 1