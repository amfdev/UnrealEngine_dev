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

IF /I ["%SceneSourceType%"] == ["BluePrints"] (
    @ECHO Build blueprints scene

    SET SceneProjectName=%SceneName%

) ELSE IF /I ["%SceneSourceType%"] == ["CPP"] (
    @ECHO Build C++ scene

    SET SceneProjectName=%SceneName%Cpp

) ELSE (
    @ECHO Error: unsupported scene source type: %SceneSourceType%!
    GOTO :error
)

@ECHO Scene project name: !SceneProjectName!
@ECHO Output file name: %SceneBuildLogFile%

EXIT /b 0

IF DEFINED Build_CleanOnly (
    @ECHO Clean scene...

    CD TestsProjects\%UE_VERSION%\!SceneProjectName!
    IF ERRORLEVEL 1 GOTO :error

    REM git reset --hard
    IF ERRORLEVEL 1 GOTO :error

    REM git clean -fdx
    IF ERRORLEVEL 1 GOTO :error

    git checkout -- .
    IF ERRORLEVEL 1 GOTO :error

    @ECHO Demo scene cleaned successfully for %UE_VERSION%.

) ELSE (
    @ECHO Build scene...

    CD %UnrealHome%
    IF ERRORLEVEL 1 GOTO :error

    CALL Engine\Build\BatchFiles\RunUAT.bat BuildCookRun -project="..\TestsProjects\%UE_VERSION%\!SceneProjectName!\!SceneProjectName!.uproject" -noP4 -platform=%Platform% -clientconfig=%Configuration% -serverconfig=%Configuration% -cook -build -stage -pak -archive -archivedirectory="%UE_VERSION%_%Configuration%_%Platform%" >> "%SceneBuildLogFile%" 2>>&1
    IF ERRORLEVEL 1 GOTO :error

    @ECHO Demo scene built successfully for %UE_VERSION%.
)

:done
    EXIT /B 0

:error
    @ECHO Error: failed to build or clean demo scene for %UE_VERSION%!
    EXIT /B 1