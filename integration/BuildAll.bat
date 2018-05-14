@ECHO OFF
SETLOCAL

CALL TestDefines.bat
IF ERRORLEVEL 1 GOTO :error

if [%1]==[] (
    CALL :runBuild 4.17
    CALL :runBuild 4.18
) ELSE (
    CALL :runBuild %1
)

:done
    @ECHO Build all finished
    EXIT /B 0

:error
    @ECHO Error: build all failed!
    EXIT /B 1

:runBuild version_number
    @ECHO Build version %~1
    SET UE_VERSION=%~1
    SET AMF_VERSION=%~1

    CALL 00-BuildAllImplementation.bat
    IF ERRORLEVEL 1 (
        @ECHO Error: failed to build version %~1
        EXIT /B 1
    ) ELSE (
        @ECHO Build for version %~1 successfull!
        EXIT /B 0
    )