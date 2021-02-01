@ECHO %Verbose%
SETLOCAL

CALL Scripts\UtilityTestDefines.bat
IF ERRORLEVEL 1 GOTO :error

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
)

IF NOT DEFINED VS_VERSION (
    @ECHO Error: VS_VERSION variable undefined!
    GOTO :error
)

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

rem to fix too long paths
rem SET UnrealHome=UnrealEngine-%UE_VERSION%
rem SET UnrealHome=UE-%UE_VERSION%

rem IF DEFINED AMF_VERSION (
rem     SET UnrealHome=%UnrealHome%-Amf
rem ) ELSE IF DEFINED STITCH_VERSION (
rem     SET UnrealHome=%UnrealHome%-Stitch
rem )

IF NOT DEFINED UnrealConfiguration (
    @ECHO Error: UnrealConfiguration variable undefined!
    GOTO :error
)

@ECHO Test UnrealEngine folder: "%UnrealHome%"

IF NOT DEFINED Build_CleanOnly (

    @ECHO:
    @ECHO Test UnrealEngine folder...
    IF NOT EXIST "%UnrealHome%" (
        @ECHO No UnrealEngine folder found, create it
        MKDIR "%UnrealHome%"
        IF ERRORLEVEL 1 GOTO :error
    )

    @ECHO:
    @ECHO Clone UnrealEngine...
    CALL Scripts\HelperUnrealClone.bat
    IF ERRORLEVEL 1 GOTO :error

    rem
    rem ivm: why need to be tested here?
    rem may be should be tested only before build?
    rem
    rem IF DEFINED Build_Devenv (
    rem    @ECHO:
    rem    @ECHO Setup Devenv...
    rem    REM Must be after cloning
    rem    CALL Scripts\UtilitySetupDevEnvExe.bat
    rem    IF ERRORLEVEL 1 (
    rem        @ECHO:
    rem        @ECHO Error: DevEnv could not be found!
    rem        GOTO :error
    rem    )
    rem ) ELSE (
    rem    @ECHO:
    rem    @ECHO Setup MS_BUILD_EXE...
    rem    REM Must be after cloning
    rem    CALL Scripts\UtilitySetupMSBuildExe.bat
    rem    IF ERRORLEVEL 1 GOTO :error
    rem )

    @ECHO:
    @ECHO Setup UnrealEngine...
    CALL Scripts\HelperUnrealSetup.bat
    IF ERRORLEVEL 1 GOTO :error

)

@ECHO:
@ECHO Prepare UnrealEngine plugins...

SET PLUGIN_TYPE=
SET PLUGIN_FOLDER=
SET PLUGIN_FOLDER_SUFFIX=
SET PLUGIN_URL=
SET PLUGIN_BRANCH=
SET PLUGIN_SOLUTION=
SET PLUGIN_APPLY_PROGRAM=
SET PLUGIN_LOGFILE=

IF DEFINED Build_SourceOrigin (
    SET PLUGIN_URL=https://github.com/GPUOpenSoftware/UnrealEngine.git
    SET PLUGIN_FOLDER_SUFFIX=-gpuopen
) ELSE IF DEFINED Build_SourceClone (
    SET PLUGIN_URL=https://github.com/amfdev/UnrealEngine_AMF
    SET PLUGIN_FOLDER_SUFFIX=-amfdev
) ELSE (
    IF DEFINED AMF_VERSION (
        @ECHO Error: amf plugin source type must be set!
        GOTO :error
    ) ELSE IF DEFINED STITCH_VERSION (
        @ECHO Error: stitch plugin source type must be set!
        GOTO :error
    )
)

IF DEFINED AMF_VERSION (
    @ECHO Prepare amf plugin...

    SET PLUGIN_TYPE=AMF
    SET PLUGIN_FOLDER=AmfMedia-%AMF_VERSION%%PLUGIN_FOLDER_SUFFIX%

    IF DEFINED Param_AmfBranch (
        SET PLUGIN_BRANCH=%Param_AmfBranch%
    ) ELSE (
        SET PLUGIN_BRANCH=AmfMedia-%AMF_VERSION%
    )

    IF DEFINED Build_VulkanVersion (
        @ECHO Build Vulkan version of AmfMedia library plugin
        SET PLUGIN_SOLUTION=Engine\Source\ThirdParty\AMD\AMF_SDK\amf\public\proj\vs%VS_VERSION%\AmfMediaFactoryHelper.sln
        SET PLUGIN_APPLY_PROGRAM=AmfMediaInstallVulkan.bat
    ) ELSE (
        @ECHO Build DX11 version of AmfMedia library plugin
        SET PLUGIN_SOLUTION=Engine\Source\ThirdParty\AMD\AMF_SDK\amf\public\proj\vs%VS_VERSION%\AmfMediaCommon.sln
        SET PLUGIN_APPLY_PROGRAM=AmfMediaInstall.bat
    )

) ELSE IF DEFINED STITCH_VERSION (
    @ECHO Prepare stitch plugin...

    SET PLUGIN_TYPE=Stitch
    SET PLUGIN_FOLDER=AmfStitchMedia-%STITCH_VERSION%%PLUGIN_FOLDER_SUFFIX%

    IF DEFINED Param_StitchBranch (
        SET PLUGIN_BRANCH=%Param_StitchBranch%
    ) ELSE (
        SET PLUGIN_BRANCH=AmfStitchMedia-%STITCH_VERSION%
    )

    SET PLUGIN_SOLUTION=Engine\Source\ThirdParty\AMD\AMF_SDK\amf\public\proj\vs%VS_VERSION%\AmfStitchMediaCommon.sln
    SET PLUGIN_APPLY_PROGRAM=AmfStitchMediaInstall.bat
)

IF DEFINED PLUGIN_TYPE (

    SET CleanFirst=!Build_Clean!!Build_CleanOnly!

    IF DEFINED CleanFirst (
        @ECHO:
        @ECHO Clean plugin folder...
        CALL Scripts\HelperClean.bat
        IF ERRORLEVEL 1 GOTO :error
    )

    IF NOT DEFINED Build_CleanOnly (

        @ECHO:
        @ECHO Clone plugin...
        CALL Scripts\HelperClone.bat
        IF ERRORLEVEL 1 GOTO :error

        @ECHO:
        @ECHO Patch plugin...
        CALL Scripts\HelperPatch.bat
        IF ERRORLEVEL 1 (
            @ECHO Failed to apply patch!
            @ECHO It seems like the code is already patched,
            @ECHO try to build it...
        )

        @ECHO:
        @ECHO Build plugin...
        CALL Scripts\HelperBuild.bat
        IF ERRORLEVEL 1 GOTO :error

        @ECHO:
        @ECHO Install plugin to UE...
        CALL Scripts\HelperApply.bat
        IF ERRORLEVEL 1 (
            @ECHO Todo: investigate why robocopy returns error
            rem GOTO :error
        )
    )
)

IF NOT DEFINED Build_CleanOnly (

    @ECHO:
    @ECHO Generate UnrealEngine solution...
    CALL Scripts\HelperUnrealPrepare.bat
    IF ERRORLEVEL 1 GOTO :error

    @ECHO:
    @ECHO Build UnrealEngine solution...
    CALL Scripts\HelperUnrealBuild.bat
    IF ERRORLEVEL 1 GOTO :error

)

:done
    @ECHO UnrealEngine built successfully
    EXIT /B 0

:error
    @ECHO Error: could not build UnrealEngine!
    EXIT /B 1