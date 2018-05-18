rem @ECHO OFF
SETLOCAL

IF NOT DEFINED UE_VERSION (
    @ECHO Error: UE_VERSION variable undefined!
    GOTO :error
)

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

SET DeployHome=Deploy
SET Configuration=Development
SET Platform=Win64

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

    MKDIR %DeployHome%\Prerequirements\%UE_VERSION%
    IF ERRORLEVEL 1 GOTO :error
)

@ECHO Copy prerequirements
ROBOCOPY %CD%\%UnrealHome%\Engine\Extras\Redist\en-us\ %CD%\Deploy\Prerequirements\%UE_VERSION% /E
IF ERRORLEVEL 1 (
    COLOR 4
    @ECHO Todo: investigate why robocopy returns error
    rem GOTO :error
)
COLOR

@ECHO Copy scene to deploy folder
IF NOT DEFINED AMF_VERSION (
    ROBOCOPY "%CD%\TestsProjects\%UE_VERSION%\PlaneStandard\Saved\StagedBuilds\WindowsNoEditor" "%CD%\Deploy\Tests\PlaneStandard_%UE_VERSION%_%Configuration%_%Platform%" /E /xf *.pdb /xf *.txt
    IF ERRORLEVEL 1 (
        @ECHO Todo: investigate why robocopy returns error
        rem GOTO :error
    )

    @ECHO Create video folder for first sample
    MKDIR "%CD%\Deploy\Tests\PlaneStandard_%UE_VERSION%_%Configuration%_%Platform%\PlaneStandard\Content\Video
    IF ERRORLEVEL 1 GOTO :error
    
    @ECHO Copy sample 4K video file
    COPY "%CD%\TestsProjects\%UE_VERSION%\PlaneStandard\Content\Video\1.mp4" "%CD%\Deploy\Tests\PlaneStandard_%UE_VERSION%_%Configuration%_%Platform%\PlaneStandard\Content\Video\1.mp4"
    IF ERRORLEVEL 1 GOTO :error

) ELSE (
    ROBOCOPY "%CD%\TestsProjects\%UE_VERSION%\PlaneAmf\Saved\StagedBuilds\WindowsNoEditor" "%CD%\Deploy\Tests\PlaneAmf_%UE_VERSION%_%Configuration%_%Platform%" /E /xf *.pdb /xf *.txt
    IF ERRORLEVEL 1 (
        @ECHO Todo: investigate why robocopy returns error
        rem GOTO :error
    )

    @ECHO Create video folder for first sample
    MKDIR "%CD%\Deploy\Tests\PlaneAmf_%UE_VERSION%_%Configuration%_%Platform%\PlaneStandard\Content\Video
    IF ERRORLEVEL 1 GOTO :error

    @ECHO Copy sample 4K video file
    COPY "%CD%\TestsProjects\%UE_VERSION%\PlaneStandard\Content\Video\1.mp4" "%CD%\Deploy\Tests\PlaneStandard_%UE_VERSION%_%Configuration%_%Platform%\PlaneStandard\Content\Video\1.mp4"
    IF ERRORLEVEL 1 GOTO :error
)

:done
    @ECHO Scene deployed successfully
    EXIT /B 0

:error
    @ECHO Error: failed deploy scene
    EXIT /B 1