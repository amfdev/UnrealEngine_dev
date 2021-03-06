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
    @ECHO Attention: BluePrints scene does not need solution generation!

) ELSE IF /I ["%SceneSourceType%"] == ["CPP"] (
    @ECHO Generate solution for C++ scene...

    SET SceneProjectName=%SceneName%Cpp

    @ECHO Scene project name: !SceneProjectName!
    @ECHO Output file name: %SceneBuildLogFile%

    @ECHO Generate solution files for scene...

    CD %UnrealHome%
    IF ERRORLEVEL 1 GOTO :error

    CALL Engine\Binaries\DotNET\UnrealBuildTool.exe -projectfiles -project="..\..\..\TestsProjects\%UE_VERSION%\!SceneProjectName!\!SceneProjectName!.uproject" -game -engine -progress
    IF ERRORLEVEL 1 GOTO :error

    @ECHO Solution file generated successfully

) ELSE (
    @ECHO Error: unsupported scene source type: %SceneSourceType%!
    GOTO :error\
)

:done
    EXIT /B 0

:error
    @ECHO Error: failed to build demo scene for %UE_VERSION%!
    EXIT /B 1