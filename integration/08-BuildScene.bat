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
SET Configuration=Development
SET Platform=Win64

pushd %~dp0
CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

TIME /T > build_time_begin_PlainScreen.txt
rem release "%CD%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="..\TestsProjects\PlainScreen\PlainScreen.uproject" -nocompile -nocompileeditor -nop4 -cook -stage -archive -archivedirectory="%UE_VERSION%_%Configuration%_%Platform%" -package -clientconfig=%Configuration% -clean -compressed -SkipCookingEditorContent -pak -distribution -nodebuginfo -targetplatform=%Platform% -build -utf8output
rem investigate "%CD%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="..\TestsProjects\PlainScreen\PlainScreen.uproject" -nop4 -cook -clientconfig=%Configuration% -serverconfig=%Configuration% -stage -archive -archivedirectory="%UE_VERSION%_%Configuration%_%Platform%" -package -clean -compressed -SkipCookingEditorContent -pak -distribution -nodebuginfo -targetplatform=%Platform% -build -utf8output
rem old "%CD%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="..\TestsProjects\PlainScreen\PlainScreen.uproject" -noP4 -platform=Win64 -clientconfig=Development -serverconfig=Development -cook -allmaps -build -stage -pak -archive -archivedirectory="Output Directory"
"%CD%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="..\TestsProjects\PlainScreen_%UE_VERSION%\PlainScreen_%UE_VERSION%.uproject" -noP4 -platform=%Platform% -clientconfig=%Configuration% -serverconfig=%Configuration% -cook -build -stage -pak -archive -archivedirectory="%UE_VERSION%_%Configuration%_%Platform%"
IF ERRORLEVEL 1 GOTO :error
TIME /T > build_time_end_PlainScreen.txt

:done
    @ECHO Demo scene built successfully for %UE_VERSION%.
    EXIT /B 0

:error
    @ECHO Error: failed to build demo scene for %UE_VERSION%!
    EXIT /B 1