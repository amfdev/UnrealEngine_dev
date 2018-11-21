@SET Verbose=OFF
@ECHO %Verbose%

CALL Scripts\UtilityTestDefines.bat
IF ERRORLEVEL 1 GOTO :error

SETLOCAL EnableDelayedExpansion
IF ERRORLEVEL 1 GOTO :error

SET Build_4_17=
SET Build_4_18=
SET Build_4_19=
SET Build_4_20=
SET Build_4_21=
SET Build_2015=
SET Build_2017=
SET Build_Amf=
SET Build_Standard=
SET Build_Stitch=
SET Build_Development=
SET Build_Shipping=
SET Build_BluePrints=
SET Build_CPP=
SET Build_MediaTest=
SET Build_Engine=
SET Build_Tests=
SET Build_Dirty=
SET Build_Clean=
SET Build_CleanOnly=
SET Build_GenerateSolutionOnly=
SET Build_SourceOrigin=
SET Build_SourceClone=
SET Build_SourcePatch=
SET Build_Minimal=
SET Build_Verbose=

SET Command_AmfBranch=
SET Param_AmfBranch=
SET Command_StitchBranch=
SET Param_StitchBranch=

SET Command_GitLogin=
SET Param_GitLogin=
SET Command_GitPassword=
SET Param_GitPassword=

FOR %%x IN (%*) DO (
    IF DEFINED Command_AmfBranch (
        SET Param_AmfBranch=%%~x
        SET Command_AmfBranch=
    ) ELSE IF DEFINED Command_StitchBranch (
        SET Param_StitchBranch=%%~x
        SET Command_StitchBranch=
    ) ELSE IF DEFINED Command_GitLogin (
        SET Param_GitLogin=%%~x
        SET Command_GitLogin=
    ) ELSE IF DEFINED Command_GitPassword (
        SET Param_GitPassword=%%~x
        SET Command_GitPassword=
    ) ELSE IF /I "%%~x"=="4.17" (
        SET Build_4_17=1
    ) ELSE IF /I "%%~x"=="4.18" (
        SET Build_4_18=1
    ) ELSE IF /I "%%~x"=="4.19" (
        SET Build_4_19=1
    ) ELSE IF /I "%%~x"=="4.20" (
        SET Build_4_20=1
    ) ELSE IF /I "%%~x"=="4.21" (
        SET Build_4_21=1
    ) ELSE IF /I "%%~x"=="2015" (
        SET Build_2015=1
    ) ELSE IF /I "%%~x"=="2017" (
        SET Build_2017=1
    ) ELSE IF /I "%%~x"=="Amf" (
        SET Build_Amf=1
    ) ELSE IF /I "%%~x"=="Stitch" (
        SET Build_Stitch=1
    ) ELSE IF /I "%%~x"=="Standard" (
        SET Build_Standard=1
    ) ELSE IF /I "%%~x"=="Development" (
        SET Build_Development=1
    ) ELSE IF /I "%%~x"=="Shipping" (
        SET Build_Shipping=1
    ) ELSE IF /I "%%~x"=="BluePrints" (
        SET Build_BluePrints=1
        SET Build_Tests=1
    ) ELSE IF /I "%%~x"=="CPP" (
        SET Build_CPP=1
        SET Build_Tests=1
    ) ELSE IF /I "%%~x"=="MediaTest" (
        SET Build_Tests=1
        SET Build_MediaTest=1
    ) ELSE IF /I "%%~x"=="Engine" (
        SET Build_Engine=1
    ) ELSE IF /I "%%~x"=="Tests" (
        SET Build_Tests=1
    ) ELSE IF /I "%%~x"=="Dirty" (
        SET Build_Dirty=1
    ) ELSE IF /I "%%~x"=="Clean" (
        SET Build_Clean=1
    ) ELSE IF /I "%%~x"=="CleanOnly" (
        SET Build_CleanOnly=1
    ) ELSE IF /I "%%~x"=="GenerateOnly" (
        SET Build_GenerateSolutionOnly=1
    ) ELSE IF /I "%%~x"=="Origin" (
        SET Build_SourceOrigin=1
    ) ELSE IF /I "%%~x"=="Clone" (
        SET Build_SourceClone=1
    ) ELSE IF /I "%%~x"=="SourcePatch" (
        SET Build_SourcePatch=1
    ) ELSE IF /I "%%~x"=="AmfBranch:" (

        IF DEFINED Command_AmfBranch (
            @ECHO Error: amf branch parameter already specified!
        ) ELSE (
            SET Command_AmfBranch=1
        )

    ) ELSE IF /I "%%~x"=="StitchBranch:" (

        IF DEFINED Command_StitchBranch (
            @ECHO Error: stitch branch parameter already specified!
        ) ELSE (
            SET Command_StitchBranch=1
        )

    ) ELSE IF /I "%%~x"=="GitLogin:" (

        IF DEFINED Command_StitchBranch (
            @ECHO Error: stitch branch parameter already specified!
        ) ELSE (
            SET Command_StitchBranch=1
        )

    ) ELSE IF /I "%%~x"=="StitchBranch:" (

        IF DEFINED Command_StitchBranch (
            @ECHO Error: stitch branch parameter already specified!
        ) ELSE (
            SET Command_StitchBranch=1
        )

    ) ELSE IF /I "%%~x"=="Minimal" (
        SET Build_Minimal=1
    ) ELSE IF /I "%%~x"=="Verbose" (
        SET Build_Verbose=1
    ) ELSE IF /I "%%~x"=="Help" (
        GOTO :usage
    ) ELSE (
        @ECHO Error: unsupported option: %%~x!
        GOTO :usage
    )
)

