rem @ECHO OFF
SETLOCAL

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

SET DeployHome=Deploy

IF EXIST "%DeployHome%" (
    @ECHO Found deploy directory, clean it
    
    RD /S /Q %DeployHome/Tests
    RD /S /Q %DeployHome/Prerequirements
    IF ERRORLEVEL 1 GOTO :error
) ELSE (
    @ECHO Create deploy folders
    
    MKDIR %DeployHome%
    MKDIR %DeployHome%\Prerequirements
    IF ERRORLEVEL 1 GOTO :error
)

@ECHO Copy prerequirements
ROBOCOPY %CD%\%UnrealHome%\Engine\Extras\Redist\en-us\ %CD%\Deploy\Prerequirements /E
@ECHO Todo: investigate why robocopy returns error
rem IF ERRORLEVEL 1 GOTO :error

@ECHO Copy scene to deploy folder
ROBOCOPY "%CD%\TestsProjects\FPSProject\Saved\StagedBuilds\WindowsNoEditor" "%CD%\Deploy\Tests\FPSProject" /E
@ECHO Todo: investigate why robocopy returns error
rem IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Scene deployed successfully
    EXIT /B 0

:error
    @ECHO Error: failed deploy scene
    EXIT /B 1