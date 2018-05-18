rem @ECHO OFF

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

IF DEFINED MSBUILD_EXE  (
    GOTO :testMSBuild
    )
    
@ECHO MSBUILD_EXE variable with command to run MSBuild.exe not found!
@ECHO Automation scripts will try to detects MSBuild.exe automatically later

rem PUSHD %~dp0
rem PUSHD %CD%

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

CALL %CD%\Engine\Build\BatchFiles\GetMSBuildPath.bat
IF ERRORLEVEL 1 GOTO :error

:testMSBuild
@ECHO Test MSBuild:
%MSBUILD_EXE% -version
IF ERRORLEVEL 1 GOTO :error
    
:done
    @ECHO ON
    @ECHO Neccessary defines tested successfully!
    
    rem POPD %~dp0
    POPD %CD%
    
    EXIT /B 0

:error
    @ECHO ON
    @ECHO Error: failed to test defines

    rem POPD %~dp0
    POPD %CD%
    
    EXIT /B 1