IF DEFINED Build_Verbose (
    SET Verbose=ON
) ELSE (
    SET Verbose=OFF
)

@ECHO %Verbose%

IF NOT DEFINED Build_4_17 IF NOT DEFINED Build_4_18 IF NOT DEFINED Build_4_19 IF NOT DEFINED Build_4_20 IF NOT DEFINED Build_4_21 (
    @ECHO No UnrealEngine version specified, 4.17, 4.18, 4.19, 4.20, 4.21 will be added
    SET Build_4_17=1
    SET Build_4_18=1
    SET Build_4_19=1
    SET Build_4_20=1
    SET Build_4_21=1
)

IF NOT DEFINED Build_2015 IF NOT DEFINED Build_2017 (
    @ECHO No Visual Studio version specified, 2015 will be added
    REM @ECHO No Visual Studio version specified, 2015 and 2017 will be added
    SET Build_2015=1
    REM SET Build_2017=1
)

IF NOT DEFINED Build_Standard IF NOT DEFINED Build_Amf IF NOT DEFINED Build_Stitch (
    @ECHO No rendering type specified by args

    REM SET Build_Standard=1
    SET Build_Amf=1

    IF NOT DEFINED Build_MediaTest (
        SET Build_Stitch=1
    )
)

IF NOT DEFINED Build_Development IF NOT DEFINED Build_Shipping (
    @ECHO No configuration specified by args, Development and Shipping will be added
    SET Build_Development=1
    SET Build_Shipping=1
)

IF NOT DEFINED Build_BluePrints IF NOT DEFINED Build_CPP IF DEFINED Build_Tests (
    rem @ECHO No tests type are specified by args, only blueprints will be built
    @ECHO No tests type are specified by args, blueprints and c++ tests will be included
    SET Build_BluePrints=1
    SET Build_CPP=1
)

IF NOT DEFINED Build_Dirty IF NOT DEFINED Build_Clean (
    @ECHO No rebuilding flags specified, clean build will be used
    SET Build_Clean=1
)

IF NOT DEFINED Build_Engine IF NOT DEFINED Build_Tests (
    SET Build_Engine=1

    rem IF NOT DEFINED Build_Standard (
        @ECHO Not engine or tests are defined, both engine and tests will be built
        SET Build_Tests=1
        SET Build_BluePrints=1
        SET Build_CPP=1
    rem )
)

IF DEFINED Build_Tests (
    IF NOT DEFINED Build_MediaTest (
        IF DEFINED Build_Amf (
            SET Build_MediaTest=1
        )
    )
)

IF NOT DEFINED Build_Standard IF NOT DEFINED Build_MediaTest IF NOT DEFINED Build_Stitch IF DEFINED Build_Tests (
    SET Build_MediaTest=1

    REM SET Build_Stitch=1
)

IF NOT DEFINED Build_SourceOrigin IF NOT DEFINED Build_SourceClone (
    IF DEFINED Build_Amf (
        SET Build_SourceClone=1
    ) ELSE IF DEFINED Build_Stitch (
        SET Build_SourceClone=1
    )
)

