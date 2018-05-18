@ECHO OFF
SETLOCAL

CALL ./Scripts/TestDefines.bat
IF ERRORLEVEL 1 GOTO :error

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
)

IF NOT DEFINED AMF_VERSION (
    @ECHO Error: AMF_VERSION variable undefined!
    GOTO :error
)

@ECHO Prepare folders...
SET UnrealHome=UnrealEngine-%UE_VERSION%

@ECHO Build test scenes
CALL ./Scripts/BuildScene.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Deploy scenes
CALL ./Scripts/DeployScene.bat
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Build all finished!
    EXIT /B 0

:error
    @ECHO Error found, break!
    EXIT /B 1