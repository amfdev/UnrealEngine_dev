@ECHO OFF
SETLOCAL

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

SET DeployHome=Deploy

IF EXIST "%DeployHome%" (
    @ECHO Found deploy directory, clean it
    
    RD /S /Q %DeployHome%\Tests
    IF ERRORLEVEL 1 GOTO :error

    RD /S /Q %DeployHome%\Prerequirements
    IF ERRORLEVEL 1 GOTO :error
) ELSE (
    @ECHO Create deploy folders
    
    MKDIR %DeployHome%
    IF ERRORLEVEL 1 GOTO :error
)

@ECHO Copy prerequirements
ROBOCOPY %CD%\%UnrealHome%\Engine\Extras\Redist\en-us\ %CD%\Deploy\Prerequirements /E
IF ERRORLEVEL 1 (
    COLOR 4
    @ECHO Todo: investigate why robocopy returns error
    rem GOTO :error
)
COLOR

@ECHO Copy scene to deploy folder
ROBOCOPY "%CD%\TestsProjects\PlainScreen\Saved\StagedBuilds\WindowsNoEditor" "%CD%\Deploy\Tests\PlainScreen" /E /xf *.pdb /xf *.txt
IF ERRORLEVEL 1 (
    COLOR 4
    @ECHO Todo: investigate why robocopy returns error
    rem GOTO :error
)
COLOR

@ECHO Create video folder for first sample
MKDIR "%CD%\Deploy\Tests\PlainScreen\PlainScreen\Content\Video

@ECHO Copy sample 4K video file
COPY "%CD%\TestsProjects\PlainScreen\Content\Video\1.mp4" "%CD%\Deploy\Tests\PlainScreen\PlainScreen\Content\Video\1.mp4"
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Scene deployed successfully
    EXIT /B 0

:error
    @ECHO Error: failed deploy scene
    EXIT /B 1