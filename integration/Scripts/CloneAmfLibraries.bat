@ECHO OFF
SETLOCAL

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

git init
IF ERRORLEVEL 1 GOTO :error
git pull https://github.com/GPUOpenSoftware/UnrealEngine.git AmfMedia-%AMF_VERSION%
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Amf libraries %AMF_VERSION% updated
    EXIT /B 0

:error
    @ECHO Error: failed to update Amf libraries %AMF_VERSION%
    EXIT /B 1