@ECHO %Verbose%

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

SETLOCAL

IF DEFINED AMF_VERSION (
    CD %PLUGIN_FOLDER%

    IF ERRORLEVEL 1 GOTO :error

    IF ["%UE_VERSION%"] == ["4.17"] (

        IF DEFINED Build_SourcePatch (
            git apply ..\Patches\AmfMedia_UE417.patch
            rem IF ERRORLEVEL 1 GOTO :error
        )

    ) ELSE IF ["%UE_VERSION%"] == ["4.18"] (

        SET result=

        IF DEFINED Build_SourcePatch (
            git apply ..\Patches\AmfMedia_UE418.patch
            IF ERRORLEVEL 1 SET result=failed
            REM git apply ..\Patches\AmfMedia_UE418_2.patch
            REM IF ERRORLEVEL 1 SET result=failed
        )

        rem IF /I ["failed"] == ["%result%"] GOTO :error

    ) ELSE IF ["%UE_VERSION%"] == ["4.19"] (

        SET result=

        IF DEFINED Build_SourcePatch (
            git apply ..\Patches\AmfMedia_UE418.patch
            IF ERRORLEVEL 1 SET result=failed
            REM git apply ..\Patches\AmfMedia_UE418_2.patch
            REM IF ERRORLEVEL 1 SET result=failed

            git apply ..\Patches\AmfMedia_UE419.patch
            IF ERRORLEVEL 1 SET result=failed
        )

        rem IF /I ["failed"] == ["%result%"] GOTO :error
    )

    IF DEFINED Build_SourcePatch (
        IF EXIST "..\Patches\Plugin\AmfMedia_%UE_VERSION%.diff" (
            @ECHO Found patch for plugin, patching...
            git apply "..\Patches\Plugin\AmfMedia_%UE_VERSION%.diff"
            IF ERRORLEVEL 1 (
                @ECHO Error: patching for plugin AmfMedia unsuccessfull...
                SET result=failed
            ) ELSE (
                @ECHO Plugin AmfMedia patched successfully
            )
        ) ELSE (
            @ECHO Patch for plugin AmfMedia not found
        )
    )
)

IF DEFINED STITCH_VERSION (
    IF ["%STITCH_VERSION%"] == ["4.18"] (
        CD %UnrealHome%
        IF ERRORLEVEL 1 GOTO :error

        REM Apply this patch in any case
        git am ..\Patches\AmfStitchMedia_UE418.patch
        IF ERRORLEVEL 1 GOTO :error
    ) ELSE IF ["%STITCH_VERSION%"] == ["4.19"] (
        SET result=

        IF DEFINED Build_SourcePatch (
            CD %PLUGIN_FOLDER%
            IF ERRORLEVEL 1 SET result=failed

            git apply ..\Patches\AmfMedia_UE419.patch
            IF ERRORLEVEL 1 SET result=failed

            CD %UnrealHome%
            IF ERRORLEVEL 1 SET result=failed
        )

        IF /I ["failed"] == ["%result%"] GOTO :error
    )

    IF DEFINED Build_SourcePatch (
        CD %PLUGIN_FOLDER%
        IF EXIST "..\Patches\Plugin\AmfStitchMedia_%UE_VERSION%.diff" (
            @ECHO Found patch for plugin, patching...
            git apply "..\Patches\Plugin\AmfStitchMedia_%UE_VERSION%.diff"
            IF ERRORLEVEL 1 (
                @ECHO Error: patching for plugin AmfStitchMedia unsuccessfull...
                SET result=failed
            ) ELSE (
                @ECHO AmfStitchMedia plugin patched successfully
            )
        ) ELSE (
            @ECHO Patch for plugin AmfStitchMedia not found
        )
    )
)

:done
    @ECHO Patches applied successfully
    EXIT /B 0

:error
    @ECHO Error: failed to apply patch!
    EXIT /B 1