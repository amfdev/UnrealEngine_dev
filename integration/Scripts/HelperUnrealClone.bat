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

SET unrealTAG=

IF DEFINED Param_UEBranch (
    SET unrealTAG="%Param_UEBranch%"
) ELSE (
    SET unrealTAG="%UE_VERSION%"
)

rem IF EXIST "%UnrealHome%\" (
rem    IF DEFINED Build_Clean (
rem        RMDIR "%UnrealHome%\" /Q /S
rem    )
rem )

IF DEFINED Build_Clean (
    git clone https://github.com/EpicGames/UnrealEngine.git "%UnrealHome%"
    IF ERRORLEVEL 1 (
        @ECHO Error: failed to clone UnrealEngine!
        rem GOTO :error
    )

    IF DEFINED Param_UEBranch (
        git checkout -b %Param_UEBranch% %Param_UEBranch%
        @ECHO Error: could not switch to specified branch or tag!
        rem GOTO :error
    )
)

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

rem Update git if folder already exist
IF NOT DEFINED Build_Clean (
    git pull
    rem IF ERRORLEVEL 1 GOTO :error

    IF DEFINED Param_UEBranch (
        git checkout -b %Param_UEBranch% %Param_UEBranch%
        @ECHO Error: could not switch to specified branch or tag!
        rem GOTO :error
    )
)

rem git init
rem IF ERRORLEVEL 1 GOTO :error

rem git pull https://github.com/EpicGames/UnrealEngine.git %unrealTAG%
rem IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO UnrealEngine %UE_VERSION% updated
    EXIT /B 0

:error
    @ECHO Error: failed to update UnrealEngine %UE_VERSION%!
    EXIT /B 1