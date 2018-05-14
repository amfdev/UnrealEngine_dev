@ECHO OFF
SETLOCAL

CALL TestDefines.bat
IF ERRORLEVEL 1 GOTO :error

@ECHO Build version 4.17
SET UE_VERSION=4.17
SET AMF_VERSION=4.17

CALL 00-BuildAllImplementation.bat
IF ERRORLEVEL 1 (
    @ECHO Error: failed to build version %UE_VERSION%
) ELSE (
    @ECHO Build for version %UE_VERSION% successfull!
)

rem @ECHO Build version 4.18
rem SET UE_VERSION=4.18
rem SET AMF_VERSION=4.18

rem CALL 00-BuildAllCleanImplementation.bat
rem IF ERRORLEVEL 1 (
rem    @ECHO Error: failed to build version %UE_VERSION%
rem ) ELSE (
rem     @ECHO Build for version %UE_VERSION% successfull!
rem )

:done
    @ECHO Clean build finished
    EXIT /B 0

:error
    @ECHO Error: clean build failed
    EXIT /B 1