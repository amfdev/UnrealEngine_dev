@ECHO OFF
SETLOCAL

CALL ./Scripts/HelperTestDefines.bat
IF ERRORLEVEL 1 GOTO :error

if [%1]==[] (
    CALL :runBuild 4.17
    CALL :runBuild 4.17 4.17
    CALL :runBuild 4.18 4.18
) ELSE (
    CALL :runBuild %1 %2
)

:done
    @ECHO Build all finished
    EXIT /B 0

:error
    @ECHO Error: build all failed!
    EXIT /B 1

:runBuild unreal_number amf_number
    @ECHO Build version %~1
    SET UE_VERSION=%~1

    if "%~2" == "" (
        @ECHO Set empty amf revision to generate standard player
        SET AMF_VERSION=
    ) ELSE (
        @ECHO Set amf revision to %~1
        SET AMF_VERSION=%~1
    )

    CALL ./Scripts/BuildUnrealImplementation.bat
    IF ERRORLEVEL 1 (
        @ECHO Error: failed to clean build version %~1
        EXIT /B 1
    )

    CALL ./Scripts/BuildSceneImplementation.bat
    IF ERRORLEVEL 1 (
        @ECHO Error: failed to build scene
        EXIT /B 1
    )