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

IF NOT DEFINED UnrealConfiguration (
    @ECHO Error: UnrealConfiguration variable undefined!
    GOTO :error
)

@ECHO:
@ECHO Prepare UnrealEngine...
IF NOT EXIST "%UnrealHome%" (
    @ECHO No UnrealEngine folder found, create it
    MKDIR "%UnrealHome%"
    IF ERRORLEVEL 1 GOTO :error
)

CALL Scripts\HelperUnrealClone.bat
IF ERRORLEVEL 1 GOTO :error

CALL Scripts\UtilitySetupMSBuildExe.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Setup UnrealEngine
CALL Scripts\HelperUnrealSetup.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO:
@ECHO Prepare UnrealEngine plugins...

SET PLUGIN_TYPE=
SET PLUGIN_FOLDER=
SET PLUGIN_URL=
SET PLUGIN_BRANCH=
SET PLUGIN_SOLUTION=
SET PLUGIN_APPLY_PROGRAM=

IF DEFINED AMF_VERSION (
    @ECHO Prepare amf plugin...

    SET PLUGIN_TYPE=AMF

    IF DEFINED Build_PatchPlugin (

        SET PLUGIN_FOLDER=AmfMedia-%AMF_VERSION%
        SET PLUGIN_URL=https://github.com/GPUOpenSoftware/UnrealEngine.git

        IF DEFINED Param_AmfBranch (
            SET PLUGIN_BRANCH=%Param_AmfBranch%
        ) ELSE (
            IF ["%AMF_VERSION%"] == ["4.19"] (
                SET PLUGIN_BRANCH=AmfMedia-4.18
            ) ELSE (
                SET PLUGIN_BRANCH=AmfMedia-%AMF_VERSION%
            )
        )

    ) ELSE (

        SET PLUGIN_FOLDER=AmfMedia-%AMF_VERSION%-amfdev
        SET PLUGIN_URL=https://github.com/amfdev/UnrealEngine_AMF
        SET PLUGIN_BRANCH=AmfMedia-%AMF_VERSION%

    )

    SET PLUGIN_SOLUTION=Engine\Source\ThirdParty\AMD\AMF_SDK\amf\public\proj\vs2015\AmfMediaCommon.sln
    SET PLUGIN_APPLY_PROGRAM=AmfMediaInstall.bat

) ELSE IF DEFINED STITCH_VERSION (
    @ECHO Prepare stitch plugin...

    SET PLUGIN_TYPE=Stitch

    IF DEFINED Build_PatchPlugin (

        SET PLUGIN_FOLDER=AmfStitchMedia-%STITCH_VERSION%
        SET PLUGIN_URL=https://github.com/GPUOpenSoftware/UnrealEngine.git

        IF DEFINED Param_StitchBranch (
            SET PLUGIN_BRANCH=%Param_StitchBranch%
        ) ELSE (
            IF ["%STITCH_VERSION%"] == ["4.19"] (
                SET PLUGIN_BRANCH=AmfStitchMedia-4.18
            ) ELSE (
                SET PLUGIN_BRANCH=AmfStitchMedia-%STITCH_VERSION%
            )
        )

    ) ELSE (

        SET PLUGIN_FOLDER=AmfStitchMedia-%STITCH_VERSION%-amfdev
        SET PLUGIN_URL=https://github.com/amfdev/UnrealEngine_AMF
        SET PLUGIN_BRANCH=AmfStitchMedia-%STITCH_VERSION%
    )

    SET PLUGIN_SOLUTION=Engine\Source\ThirdParty\AMD\AMF_SDK\amf\public\proj\vs2015\AmfStitchMediaCommon.sln
    SET PLUGIN_APPLY_PROGRAM=AmfStitchMediaInstall.bat
)

IF DEFINED PLUGIN_TYPE (
    @ECHO:
    CALL Scripts\HelperClean.bat
    IF ERRORLEVEL 1 GOTO :error

    @ECHO:
    CALL Scripts\HelperClone.bat
    IF ERRORLEVEL 1 GOTO :error

    IF DEFINED Build_PatchPlugin (
        @ECHO:
        CALL Scripts\HelperPatch.bat
        IF ERRORLEVEL 1 (
            @ECHO Failed to apply patch!
            @ECHO It seems like the code is already patched,
            @ECHO try to build it...
            )
    )

    @ECHO:
    CALL Scripts\HelperBuild.bat
    IF ERRORLEVEL 1 GOTO :error

    @ECHO:
    CALL Scripts\HelperApply.bat
    IF ERRORLEVEL 1 (
        @ECHO ToDo: investigate why error returned here
        rem GOTO :error
    )
)

@ECHO:
@ECHO Prepare UnrealEngine solution
CALL Scripts\HelperUnrealPrepare.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO:
@ECHO Build UnrealEngine solution
CALL Scripts\HelperUnrealBuild.bat
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO UnrealEngine built successfully
    EXIT /B 0

:error
    @ECHO Error: could not build UnrealEngine!
    EXIT /B 1