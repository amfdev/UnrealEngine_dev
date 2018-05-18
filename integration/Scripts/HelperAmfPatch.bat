rem @ECHO OFF
SETLOCAL

IF NOT DEFINED AmfHome (
    @ECHO Error: AmfHome variable undefined!
    GOTO :error
)

CD %AmfHome%
IF ERRORLEVEL 1 GOTO :error

git apply ..\Patches\CmdLogger.patch
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Amf libraries patched
    EXIT /B 0

:error
    @ECHO Error: failed to patch Amf libraries
    EXIT /B 1