@ECHO %Verbose%

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

IF DEFINED MSBUILD_EXE  (
    GOTO :testMSBuild
    )

@ECHO MSBUILD_EXE variable with command to run MSBuild.exe not found!
@ECHO Automation scripts will try to detects MSBuild.exe automatically:

CALL %UnrealHome%\Engine\Build\BatchFiles\GetMSBuildPath.bat
IF ERRORLEVEL 1 GOTO :error

REM fix issue in script
@ECHO %Verbose%

:testMSBuild
@ECHO Test MSBuild:
%MSBUILD_EXE% -version
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO:
    @ECHO: Msbuild.exe found and tested successfully!

    EXIT /B 0

:error
    @ECHO Error: failed to test defines!

    EXIT /B 1