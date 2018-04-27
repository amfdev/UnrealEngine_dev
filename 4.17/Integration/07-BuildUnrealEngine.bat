rem @ECHO OFF

IF [%1]==[] GOTO usage ELSE GOTO :checkFolder
IF [%2]==[] GOTO usage ELSE GOTO :checkFolder
GOTO prepare

:usage
@ECHO "Error: ms build path and unreal root are not specified, usage: 07-BuildUnrealEngine.bat <MsBuild> <UnrealRoot>"
EXIT /B 1

:prepare

FSUTIL DIRTY QUERY %systemdrive% >nul
if %errorlevel% == 0 (
    ECHO Running with administrator rights.
) else (
    ECHO Error: administrator rights are required.
    EXIT /B 1
)

SETLOCAL
pushd %~dp0

SET MsBuild=%1
SET UnrealHome=%2
SET Target=build
SET MaxCPUCount=/maxcpucount
SET Solution=UE4.sln
SET Configuration="Development Editor"
SET Platform="Win64"
set PROMPT_ARGUMENT=--force

CD %UnrealHome%
goto build

:setupBat
ECHO Sync the dependencies...
.\Engine\Binaries\DotNET\GitDependencies.exe %PROMPT_ARGUMENT%*
if ERRORLEVEL 1 goto error

ECHO Setup the git hooks...
if not exist .git\hooks goto no_git_hooks_directory
echo Registering git hooks...
echo #!/bin/sh >.git\hooks\post-checkout
echo Engine/Binaries/DotNET/GitDependencies.exe %* >>.git\hooks\post-checkout
echo #!/bin/sh >.git\hooks\post-merge
echo Engine/Binaries/DotNET/GitDependencies.exe %* >>.git\hooks\post-merge
:no_git_hooks_directory

ECHO Installing prerequisites...
start /wait Engine\Extras\Redist\en-us\UE4PrereqSetup_x64.exe /quiet

ECHO Done!
goto :setupCompleted

:error
ECHO Error: could not install UE4 prerequirements!
EXIT /B 1

:setupCompleted
GenerateProjectFiles.bat

:build
ECHO Start building UnrealEngine
TIME /T > build_time_begin.txt

%msbuild% /target:%target% %maxcpucount% /property:Configuration=%configuration%;Platform=%platform% %parameters% %solution%

TIME /T > build_time_end.txt