@ECHO %Verbose%

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

:checkMSBuild
IF DEFINED VSComnToolsPath  (
    GOTO :testVSComnToolsPath
    )

@ECHO VSComnToolsPath variable with path to run devenv.exe not found!
@ECHO Automation scripts will try to detects devenv.exe automatically later

rem PUSHD %~dp0
CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

CALL %CD%\Engine\Build\BatchFiles\GetVSComnToolsPath.bat
IF ERRORLEVEL 1 GOTO :error

:testMSBuild
@ECHO Test VSComnToolsPath: %VSComnToolsPath%
IF EXIST "%VSComnToolsPath%\..\ide\devenv.exe" (
    @ECHO Devenv.exe found
) ELSE (
    @ECHO Error: Devenv.exe not found!
    GOTO :error
)
@ECHO todo: test run devenv

:done
    @ECHO:
    @ECHO Devenv.exe found and tested successfully!

    POPD %~dp0
    EXIT /B 0

:error
    @ECHO Error: failed to test defines!

    POPD %~dp0
    EXIT /B 1