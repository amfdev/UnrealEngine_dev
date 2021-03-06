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

IF /I ["%SceneSourceType%"] == ["BluePrints"] (
    @ECHO Deploy blueprints scene

    SET SceneProjectName=%SceneName%

) ELSE IF /I ["%SceneSourceType%"] == ["CPP"] (
    @ECHO Deploy C++ scene

    SET SceneProjectName=%SceneName%Cpp

) ELSE (
    @ECHO Error: unsupported scene source type: %SceneSourceType%!
    GOTO :error\
)

SET SceneProjectOutputName=!SceneProjectName!_%Configuration%

IF DEFINED Build_VulkanVersion (
    SET SceneProjectOutputName=!SceneProjectName!_%Configuration%_Vulkan
)

@ECHO Project name to deploy: !SceneProjectName!
@ECHO Scene project output name: %SceneProjectOutputName%

IF NOT EXIST "%DeployHome%" (
    @ECHO Create deploy folder
    MKDIR %DeployHome%
    IF ERRORLEVEL 1 GOTO :error
)

IF NOT EXIST "%DeployHome%\Tests" (
    @ECHO Create tests folder

    MKDIR %DeployHome%\Tests
    IF ERRORLEVEL 1 GOTO :error
)

IF NOT EXIST "%DeployHome%\Media" (
    @ECHO Create media folder

    MKDIR %DeployHome%\Media
    IF ERRORLEVEL 1 GOTO :error
)

IF NOT EXIST "%DeployHome%\Tests\%UE_VERSION%" (
    @ECHO Create engine version folder

    MKDIR %DeployHome%\Tests\%UE_VERSION%
    IF ERRORLEVEL 1 GOTO :error
)

IF EXIST "%DeployHome%\Tests\%UE_VERSION%\%SceneProjectOutputName%" (
    @ECHO Delete old %SceneProjectOutputName% folder

    RD /S /Q %DeployHome%\Tests\%UE_VERSION%\%SceneProjectOutputName%
    IF ERRORLEVEL 1 GOTO :error
)

@ECHO Create deploy folder for %SceneProjectOutputName%
MKDIR %DeployHome%\Tests\%UE_VERSION%\%SceneProjectOutputName%
IF ERRORLEVEL 1 GOTO :error

IF EXIST "%CD%\TestsProjects\Media" (
    @ECHO Copy shared video files

    ROBOCOPY "%CD%\TestsProjects\Media" "%CD%\Deploy\Media" /xf *.bat
    IF ERRORLEVEL 1 (
        @ECHO Todo: investigate why robocopy returns error
        rem GOTO :error
    )
)

@ECHO Copy scene to deploy folder
ROBOCOPY %CD%\TestsProjects\%UE_VERSION%\!SceneProjectName!\Saved\StagedBuilds\WindowsNoEditor %CD%\Deploy\Tests\%UE_VERSION%\%SceneProjectOutputName% /E /xf *.pdb /xf *.txt
IF ERRORLEVEL 1 (
    @ECHO Todo: investigate why robocopy returns error
    rem GOTO :error
)

IF ["%SceneName%"] == ["MediaTestAmf"] (
    @ECHO Copy MediaTest predefined bat files

    IF NOT DEFINED Build_VulkanVersion (
        ROBOCOPY "%CD%\TestsProjects\Media" %CD%\Deploy\Tests\%UE_VERSION%\%SceneProjectOutputName% *.bat /xf *Vulkan*
    ) ELSE (
        ROBOCOPY "%CD%\TestsProjects\Media" %CD%\Deploy\Tests\%UE_VERSION%\%SceneProjectOutputName% *.bat
    )


    IF ERRORLEVEL 1 (
        @ECHO Todo: investigate why robocopy returns error
        rem GOTO :error
    )

    IF DEFINED Build_VulkanVersion (
        @ECHO Install AMF media dll
        COPY "%UnrealHome%\Engine\Binaries\Thirdparty\AMD\amf\Win64\AmfMediaFactoryHelper.dll" %CD%\Deploy\Tests\%UE_VERSION%\%SceneProjectOutputName%
    )
)

:done
    @ECHO Scene deployed successfully
    EXIT /B 0

:error
    @ECHO Error: failed deploy scene!
    EXIT /B 1