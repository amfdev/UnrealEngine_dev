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

IF NOT DEFINED SceneConfiguration (
    @ECHO Error: SceneConfiguration variable undefined!
    GOTO :error
)

IF NOT DEFINED SceneSourceType (
    @ECHO Error: SceneSourceType variable undefined!
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
SET Configuration=%SceneConfiguration%
SET Platform=Win64

IF NOT DEFINED AMF_VERSION (
    SET PlaneProjectName=PlaneStandard
) ELSE (
    SET PlaneProjectName=PlaneAmf
)

IF /I ["%SceneSourceType%"] == ["BluePrints"] (
    @ECHO Build blueprints scene
) ELSE IF /I ["%SceneSourceType%"] == ["CPP"] (
    @ECHO Build C++ scene
    SET PlaneProjectName=%PlaneProjectName%Cpp
) ELSE (
    @ECHO Error: unsupported scene source type: %SceneSourceType%!
    GOTO :error
)

@ECHO Plane project name: %PlaneProjectName%

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

"%CD%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="..\TestsProjects\%UE_VERSION%\%PlaneProjectName%\%PlaneProjectName%.uproject" -noP4 -platform=%Platform% -clientconfig=%Configuration% -serverconfig=%Configuration% -cook -build -stage -pak -archive -archivedirectory="%UE_VERSION%_%Configuration%_%Platform%"
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Demo scene built successfully for %UE_VERSION%.
    EXIT /B 0

:error
    @ECHO Error: failed to build demo scene for %UE_VERSION%!
    EXIT /B 1