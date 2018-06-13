@ECHO %Verbose%
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

@ECHO Start building UnrealEngine
@ECHO:

@ECHO MsBuild: %MSBUILD_EXE%
@ECHO Target: %target%
@ECHO Affinity: %maxcpucount%
@ECHO Configuration: %UnrealConfiguration%
@ECHO Platform: %platform%
@ECHO Params: %parameters%
@ECHO Solution: %solution%
@ECHO Log file: %UnrealBuildLogFile%
@ECHO:

CALL %MSBUILD_EXE% /target:"%target%" "%maxcpucount%" /property:Configuration="%UnrealConfiguration%";Platform="%platform%" "%parameters%" "%solution%" >> "%UnrealBuildLogFile%" 2>>&1
IF ERRORLEVEL 1 GOTO :error

@ECHO Copy prerequirements
CD %CurrentDirectory%

ROBOCOPY %CD%\%UnrealHome%\Engine\Extras\Redist\en-us\ %CD%\Deploy\Prerequirements\%UE_VERSION% /E
IF ERRORLEVEL 1 (
    @ECHO Error: failed to copy dependencies!
    rem GOTO :error
)

:done
    @ECHO UnrealEngine build completed
    EXIT /B 0

:error
    @ECHO Error: failed to build UnrealEngine!
    EXIT /B 1