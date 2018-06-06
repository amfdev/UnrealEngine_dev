@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED PROJECT_FOLDER (
    @ECHO Error: PROJECT_FOLDER variable undefined!
    GOTO :error
)

IF NOT DEFINED PROJECT_SOLUTION (
    @ECHO Error: PROJECT_SOLUTION variable undefined!
    GOTO :error
)

CALL Scripts\UtilitySetupMSBuildExe.bat
IF ERRORLEVEL 1 GOTO :error

CD %PROJECT_FOLDER%
IF ERRORLEVEL 1 GOTO :error

SET target=build
SET maxcpucount=/maxcpucount 
SET configuration=Release
SET platform=x64

%MSBUILD_EXE% /target:%target% %maxcpucount% /property:Configuration=%configuration%;Platform=%platform% %parameters% %PROJECT_SOLUTION%
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Solution %PROJECT_FOLDER%\%PROJECT_SOLUTION% built successfully
    EXIT /B 0

:error
    @ECHO Error: failed to build solution %PROJECT_FOLDER%\%PROJECT_SOLUTION%
    EXIT /B 1