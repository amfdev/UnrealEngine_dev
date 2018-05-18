rem @ECHO OFF
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

rem pushd %~dp0
CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

IF NOT DEFINED AMF_VERSION (
    TIME /T > build_time_begin_PlaneStandard.txt
    @ECHO Amf version unspecified, standard media playback will be used
    "%CD%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="..\TestsProjects\%UE_VERSION%\PlaneStandard\PlaneStandard.uproject" -noP4 -platform=%Platform% -clientconfig=%Configuration% -serverconfig=%Configuration% -cook -build -stage -pak -archive -archivedirectory="%UE_VERSION%_%Configuration%_%Platform%"
    IF ERRORLEVEL 1 GOTO :error
    TIME /T > build_time_end_PlaneStandard.txt
) ELSE (
    TIME /T > build_time_begin_PlaneAmf.txt
    @ECHO Amf version specified, amf playback will be used
    "%CD%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="..\TestsProjects\%UE_VERSION%\PlaneAmf\PlaneStandard.uproject" -noP4 -platform=%Platform% -clientconfig=%Configuration% -serverconfig=%Configuration% -cook -build -stage -pak -archive -archivedirectory="%UE_VERSION%_%Configuration%_%Platform%"
    IF ERRORLEVEL 1 GOTO :error
    TIME /T > build_time_end_PlaneAmf.txt
)

:done
    @ECHO Demo scene built successfully for %UE_VERSION%.
    EXIT /B 0

:error
    @ECHO Error: failed to build demo scene for %UE_VERSION%!
    EXIT /B 1