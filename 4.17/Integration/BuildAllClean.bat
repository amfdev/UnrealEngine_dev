rem @ECHO OFF
rem SETLOCAL

CALL TestDefines.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Prepare folders...
SET UnrealHome=UnrealEngine-4.17
SET AmfHome=AmfMedia-4.17

@ECHO Prepare UnrealEngine...
IF NOT EXIST "%UnrealHome%" (
    @ECHO No UnrealEngine folder found, create it
    MKDIR "%UnrealHome%"
) ELSE (
    @ECHO UnrealEngine folder found, clear it
    rem CALL 02-CleanUnrealEngine.bat
    IF ERRORLEVEL 1 GOTO :error
)
    
CALL 02-CloneUnrealEngine.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Prepare Amf...
IF NOT EXIST "%AmfHome%" (
    @ECHO No Amf folder found, create it
    MKDIR "%AmfHome%"
) ELSE (
    @ECHO Reset Amf libraries repository
    CALL 03-CleanAmfLibraries.bat
    IF ERRORLEVEL 1 GOTO :error
)
    
CALL 03-CloneAmfLibraries.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Patch Amf libraries
CALL 04-PatchAmfLibraries.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Build Amf libraries
CALL 05-BuildAmfLibraries.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Setup UnrealEngine
CALL 07-SetupUnrealEngine.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Apply Amf libraries
CALL 06-ApplyAmfLibraries.bat
IF ERRORLEVEL 1 (
    @ECHO ToDo: investigate why error returned here
    rem GOTO :error
)

@ECHO Prepare UnrealEngine solution
CALL 07-PrepareUnrealEngineSolution.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Prepare UnrealEngine solution
CALL 07-BuildUnrealEngine.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Build test scenes
CALL 08-BuildScene.bat
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Clean build finished!
    EXIT /B 0

:error
    @ECHO Error found, break!
    EXIT /B 1