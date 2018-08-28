@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED PLUGIN_FOLDER (
    @ECHO Error: PLUGIN_FOLDER variable undefined!
    GOTO :error
)

IF NOT DEFINED PLUGIN_SOLUTION (
    @ECHO Error: PLUGIN_SOLUTION variable undefined!
    GOTO :error
)

CALL Scripts\UtilitySetupMSBuildExe.bat
IF ERRORLEVEL 1 GOTO :error

CD %PLUGIN_FOLDER%
IF ERRORLEVEL 1 GOTO :error

SET target=build
SET maxcpucount=/maxcpucount
SET configuration=Release
SET platform=x64

REM %MSBUILD_EXE% /target:%target% %maxcpucount% /property:Configuration=%configuration%;Platform=%platform% %parameters% %PLUGIN_SOLUTION%
%MSBUILD_EXE% /target:%target% %maxcpucount% /property:Configuration=%configuration%;Platform=%platform% %PLUGIN_SOLUTION%
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Solution %PLUGIN_FOLDER%\%PLUGIN_SOLUTION% built successfully
    EXIT /B 0

:error
    @ECHO Error: failed to build solution %PLUGIN_FOLDER%\%PLUGIN_SOLUTION%
    EXIT /B 1