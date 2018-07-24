@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
)

IF NOT DEFINED VS_VERSION (
    @ECHO Error: VS_VERSION variable undefined!
    GOTO :error
)

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
    @ECHO Running with administrator rights.
) else (
    @ECHO Error: administrator rights required!
    GOTO :error
)

CALL Scripts\UtilitySetupMSBuildExe.bat
IF ERRORLEVEL 1 GOTO :error

SET Target=build
SET MaxCPUCount=/maxcpucount
SET Solution=UE4.sln
SET Platform=Win64
SET CurrentDirectory=%CD%

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

@ECHO:
@ECHO Build UnrealEngine
@ECHO UnrealEngine version: %UE_VERSION%
@ECHO VisualStudio version: %VS_VERSION%
@ECHO Configuration: %UnrealConfiguration%
@ECHO Platform: %platform%
@ECHO MsBuild: %MSBUILD_EXE%
@ECHO Target: %target%
@ECHO Affinity: %maxcpucount%
@ECHO Params: %parameters%
@ECHO Solution: %solution%
@ECHO Log file: %UnrealBuildLogFile%
@ECHO:

SET errorInUE=
CALL %MSBUILD_EXE% /target:"%target%" "%maxcpucount%" /property:Configuration="%UnrealConfiguration%";Platform="%platform%" "%parameters%" "%solution%" >> "%UnrealBuildLogFile%" 2>>&1
IF ERRORLEVEL 1 (

    SET errorInUE=1
    @ECHO Error: MSBUILD_EXE returns error when building UnrealEngine!
)

@ECHO Copy prerequirements
CD %CurrentDirectory%
ROBOCOPY %CD%\%UnrealHome%\Engine\Extras\Redist\en-us\ %CD%\Deploy\Prerequirements\%UE_VERSION% /E
IF ERRORLEVEL 1 (
    @ECHO Error: error returned from robocopy when coping dependencies! TODO: investigate why?
    rem GOTO :error
)

IF DEFINED errorInUE GOTO :error

:done
    @ECHO UnrealEngine build completed
    EXIT /B 0

:error
    @ECHO Error: failed to build UnrealEngine!
    EXIT /B 1