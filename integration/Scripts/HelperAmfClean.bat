rem @ECHO OFF
SETLOCAL

IF NOT DEFINED AmfHome (
    @ECHO Error: AmfHome variable undefined!
    GOTO :error
)

CD %AmfHome%
IF ERRORLEVEL 1 GOTO :error

git reset --hard && git clean -fdx
IF ERRORLEVEL 1 GOTO :error

RD /S /Q "%CD%/.git/rebase-apply"

:done
    @ECHO Amf libraries cleaned
    EXIT /B 0

:error
    @ECHO Error: failed to clean Amf libraries
    EXIT /B 1