@ECHO:
SET Build_4_17
SET Build_4_18
SET Build_4_19
SET Build_4_20
SET Build_4_21
SET Build_2015
SET Build_2017
SET Build_Amf
SET Build_Standard
SET Build_Stitch
SET Build_Development
SET Build_Shipping
SET Build_BluePrints
SET Build_CPP
SET Build_MediaTest
SET Build_Engine
SET Build_Tests
SET Build_Dirty
SET Build_Clean
SET Build_CleanOnly
SET Build_GenerateSolutionOnly
SET Build_SourceOrigin
SET Build_SourceClone
SET Build_SourcePatch
SET Build_Minimal
SET Build_Verbose
SET Param_AmfBranch
SET Param_StitchBranch

REM EXIT /B 0

@ECHO:

CALL :fillDateTimeVariables CurrentYear CurrentMonth CurrentDay CurrentHour CurrentMinute CurrentSecond
rem @ECHO %CurrentYear%/%CurrentMonth%/%CurrentDay%
rem @ECHO %CurrentHour%:%CurrentMinute%:%CurrentSecond%

SET LogFolderName=Logs\Build_%CurrentYear%_%CurrentMonth%_%CurrentDay%__%CurrentHour%_%CurrentMinute%_%CurrentSecond%
SET ResultsFileName=%LogFolderName%\results.csv

@ECHO Prepare log folder
IF NOT EXIST Logs (
    MKDIR Logs
    IF ERRORLEVEL 1 GOTO :error
)
IF NOT EXIST %LogFolderName% (
    MKDIR %LogFolderName%
    IF ERRORLEVEL 1 GOTO :error
)

@ECHO project_name,start_date,start_time,end_date,end_time,result>>"%ResultsFileName%""

FOR %%s IN (2015, 2017) DO (
    SET SkipVisualStudio=

    IF /I ["%%s"] == ["2015"] IF NOT DEFINED Build_2015 SET SkipVisualStudio=1
    IF /I ["%%s"] == ["2017"] IF NOT DEFINED Build_2017 SET SkipVisualStudio=1
    REM Skip building vs2017 samples if they were already built in the previous cycle
    IF /I ["%%s"] == ["2017"] IF NOT DEFINED Build_Engine IF DEFINED Build_2015 SET SkipVisualStudio=1

    IF NOT DEFINED SkipVisualStudio (
        SET VS_VERSION=%%s

        FOR %%v IN (17, 18, 19, 20, 21) DO (

            IF DEFINED Build_4_%%v (
                CALL :runBuildHelper 4.%%v
                )
        )
    )
)

:done
    @ECHO:
    @ECHO Work of build system finished
    EXIT /B 0

:usage
    @ECHO:
    @ECHO Build.bat [Command1] [Command2] [Command3] ...
    @ECHO:
    @ECHO Available commands:
    @ECHO     Engine - build Unreal Engine
    @ECHO     Tests - build tests
    @ECHO     4.17 4.18 4.19 4.20 4.21 - specify Unreal Engine version
    @ECHO     2015 2017 - specify Visual Studio version
    @ECHO     Standard - build Unreal Engine and related tests with standard media playback
    @ECHO     Amf - build Unreal Engine and related tests with accelerated AMF media playback
    @ECHO     Stitch - build Unreal Engine and related tests with stitch media playback
    @ECHO     Development - Unreal Engine and related tests with development configuration
    @ECHO     Shipping - Unreal Engine and related tests with shipping configuration
    @ECHO     BluePrints - build blueprints variant of the related tests
    @ECHO     CPP - build c++ variant of the related tests
    @ECHO     MediaTest - specify name of the test for standard and amf configuration
    @ECHO     Clean - clean up Unreal Engine and plugin repository before build
    @ECHO     Dirty - don't clean Unreal Engine and plugin repository before build
    @ECHO     Origin - take plugin from https://github.com/GPUOpenSoftware/UnrealEngine.git
    @ECHO     Clone - take plugin from https://github.com/amfdev/UnrealEngine_AMF
    @ECHO     SourcePatch - use test repository, download branch, then patch it with our patches
    @ECHO                   Attention: not-patched plugin will be used if this command is not set!
    @ECHO     AmfBranch: branch_name - download specified branch of AMF plugin
    @ECHO     StitchBranch: branch_name - download specified branch of Stitch plugin
    @ECHO     Verbose - show extended information
    @ECHO     Help - show this help

    EXIT /B 0

:error
    @ECHO:
    @ECHO Error: Work of build system failed!

    EXIT /B 1

