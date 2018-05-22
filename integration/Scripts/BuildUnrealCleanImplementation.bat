@ECHO OFF
SETLOCAL

CALL Scripts\UtilityTestDefines.bat
IF ERRORLEVEL 1 GOTO :error

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
) ELSE (
    SET UnrealHome=UnrealEngine-%UE_VERSION%
)

IF NOT DEFINED AMF_VERSION (
    @ECHO Amf variable undefined! Build standard version
) ELSE (
    SET AmfHome=AmfMedia-%AMF_VERSION%
)

@ECHO Prepare UnrealEngine...
IF EXIST "%UnrealHome%" (
    @ECHO UnrealEngine folder found, clear it
    CALL Scripts\HelperUnrealClean.bat
    IF ERRORLEVEL 1 GOTO :error
)

IF DEFINED AMF_VERSION (
    @ECHO Prepare Amf...
    IF EXIST "%AmfHome%" (
        @ECHO Reset Amf libraries repository
        CALL Scripts\HelperAmfClean.bat
        IF ERRORLEVEL 1 GOTO :error
    )
)

:done
    @ECHO Clean before build completed
    CALL Scripts\BuildUnrealImplementation.bat
    EXIT /B 0

:error
    @ECHO Error: failed to clean before build
    EXIT /B 1