rem @ECHO OFF
SETLOCAL

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

git reset --hard && git clean -fdx
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO UnrealEngine cleaned
    EXIT /B 0

:error
    @ECHO Error: failed to clean UnrealEngine
    EXIT /B 1