@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
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

set PROMPT_ARGUMENT=--force

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

:setupBat
@ECHO Sync the dependencies...
.\Engine\Binaries\DotNET\GitDependencies.exe %PROMPT_ARGUMENT% >> %UnrealBuildLogFile% 2>>&1 %UnrealBuildLogFile%
if ERRORLEVEL 1 goto :error

@ECHO Setup the git hooks disabled, todo: implement it
rem if not exist .git\hooks goto no_git_hooks_directory
rem @ECHO Registering git hooks...
rem @ECHO #!/bin/sh >.git\hooks\post-checkout
rem @ECHO Engine/Binaries/DotNET/GitDependencies.exe %* >>.git\hooks\post-checkout
rem @ECHO #!/bin/sh >.git\hooks\post-merge
rem @ECHO Engine/Binaries/DotNET/GitDependencies.exe %* >>.git\hooks\post-merge
rem :no_git_hooks_directory

@ECHO Installing prerequisites...
start /wait Engine\Extras\Redist\en-us\UE4PrereqSetup_x64.exe /quiet

:done
    @ECHO UnrealEngine setup completed
    EXIT /B 0

:error
    @ECHO Error: failed to setup UnrealEngine
    EXIT /B 1