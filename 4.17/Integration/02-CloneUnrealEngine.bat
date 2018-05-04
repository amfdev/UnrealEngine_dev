@ECHO OFF
SETLOCAL

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

git init
IF ERRORLEVEL 1 GOTO :error
REM git config user.email %1
REM git config user.name %1
REM git config user.password %2
REM git pull https://%1:%2@github.com/EpicGames/UnrealEngine.git 4.17
REM git clone https://github.com/EpicGames/UnrealEngine.git
git pull https://github.com/EpicGames/UnrealEngine.git 4.17
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO UnrealEngine updated
    EXIT /B 0

:error
    @ECHO Error: failed to update UnrealEngine
    EXIT /B 1