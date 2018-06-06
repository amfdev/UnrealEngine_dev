@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED PROJECT_FOLDER (
    @ECHO Error: PROJECT_FOLDER variable undefined!
    GOTO :error
)

IF NOT DEFINED PROJECT_APPLY_PROGRAM (
    @ECHO Error: PROJECT_APPLY_PROGRAM variable undefined!
    GOTO :error
)

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

SET CurrentDirectory=%CD%

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

CD %CurrentDirectory%

CD %PROJECT_FOLDER%
IF ERRORLEVEL 1 GOTO :error

CALL %PROJECT_APPLY_PROGRAM% "..\%UnrealHome%"
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Plugin libraries applied to UnrealEngine
    EXIT /B 0

:error
    @ECHO Error: failed to apply plugin libraries to UnrealEngine
    EXIT /B 1