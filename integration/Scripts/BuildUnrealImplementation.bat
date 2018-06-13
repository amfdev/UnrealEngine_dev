@ECHO %Verbose%
SETLOCAL

CALL Scripts\UtilityTestDefines.bat
IF ERRORLEVEL 1 GOTO :error

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
) ELSE (
    SET UnrealHome=UnrealEngine-%UE_VERSION%
)

IF DEFINED AMF_VERSION (
    IF ["%AMF_VERSION%"] == ["%UNREAL_VERSION%"] (
        SET AmfHome=AmfMedia-%AMF_VERSION%
    ) ELSE (
        SET AmfHome=AmfMedia-%UNREAL_VERSION%
    )
)

IF NOT DEFINED UnrealConfiguration (
    @ECHO Error: UnrealConfiguration variable undefined!
    GOTO :error
)

@ECHO Prepare UnrealEngine...
IF NOT EXIST "%UnrealHome%" (
    @ECHO No UnrealEngine folder found, create it
    MKDIR "%UnrealHome%"
)

CALL Scripts\HelperUnrealClone.bat
IF ERRORLEVEL 1 GOTO :error

CALL Scripts\UtilitySetupMSBuildExe.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Setup UnrealEngine
CALL Scripts\HelperUnrealSetup.bat
IF ERRORLEVEL 1 GOTO :error

IF DEFINED AMF_VERSION (
    @ECHO Prepare Amf...
    IF NOT EXIST "%AmfHome%" (
        @ECHO No Amf folder found, create it
        MKDIR "%AmfHome%"
        IF ERRORLEVEL 1 GOTO :error
    )

    CALL Scripts\HelperAmfClone.bat
    IF ERRORLEVEL 1 GOTO :error

    @ECHO Patch Amf libraries
    CALL Scripts\HelperAmfPatch.bat
    IF ERRORLEVEL 1 (
        @ECHO:
        @ECHO Failed to apply Amf library patch
        @ECHO It seems that Amf libraries is already patched!
        @ECHO Automation will try to build it
        @ECHO:
    )

    @ECHO Build Amf libraries
    CALL Scripts\HelperAmfBuild.bat
    IF ERRORLEVEL 1 GOTO :error

    @ECHO Apply Amf libraries
    CALL Scripts\HelperAmfApply.bat
    IF ERRORLEVEL 1 (
        @ECHO ToDo: investigate why error returned here
        rem GOTO :error
    )

)

SET PROJECT_FOLDER=
SET PROJECT_URL=
SET PROJECT_BRANCH=
SET PROJECT_SOLUTION=

IF DEFINED STITCH_VERSION (
    @ECHO Prepare stitch plugin...

    SET PROJECT_FOLDER=AmfStitchMedia-4.18
    SET PROJECT_URL=https://github.com/GPUOpenSoftware/UnrealEngine.git
    SET PROJECT_BRANCH=AmfStitchMedia-4.18
    SET PROJECT_SOLUTION=Engine\Source\ThirdParty\AMD\AMF_SDK\amf\public\proj\vs2015\AmfStitchMediaCommon.sln
    SET PROJECT_APPLY_PROGRAM=AmfStitchMediaInstall.bat

    CALL Scripts\HelperClone.bat
    IF ERRORLEVEL 1 GOTO :error

    CALL Scripts\HelperPatch.bat
    IF ERRORLEVEL 1 (
        @ECHO Failed to apply patch!
        @ECHO It seems like the code is already patched,
        @ECHO try to build it...
        )

    CALL Scripts\HelperBuild.bat
    IF ERRORLEVEL 1 GOTO :error

    CALL Scripts\HelperApply.bat
    IF ERRORLEVEL 1 (
        @ECHO ToDo: investigate why error returned here
        rem GOTO :error
    )
)

@ECHO Prepare UnrealEngine solution
CALL Scripts\HelperUnrealPrepare.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Build UnrealEngine solution
CALL Scripts\HelperUnrealBuild.bat
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Build all finished!
    EXIT /B 0

:error
    @ECHO Error found, break!
    EXIT /B 1