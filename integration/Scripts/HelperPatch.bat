@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
)

IF NOT DEFINED PROJECT_FOLDER (
    @ECHO Error: PROJECT_FOLDER variable undefined!
    GOTO :error
)

IF DEFINED AMF_VERSION (
    IF /I ["%UE_VERSION%"] == ["4.17"] (    
        CD %PROJECT_FOLDER%
        IF ERRORLEVEL 1 GOTO :error

        git apply ..\Patches\CmdLogger.patch
        IF ERRORLEVEL 1 GOTO :error
    )
) ELSE IF DEFINED STITCH_VERSION (
    IF /I ["%UE_VERSION%"] == ["4.18"] (    
        CD %PROJECT_FOLDER%
        IF ERRORLEVEL 1 GOTO :error

        git apply ..\Patches\AmfStitchMedia_UE418.patch
        IF ERRORLEVEL 1 GOTO :error
    )
)

:done
    @ECHO Patch applied successfully
    EXIT /B 0

:error
    @ECHO Error: failed to apply patch!
    EXIT /B 1