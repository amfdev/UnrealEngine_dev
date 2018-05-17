@ECHO OFF
SETLOCAL

CALL TestDefines.bat
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
IF NOT EXIST "%UnrealHome%" (
    @ECHO No UnrealEngine folder found, create it
    MKDIR "%UnrealHome%"
)

CALL 02-CloneUnrealEng1ine.bat
IF ERRORLEVEL 1 GOTO :error

CALL SetupMSBuildExe.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Setup UnrealEngine
CALL 07-SetupUnrealEngine.bat
IF ERRORLEVEL 1 GOTO :error

IF DEFINED AMF_VERSION (

    @ECHO Prepare Amf...
    IF NOT EXIST "%AmfHome%" (
        @ECHO No Amf folder found, create it
        MKDIR "%AmfHome%"
        IF ERRORLEVEL 1 GOTO :error
    )

    CALL 03-CloneAmfLibraries.bat
    IF ERRORLEVEL 1 GOTO :error

    IF "%AMF_VERSION%" == "4.17" (

        @ECHO Patch Amf libraries
        CALL 04-PatchAmfLibraries.bat
        IF ERRORLEVEL 1 (
            @ECHO Failed to apply Amf library patch
            @ECHO It seems that Amf libraries is already patched!
            @ECHO Automation will try to build it
        )
    )

    @ECHO Build Amf libraries
    CALL 05-BuildAmfLibraries.bat
    IF ERRORLEVEL 1 GOTO :error

    @ECHO Apply Amf libraries
    CALL 06-ApplyAmfLibraries.bat
    IF ERRORLEVEL 1 (
        @ECHO ToDo: investigate why error returned here
        rem GOTO :error
    )
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

@ECHO Deploy scenes
CALL 09-DeployScene.bat
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Build all finished!
    EXIT /B 0

:error
    @ECHO Error found, break!
    EXIT /B 1