:runBuildHelper unreal_number
    IF DEFINED Build_Standard (
        IF DEFINED Build_Development (
            CALL :runBuildProcess %~1 Development Standard
        )

        IF DEFINED Build_Shipping (
            CALL :runBuildProcess %~1 Shipping Standard
        )
    )

    IF DEFINED Build_Amf (
        IF DEFINED Build_Development (
            CALL :runBuildProcess %~1 Development Amf
        )

        IF DEFINED Build_Shipping (
            CALL :runBuildProcess %~1 Shipping Amf
        )
    )

    IF DEFINED Build_Stitch (
        IF NOT ["%~1"] == ["4.17"] (
            IF DEFINED Build_Development (
                CALL :runBuildProcess %~1 Development Stitch
            )

            IF DEFINED Build_Shipping (
                CALL :runBuildProcess %~1 Shipping Stitch
            )
        )
    )

    EXIT /B 0

:runBuildProcess unreal_number configuration renderType
    SET UE_VERSION=%~1
    SET AMF_VERSION=
    SET STITCH_VERSION=

    SET renderTypePrintable=%~3

    IF ["%~3"] == ["Standard"] (
        REM default values
    ) ELSE IF ["%~3"] == ["Amf"] (
        SET AMF_VERSION=!UE_VERSION!
    ) ELSE IF ["%~3"] == ["Stitch"] (
        SET STITCH_VERSION=!UE_VERSION!
    ) ELSE (
        @ECHO Error! unsupported renderType
        EXIT /B 1
    )

    IF ["%~2"] == ["Development"] (
        SET UnrealConfiguration=Development Editor
        SET SceneConfiguration=Development
    ) ELSE IF ["%~2"] == ["Shipping"] (
        SET UnrealConfiguration=Shipping
        SET SceneConfiguration=Shipping
    ) ELSE (
        REM Must be failed later
        SET UnrealConfiguration=
        SET SceneConfiguration=
    )

    SET UnrealConfigurationPrintableName=UnrealEngine_%UE_VERSION%_%UnrealConfiguration%_%renderTypePrintable%_%VS_VERSION%
    SET UnrealBuildLogFile=%CD%\%LogFolderName%\%UnrealConfigurationPrintableName%.log
    SET returnCode=0
    SET buildResult=""

    CALL :fillDateTimeVariables startYear startMonth startDay startHour startMinute startSecond

    @ECHO:

    IF DEFINED Build_Engine (

        @ECHO Build unreal engine configuration
        @ECHO Configuration name: !UnrealConfigurationPrintableName!
        @ECHO Log file: !UnrealBuildLogFile!

        SET CleanFirst=!Build_Clean!!Build_CleanOnly!

        IF DEFINED CleanFirst (
            CALL Scripts\CleanImplementation.bat

            IF ERRORLEVEL 1 (
                @ECHO Clean for configuration "!UnrealConfigurationPrintableName!" finished with errors
                SET buildResult=failed
            ) ELSE (
                @ECHO Clean for configuration "!UnrealConfigurationPrintableName!" finished successfully
                SET buildResult=succeeded
            )
        )

        IF DEFINED Build_Engine IF /I NOT ["failed"] == ["%buildResult%"] (
            CALL Scripts\BuildUnrealImplementation.bat

            IF ERRORLEVEL 1 (
                @ECHO Build for configuration "!UnrealConfigurationPrintableName!" finished with errors
                SET buildResult=failed
            ) ELSE (
                @ECHO Build for configuration "!UnrealConfigurationPrintableName!" finished successfully
                SET buildResult=succeeded
            )
        )
    )

    CALL :fillDateTimeVariables endYear endMonth endDay endHour endMinute endSecond

    IF DEFINED Build_Engine (
        @ECHO ,,,,,>>"%ResultsFileName%"
        @ECHO %UnrealConfigurationPrintableName%,%startYear%/%startMonth%/%startDay%,%startHour%:%startMinute%:%startSecond%,%endYear%/%endMonth%/%endDay%,%endHour%:%endMinute%:%endSecond%,%buildResult%>>"%ResultsFileName%"
    )

    IF DEFINED Build_Tests (
        CALL :runSceneBuilder %~1 %~2 %~3
    )

    EXIT /B 0

