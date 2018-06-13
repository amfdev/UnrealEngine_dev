@ECHO %Verbose%
SETLOCAL

CALL Scripts\UtilityTestDefines.bat
IF ERRORLEVEL 1 GOTO :error

SET UnrealHome=

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
) ELSE (
    SET UnrealHome=UnrealEngine-%UE_VERSION%
)

SET AmfHome=

IF DEFINED AMF_VERSION (
    SET AmfHome=AmfMedia-%AMF_VERSION%
    @ECHO Amf variable defined, AmfHome: AmfMedia-%AMF_VERSION%
)

@ECHO Prepare UnrealEngine...
IF EXIST "%UnrealHome%" (
    @ECHO UnrealEngine folder found, clear it
    CALL Scripts\HelperUnrealClean.bat
    IF ERRORLEVEL 1 GOTO :error
)

IF DEFINED AMF_VERSION (
    @ECHO Clean Amf...
    IF EXIST "%AmfHome%" (
        @ECHO Reset Amf libraries repository
        CALL Scripts\HelperAmfClean.bat
        IF ERRORLEVEL 1 GOTO :error
    )
) ELSE IF DEFINED STITCH_VERSION (
    @ECHO Clean Stitch...
    @ECHO:
    @ECHO:
    @ECHO TODO: Implement clean of Stitch plugin sources
    @ECHO:
    @ECHO:
)

@ECHO:
@ECHO Cleanup finished
@ECHO:

:done
    EXIT /B 0

:error
    @ECHO Error: failed to clean before build!
    EXIT /B 1