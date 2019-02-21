@ECHO %Verbose%
SETLOCAL

CALL Scripts\UtilityTestDefines.bat
IF ERRORLEVEL 1 GOTO :error

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
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

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

rem @ECHO Prepare folders...
rem SET UnrealHome=UnrealEngine-%UE_VERSION%

rem IF DEFINED AMF_VERSION (
rem     SET UnrealHome=%UnrealHome%-Amf
rem ) ELSE IF DEFINED STITCH_VERSION (
rem     SET UnrealHome=%UnrealHome%-Stitch
rem )

IF NOT DEFINED Build_CleanOnly (
    @ECHO Generate solution files
    CALL Scripts\HelperSceneGenerateSolution.bat
    IF ERRORLEVEL 1 GOTO :error
)

IF NOT DEFINED Build_GenerateSolutionOnly (

    @ECHO Build test scenes
    CALL Scripts\HelperSceneBuild.bat
    IF ERRORLEVEL 1 GOTO :error

    IF NOT DEFINED Build_CleanOnly (
        @ECHO Deploy scenes
        CALL Scripts\HelperSceneDeploy.bat
        IF ERRORLEVEL 1 GOTO :error
    )

)

:done
    @ECHO Scene built successfully
    EXIT /B 0

:error
    @ECHO Error: could not build scene!
    EXIT /B 1