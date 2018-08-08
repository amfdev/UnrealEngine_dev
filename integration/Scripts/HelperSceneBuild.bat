@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
)

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

IF NOT DEFINED SceneName (
    @ECHO Error: SceneSourceType variable undefined!
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

SET Target=build
SET MaxCPUCount=/maxcpucount
SET Configuration=%SceneConfiguration%
SET Platform=Win64

SET SceneProjectName=%SceneName%

IF /I ["%SceneSourceType%"] == ["BluePrints"] (
    @ECHO Build blueprints scene

) ELSE IF /I ["%SceneSourceType%"] == ["CPP"] (
    @ECHO Build C++ scene

    SET SceneProjectName=%SceneProjectName%Cpp

) ELSE (
    @ECHO Error: unsupported scene source type: %SceneSourceType%!
    GOTO :error\
)

@ECHO Scene name: %SceneProjectName%
@ECHO Output file name: %SceneBuildLogFile%

IF DEFINED Build_CleanOnly (
    @ECHO Clean scene...

    CD TestsProjects\%UE_VERSION%\%SceneProjectName%
    IF ERRORLEVEL 1 GOTO :error

    git reset --hard
    IF ERRORLEVEL 1 GOTO :error

    git clean -fdx
    IF ERRORLEVEL 1 GOTO :error

) ELSE (
    @ECHO Build scene...

    CD %UnrealHome%
    IF ERRORLEVEL 1 GOTO :error

    CALL "%CD%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="..\TestsProjects\%UE_VERSION%\%SceneProjectName%\%SceneProjectName%.uproject" -noP4 -platform=%Platform% -clientconfig=%Configuration% -serverconfig=%Configuration% -cook -build -stage -pak -archive -archivedirectory="%UE_VERSION%_%Configuration%_%Platform%" >> "%SceneBuildLogFile%" 2>>&1
    IF ERRORLEVEL 1 GOTO :error
)

:done
    @ECHO Demo scene built successfully for %UE_VERSION%.
    EXIT /B 0

:error
    @ECHO Error: failed to build demo scene for %UE_VERSION%!
    EXIT /B 1