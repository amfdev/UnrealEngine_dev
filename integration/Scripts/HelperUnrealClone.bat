@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
)

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

git init
IF ERRORLEVEL 1 GOTO :error
git pull https://github.com/EpicGames/UnrealEngine.git %UE_VERSION% >> %UnrealBuildLogFile% 2>>&1 %UnrealBuildLogFile%
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO UnrealEngine %UE_VERSION% updated
    EXIT /B 0

:error
    @ECHO Error: failed to update UnrealEngine %UE_VERSION%
    EXIT /B 1