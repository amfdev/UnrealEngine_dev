@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

git config --global core.longpaths true
IF ERRORLEVEL 1 GOTO :error

SET GIT_ASK_YESNO=false

git reset --hard
IF ERRORLEVEL 1 GOTO :error

git clean -fdx
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO UnrealEngine cleaned
    EXIT /B 0

:error
    @ECHO Error: failed to clean UnrealEngine!
    EXIT /B 1