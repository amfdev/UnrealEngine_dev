@ECHO %Verbose%
SETLOCAL

CALL Scripts\UtilityTestDefines.bat
IF ERRORLEVEL 1 GOTO :error

SET UnrealHome=

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
)

SET UnrealHome=UnrealEngine-%UE_VERSION%

IF DEFINED AMF_VERSION (
    SET UnrealHome=%UnrealHome%-Amf
) ELSE IF DEFINED STITCH_VERSION (
    SET UnrealHome=%UnrealHome%-Stitch
)

SET AmfHome=

IF DEFINED AMF_VERSION (
    IF ["%AMF_VERSION%"] == ["%UE_VERSION%"] (
        SET AmfHome=AmfMedia-%AMF_VERSION%
    ) ELSE (
        SET AmfHome=AmfMedia-%UE_VERSION%
    )
)

@ECHO:

IF EXIST "%UnrealHome%" (

    @ECHO UnrealEngine folder found, clear it
    CALL Scripts\HelperUnrealClean.bat
    IF ERRORLEVEL 1 SET result=failed

)

SET PLUGIN_TYPE=
SET PLUGIN_FOLDER=

IF DEFINED Build_SourceOrigin (
    SET PLUGIN_FOLDER_SUFFIX=-gpuopen
) ELSE IF DEFINED Build_SourceClone (
    SET PLUGIN_FOLDER_SUFFIX=-amfdev
)

IF DEFINED AMF_VERSION (

    SET PLUGIN_TYPE=AMF
    SET PLUGIN_FOLDER=AmfMedia-%AMF_VERSION%%PLUGIN_FOLDER_SUFFIX%

) ELSE IF DEFINED STITCH_VERSION (

    SET PLUGIN_TYPE=Stitch
    SET PLUGIN_FOLDER=AmfStitchMedia-%STITCH_VERSION%%PLUGIN_FOLDER_SUFFIX%
)

IF DEFINED PLUGIN_TYPE (

    @ECHO:
    CALL Scripts\HelperClean.bat
    IF ERRORLEVEL 1 SET result=failed

)

IF /I ["failed"] == ["%result%"] GOTO :error

@ECHO:
@ECHO Cleanup finished
@ECHO:

:done
    EXIT /B 0

:error
    @ECHO Error: failed to clean before build!
    EXIT /B 1