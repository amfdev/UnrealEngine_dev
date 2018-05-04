@ECHO OFF
SETLOCAL

CALL TestDefines.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Prepare folders...
SET UnrealHome=UnrealEngine-4.17
SET AmfHome=AmfMedia-4.17

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
    CALL BuildAllClean.bat
    EXIT /B 0

:error
    @ECHO Error: failed to clean before build
    EXIT /B 1