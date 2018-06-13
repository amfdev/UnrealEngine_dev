@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED AmfHome (
    @ECHO Error: AmfHome variable undefined!
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

CD %AmfHome%
IF ERRORLEVEL 1 GOTO :error

AmfMediaInstall.bat "..\%UnrealHome%"
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Amf libraries applied to UnrealEngine
    EXIT /B 0

:error
    @ECHO Error: failed to apply Amf libraries to UnrealEngine!
    EXIT /B 1