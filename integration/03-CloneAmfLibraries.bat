@ECHO OFF
SETLOCAL

IF NOT DEFINED AmfHome (
    @ECHO Error: AmfHome variable undefined!
    GOTO :error
)

CD %AmfHome%
IF ERRORLEVEL 1 GOTO :error

git init
IF ERRORLEVEL 1 GOTO :error
git pull https://github.com/GPUOpenSoftware/UnrealEngine.git AmfMedia-4.17
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Amf libraries updated
    EXIT /B 0

:error
    @ECHO Error: failed to update Amf libraries
    EXIT /B 1