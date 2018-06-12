@ECHO %Verbose%

SETLOCAL
SETLOCAL EnableDelayedExpansion
IF ERRORLEVEL 1 GOTO :error

IF NOT DEFINED AMF_VERSION (
    @ECHO Error: AMF_VERSION variable undefined!
    GOTO :error
)

IF NOT DEFINED AmfHome (
    @ECHO Error: AmfHome variable undefined!
    GOTO :error
)

CD %AmfHome%
IF ERRORLEVEL 1 GOTO :error

IF ["%AMF_VERSION%"] == ["4.17"] (
    git apply ..\Patches\CmdLogger.patch
    IF ERRORLEVEL 1 GOTO :error    
) ELSE IF ["%AMF_VERSION%"] == ["4.18"] (
    git apply ..\Patches\AmfMedia_UE418.patch
    IF ERRORLEVEL 1 GOTO :error    
) ELSE IF ["%AMF_VERSION%"] == ["4.19"] (
    SET result=

    git apply ..\Patches\AmfMedia_UE418.patch
    IF ERRORLEVEL 1 SET result=failed

    git apply ..\Patches\AmfMedia_UE419.patch
    IF ERRORLEVEL 1 SET result=failed

    IF ["failed"] == ["!result!"] GOTO :error
)

:done
    @ECHO Amf libraries patched
    EXIT /B 0

:error
    @ECHO Error: failed to patch Amf libraries
    EXIT /B 1