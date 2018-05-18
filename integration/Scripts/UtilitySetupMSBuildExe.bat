@ECHO OFF

PUSHD %~dp0

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

:checkMSBuild
IF DEFINED MSBUILD_EXE  (
    GOTO :testMSBuild
    )
    
@ECHO MSBUILD_EXE variable with command to run MSBuild.exe not found!
@ECHO Automation scripts will try to detects MSBuild.exe automatically later

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

CALL %CD%\Engine\Build\BatchFiles\GetMSBuildPath.bat
IF ERRORLEVEL 1 GOTO :error

:testMSBuild
@ECHO Test MSBuild:
%MSBUILD_EXE% -version
IF ERRORLEVEL 1 GOTO :error
    
:done
    @ECHO
    @ECHO Neccessary defines tested successfully!
    
    POPD %~dp0    
    EXIT /B 0

:error
    @ECHO Error: failed to test defines

    POPD %~dp0
    EXIT /B 1