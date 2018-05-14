@ECHO OFF
SETLOCAL

CALL TestDefines.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Build version 4.17
SET UE_VERSION=4.17
SET AMF_VERSION=4.17

rem CALL 00-BuildAllCleanImplementation.bat
IF ERRORLEVEL 1 (
    @ECHO Error: failed to build version %UE_VERSION%
) ELSE (
    @ECHO Build for version %UE_VERSION% successfull!
)

@ECHO Build version 4.18
SET UE_VERSION=4.18
SET AMF_VERSION=4.18

CALL 00-BuildAllCleanImplementation.bat
IF ERRORLEVEL 1 (
    @ECHO Error: failed to build version %UE_VERSION%
) ELSE (
    @ECHO Build for version %UE_VERSION% successfull!
)

:done
    @ECHO Clean build finished
    EXIT /B 0

:error
    @ECHO Error: clean build failed
    EXIT /B 1