@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
)

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

IF NOT DEFINED PLUGIN_FOLDER (
    @ECHO Error: PLUGIN_FOLDER variable undefined!
    GOTO :error
)

IF DEFINED AMF_VERSION (
    @ECHO Error: not yet implemented
    GOTO :error
) ELSE IF DEFINED STITCH_VERSION (
    IF /I ["%STITCH_VERSION%"] == ["4.18"] (
        CD %UnrealHome%
        IF ERRORLEVEL 1 GOTO :error

        git am ..\Patches\AmfStitchMedia_UE418.patch
        IF ERRORLEVEL 1 GOTO :error
    ) ELSE IF /I ["%STITCH_VERSION%"] == ["4.19"] (
        SET result=

        CD %PLUGIN_FOLDER%
        IF ERRORLEVEL 1 SET result=failed

        git apply ..\Patches\AmfMedia_UE419.patch
        IF ERRORLEVEL 1 SET result=failed

        CD %UnrealHome%
        IF ERRORLEVEL 1 SET result=failed

        git am ..\Patches\AmfStitchMedia_UE418.patch
        IF ERRORLEVEL 1 SET result=failed

        IF ["failed"] == ["!result!"] GOTO :error
    )
) ELSE (
    @ECHO Error: not yet implemented
    GOTO :error
)

:done
    @ECHO Patch applied successfully
    EXIT /B 0

:error
    @ECHO Error: failed to apply patch!
    EXIT /B 1