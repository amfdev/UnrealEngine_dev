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
    @ECHO Clean build finished
    EXIT /B 0

:error
    @ECHO Error: clean build failed
    EXIT /B 1

:runBuild version_number
    @ECHO Build version %~1
    SET UE_VERSION=%~1
    SET AMF_VERSION=%~1

    CALL 00-BuildAllCleanImplementation.bat
    IF ERRORLEVEL 1 (
        @ECHO Error: failed to clean build version %~1
        EXIT /B 1
    ) ELSE (
        @ECHO Clean build for version %~1 successfull!
        EXIT /B 0
    )