:runSceneBuilder unreal_number configuration renderType
    SET SceneConfigurationPrintableName=

    FOR %%s IN (Blueprints, CPP) DO (

        SET SkipSourceType=
        IF ["%%s"] == ["Blueprints"] IF NOT DEFINED Build_BluePrints SET SkipSourceType=1
        IF ["%%s"] == ["CPP"] IF NOT DEFINED Build_CPP SET SkipSourceType=1

        IF NOT DEFINED SkipSourceType (

            IF /I ["%~3"] == ["Stitch"] (

                IF /I ["%%s"] == ["Blueprints"] (

                    SET SceneName=StitchAmf
                    SET SceneSourceType=%%s
                    SET SceneConfigurationPrintableName=!UE_VERSION!_!SceneConfiguration!_!SceneName!_!SceneSourceType!
                    SET SceneBuildLogFile=!CD!\!LogFolderName!\!SceneConfigurationPrintableName!.log

                    CALL :buildScene
                )
            ) ELSE (

                FOR %%t IN (MediaTest) DO (

                    SET SkipTestType=
                    IF /I ["%%t"] == ["MediaTest"] IF NOT DEFINED Build_MediaTest SET SkipTestType=1

                    IF /I ["%%t"] == ["MediaTest"] IF /I ["%~3"] == ["Standard"] SET SkipTestType=1
                    IF /I ["%%t"] == ["MediaTest"]  IF /I ["%%s"] == ["Blueprints"] SET SkipTestType=1

                    IF NOT DEFINED SkipTestType (
                        SET SceneName=%%t%~3
                        SET SceneSourceType=%%s
                        SET SceneConfigurationPrintableName=!UE_VERSION!_!SceneConfiguration!_!SceneName!_!SceneSourceType!
                        SET SceneBuildLogFile=!CD!\!LogFolderName!\!SceneConfigurationPrintableName!.log

                        CALL :buildScene
                    )
                )
            )
        )
    )

    EXIT /B 0

:buildScene
    @ECHO:
    @ECHO SceneName: %SceneName%
    @ECHO SceneConfiguration: %SceneConfiguration%
    @ECHO SceneConfigurationPrintableName: %SceneConfigurationPrintableName%
    @ECHO SceneSourceType: %SceneSourceType%
    @ECHO ResultsFileName: %ResultsFileName%
    @ECHO SceneBuildLogFile: %SceneBuildLogFile%
    @ECHO VisualStudio version: %VS_VERSION%

    SET returnCode=0
    SET buildResult=""

    CALL :fillDateTimeVariables startYear startMonth startDay startHour startMinute startSecond
    CALL Scripts\BuildSceneImplementation.bat

    IF ERRORLEVEL 1 (
        @ECHO Error: failed to build scene %SceneConfigurationPrintableName%!
        SET returnCode=1
    ) ELSE (
        @ECHO Scene %SceneConfigurationPrintableName% built successfully!
        SET returnCode=0
    )

    CALL :fillDateTimeVariables endYear endMonth endDay endHour endMinute endSecond

    iF "%returnCode%" == "1" (
        SET buildResult=failed
    ) ELSE (
        SET buildResult=succeeded
    )

    @ECHO !SceneConfigurationPrintableName!,!startYear!/!startMonth!/!startDay!,!startHour!:!startMinute!:!startSecond!,!endYear!/!endMonth!/!endDay!,!endHour!:!endMinute!:!endSecond!,!buildResult!>>"!ResultsFileName!"

    EXIT /B 0

:fillDateTimeVariables yy mm dd hour minute second [/A]
    @ECHO OFF

    SETLOCAL ENABLEEXTENSIONS

    IF "%date%A" LSS "A" (SET toks=1-3) ELSE (SET toks=2-4)

    FOR /f "tokens=2-4 delims=(-)" %%a IN ('echo:^|date') DO (
        FOR /f "tokens=%toks% delims=.-/ " %%i IN ('date/t') DO (
            SET '%%a'=%%i
            SET '%%b'=%%j
            SET '%%c'=%%k
        )
    )

    IF /I "%'yy'%"=="" SET "'yy'=%'aa'%"
    IF /I "%'yy'%"=="" ( SET "'yy'=%'jj'%" & SET "'dd'=%'tt'%" )
    IF %'yy'% LSS 100 SET 'yy'=20%'yy'%
    ENDLOCAL&SET %1=%'yy'%&SET %7 %2=%'mm'%&SET %7 %3=%'dd'%

    SET currentTimeValue=%TIME%
    IF "%currentTimeValue:~0,1%" == " " (SET currentTimeValue=0%currentTimeValue:~1,7%)

    SET %4=%currentTimeValue:~0,2%
    SET %5=%currentTimeValue:~3,2%
    SET %6=%currentTimeValue:~6,2%

    @ECHO %Verbose%

    EXIT /B 0