@ECHO OFF
SETLOCAL

CALL TestDefines.bat
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
SET AmfHome=AmfMedia-%AMF_VERSION%

@ECHO Prepare UnrealEngine...
IF EXIST "%UnrealHome%" (
    @ECHO UnrealEngine folder found, clear it
    CALL 02-CleanUnrealEngine.bat
    IF ERRORLEVEL 1 GOTO :error
)
    
@ECHO Prepare Amf...
IF EXIST "%AmfHome%" (
    @ECHO Reset Amf libraries repository
    CALL 03-CleanAmfLibraries.bat
    IF ERRORLEVEL 1 GOTO :error
)

:done
    @ECHO Clean before build completed
    CALL 00-BuildAllImplementation.bat
    EXIT /B 0

:error
    @ECHO Error: failed to clean before build
    EXIT /B 1