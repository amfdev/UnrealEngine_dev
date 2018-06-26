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

IF DEFINED AMF_VERSION (

    SET PLUGIN_TYPE=AMF

    IF DEFINED Build_PatchPlugin (

        SET PLUGIN_FOLDER=AmfMedia-%AMF_VERSION%

    ) ELSE (

        SET PLUGIN_FOLDER=AmfMedia-%AMF_VERSION%-amfdev

    )

) ELSE IF DEFINED STITCH_VERSION (

    SET PLUGIN_TYPE=Stitch

    IF DEFINED Build_PatchPlugin (

        SET PLUGIN_FOLDER=AmfStitchMedia-%STITCH_VERSION%

    ) ELSE (

        SET PLUGIN_FOLDER=AmfStitchMedia-%STITCH_VERSION%-amfdev

    )
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