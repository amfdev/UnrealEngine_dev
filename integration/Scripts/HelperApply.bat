@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED PLUGIN_FOLDER (
    @ECHO Error: PLUGIN_FOLDER variable undefined!
    GOTO :error
)

IF NOT DEFINED PLUGIN_APPLY_PROGRAM (
    @ECHO Error: PLUGIN_APPLY_PROGRAM variable undefined!
    GOTO :error
)

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

@ECHO Plugin folder: %PLUGIN_FOLDER%
@ECHO Install programm: %PLUGIN_APPLY_PROGRAM%
@ECHO Unreal home: %UnrealHome%

SET CurrentDirectory=%CD%

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

CD %CurrentDirectory%

CD %PLUGIN_FOLDER%
IF ERRORLEVEL 1 GOTO :error

CALL %PLUGIN_APPLY_PROGRAM% "..\%UnrealHome%"
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Plugin libraries applied to UnrealEngine
    EXIT /B 0

:error
    @ECHO Error: failed to apply plugin libraries to UnrealEngine
    EXIT /B 1