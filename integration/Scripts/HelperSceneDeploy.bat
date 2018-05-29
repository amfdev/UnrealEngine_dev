@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
)

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

IF NOT DEFINED SceneConfiguration (
    @ECHO Error: SceneConfiguration variable undefined!
    GOTO :error
)

IF NOT DEFINED SceneSourceType (
    @ECHO Error: SceneSourceType variable undefined!
    GOTO :error
)

SET DeployHome=Deploy
SET Configuration=%SceneConfiguration%
SET Platform=Win64

IF NOT DEFINED AMF_VERSION (
    SET PlaneProjectName=PlaneStandard
) ELSE (
    SET PlaneProjectName=PlaneAmf
)

IF /I ["%SceneSourceType%"] == ["BluePrints"] (
    @ECHO Deploy blueprints scene
) ELSE IF /I ["%SceneSourceType%"] == ["CPP"] (
    @ECHO Deploy C++ scene
    SET PlaneProjectName=%PlaneProjectName%Cpp
) ELSE (
    @ECHO Error: unsupported scene source type!
    GOTO :error
)

@ECHO Plane project name: %PlaneProjectName%

SET PlaneProjectOutputName=%PlaneProjectName%_%UE_VERSION%_%Configuration%_%Platform%
@ECHO Plane project output name: %PlaneProjectOutputName%

IF NOT EXIST "%DeployHome%" (
    @ECHO Create deploy home folder
    MKDIR %DeployHome%
    IF ERRORLEVEL 1 GOTO :error
)

IF NOT EXIST "%DeployHome%\Tests" (
    @ECHO Create tests folder

    MKDIR %DeployHome%\Tests
    IF ERRORLEVEL 1 GOTO :error
)

IF EXIST "%DeployHome%\Tests\%PlaneProjectOutputName%" (
    @ECHO Delete old %PlaneProjectOutputName% folder
    
    RD /S /Q %DeployHome%\Tests\%PlaneProjectOutputName%
    IF ERRORLEVEL 1 GOTO :error
)

@ECHO Create deploy folder for %PlaneProjectOutputName%
MKDIR %DeployHome%\Tests\%PlaneProjectOutputName%
IF ERRORLEVEL 1 GOTO :error

@ECHO Create folder for video file
MKDIR "%CD%\Deploy\Tests\%PlaneProjectOutputName%\%PlaneProjectName%\Content\Video
IF ERRORLEVEL 1 GOTO :error

@ECHO Copy scene to deploy folder
ROBOCOPY "%CD%\TestsProjects\%UE_VERSION%\%PlaneProjectName%\Saved\StagedBuilds\WindowsNoEditor" "%CD%\Deploy\Tests\%PlaneProjectOutputName%" /E /xf *.pdb /xf *.txt
IF ERRORLEVEL 1 (
    @ECHO Todo: investigate why robocopy returns error
    rem GOTO :error
)

@ECHO Copy sample 4K video file
COPY "%CD%\TestsProjects\%UE_VERSION%\%PlaneProjectName%\Content\Video\1.mp4" "%CD%\Deploy\Tests\%PlaneProjectOutputName%\%PlaneProjectName%\Content\Video\1.mp4"
IF ERRORLEVEL 1 GOTO :error

:done
    @ECHO Scene deployed successfully
    EXIT /B 0

:error
    @ECHO Error: failed deploy scene
    EXIT /B 1