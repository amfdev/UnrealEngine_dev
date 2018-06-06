@SET Verbose=OFF
@ECHO %Verbose%

CALL Scripts\UtilityTestDefines.bat
IF ERRORLEVEL 1 GOTO :error

SET Build_4_17=
SET Build_4_18=
SET Build_4_19=
SET Build_Amf=
SET Build_Standard=
SET Build_Stitch=
SET Build_Development=
SET Build_Shipping=
SET Build_BluePrints=
SET Build_CPP=
SET Build_Engine=
SET Build_Tests=
SET Build_Dirty=
SET Build_Clean=
SET Build_Verbose=

SET Params=
SET ParamsEngine=
SET ParamsScene=

FOR %%x IN (%*) DO (
   IF /i "%%~x"=="4.17" (
        SET Build_4_17=1
        SET Params=%Params%A
        SET ParamsEngine=%ParamsEngine%A
    ) ELSE IF /i "%%~x"=="4.18" (
        SET Build_4_18=1
        SET Params=%Params%B
        SET ParamsEngine=%ParamsEngine%B
    ) ELSE IF /i "%%~x"=="4.19" (
        SET Build_4_19=1
        SET Params=%Params%B2
        SET ParamsEngine=%ParamsEngine%B2
    ) ELSE IF /i "%%~x"=="Amf" (
        SET Build_Amf=1
        SET Params=%Params%C
        SET ParamsEngine=%ParamsEngine%C
    ) ELSE IF /i "%%~x"=="Stitch" (
        SET Build_Stitch=1
        SET Params=%Params%C2
        SET ParamsEngine=%ParamsEngine%C2
    ) ELSE IF /i "%%~x"=="Standard" (
        SET Build_Standard=1
        SET Params=%Params%D
        SET ParamsEngine=%ParamsEngine%D
    ) ELSE IF /i "%%~x"=="Development" (
        SET Build_Development=1
        SET Params=%Params%E
        SET ParamsEngine=%ParamsEngine%E
    ) ELSE IF /i "%%~x"=="Shipping" (
        SET Build_Shipping=1
        SET Params=%Params%F
        SET ParamsEngine=%ParamsEngine%F
    ) ELSE IF /i "%%~x"=="BluePrints" (
        SET Build_BluePrints=1
        SET Build_Tests=1
        SET Params=%Params%J
        SET ParamsScene=%ParamsScene%J
    ) ELSE IF /i "%%~x"=="CPP" (
        SET Build_CPP=1
        SET Build_Tests=1
        SET Params=%Params%H
        SET ParamsScene=%ParamsScene%H
    ) ELSE IF /i "%%~x"=="Engine" (
        SET Build_Engine=1
        SET Params=%Params%I
        SET ParamsEngine=%ParamsScene%I
    ) ELSE IF /i "%%~x"=="Tests" (
        SET Build_Tests=1
        SET Params=%Params%J
        SET ParamsScene=%ParamsScene%J
    ) ELSE IF /i "%%~x"=="Dirty" (
        SET Build_Dirty=1
    ) ELSE IF /i "%%~x"=="Clean" (
        SET Build_Clean=1
    ) ELSE IF /i "%%~x"=="Verbose" (
        SET Build_Verbose=1
    ) ELSE IF /i "%%~x"=="Help" (
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

IF NOT DEFINED Build_4_17 IF NOT DEFINED Build_4_18 IF NOT DEFINED Build_4_19 (
    @ECHO No UnrealEngine version specified, 4.17, 4.18, 4.19 will be added
    SET Build_4_17=1
    SET Build_4_18=1
    SET Build_4_19=1
)

IF NOT DEFINED Build_Standard IF NOT DEFINED Build_Amf IF NOT DEFINED Build_Stitch (
    @ECHO No build type specified by args, standard, Amf and Stitch will be added 
    SET Build_Standard=1
    SET Build_Amf=1
    SET Build_Stitch=1
)

IF NOT DEFINED Build_Development IF NOT DEFINED Build_Shipping (
    @ECHO No configuration specified by args, Development and Shipping will be added
    SET Build_Development=1
    SET Build_Shipping=1
)

IF NOT DEFINED Build_BluePrints IF NOT DEFINED Build_CPP IF DEFINED Build_Tests (
    @ECHO No tests type are specified by args, only blueprints will be built
    SET Build_BluePrints=1
    rem SET Build_CPP=1
)

IF NOT DEFINED Build_Dirty IF NOT DEFINED Build_Clean (
    @ECHO No rebuilding flags specified, clean build will be used
    SET Build_Clean=1
)

IF NOT DEFINED Build_Engine IF NOT DEFINED Build_Tests (
    @ECHO Engine and tests will be built
    SET Build_Engine=1
    SET Build_Tests=1
    SET Build_BluePrints=1
    SET Build_CPP=1
)

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

IF DEFINED Build_4_17 (
    CALL :runBuildHelper 4.17
    )

IF DEFINED Build_4_18 (
    CALL :runBuildHelper 4.18
    )

IF DEFINED Build_4_19 (
    CALL :runBuildHelper 4.19
    )

:done
    @ECHO:
    @ECHO Build successfully finished!
    EXIT /B 0

:usage
    @ECHO:
    @ECHO Available commands: Build.bat [Engine] [Tests] [4.17] [4.18] [4.19] [Standard] [Amf] [Development] [Shipping] [BluePrints] [CPP] [Help] [Dirty] [Clean]
    EXIT /B 0

:error
    @ECHO:
    @ECHO Error: build failed!
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
        IF DEFINED Build_Development (
            CALL :runBuildProcess %~1 Development Stitch
        )

        IF DEFINED Build_Shipping (
            CALL :runBuildProcess %~1 Shipping Stitch
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
        SET AMF_VERSION=%~1
    ) ELSE IF ["%~3"] == ["Stitch"] (
        SET STITCH_VERSION=4.18
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
    
    @ECHO:
    
    SET UnrealConfigurationPrintableName=UnrealEngine_%UE_VERSION%_%UnrealConfiguration%_%renderType%
    SET UnrealBuildLogFile=%CD%\%LogFolderName%\%UnrealConfigurationPrintableName%.log
    SET returnCode=0
    SET buildSuccess=""

    CALL :fillDateTimeVariables startYear startMonth startDay startHour startMinute startSecond
    
    IF DEFINED Build_Engine (
        IF DEFINED Build_Clean (
            CALL Scripts\BuildUnrealCleanImplementation.bat
        ) ELSE (
            CALL Scripts\BuildUnrealImplementation.bat
        )
        
        IF ERRORLEVEL 1 (
            @ECHO Error: failed to build "%UnrealConfigurationPrintableName%"
            SET buildSuccess=failed
        ) ELSE (
            @ECHO Build for "%UnrealConfigurationPrintableName%" is done
            SET buildSuccess=succeeded
        )
    )
    
    CALL :fillDateTimeVariables endYear endMonth endDay endHour endMinute endSecond

    IF DEFINED Build_Engine (
        @ECHO %UnrealConfigurationPrintableName%,%startYear%/%startMonth%/%startDay%,%startHour%:%startMinute%:%startSecond%,%endYear%/%endMonth%/%endDay%,%endHour%:%endMinute%:%endSecond%,%buildSuccess%>>"%ResultsFileName%"
    )

    SET SceneSourceType=
    SET SceneConfigurationPrintableName=
    SET SceneName=

    IF "%~3" == "Standard" (
        SET SceneName=PlaneStandard
    ) ELSE IF "%~3" == "Amf" (
        SET SceneName=PlaneAmf
    ) ELSE IF "%~3" == "Stitch" (
        SET SceneName=StitchAmf
    ) ELSE (
        @ECHO Error! unsupported renderType
        EXIT /B 1
    )
    
    IF DEFINED Build_BluePrints (
        SET SceneSourceType=Blueprints
        SET SceneConfigurationPrintableName=!SceneName!_!UE_VERSION!_!SceneConfiguration!_!SceneSourceType!
        
        CALL :buildScene
    )
    
    SET SceneSourceType=
    IF DEFINED Build_CPP (
        SET SceneSourceType=CPP
        SET SceneConfigurationPrintableName=!SceneName!_!UE_VERSION!_!SceneConfiguration!_!SceneSourceType!

        CALL :buildScene
    )

    EXIT /B 0

:buildScene
    @ECHO:
    @ECHO SceneConfigurationPrintableName: !SceneConfigurationPrintableName!
    @ECHO SceneSourceType: !SceneSourceType!

    SET SceneBuildLogFile=!CD!\!LogFolderName!\!SceneConfigurationPrintableName!.log
    SET returnCode=0
    SET buildSuccess=""

    CALL :fillDateTimeVariables startYear startMonth startDay startHour startMinute startSecond
    CALL Scripts\BuildSceneImplementation.bat
    
    IF ERRORLEVEL 1 (
        @ECHO Error: failed to build scene !SceneConfigurationPrintableName!
        SET returnCode=1
    ) ELSE (
        @ECHO Scene !SceneConfigurationPrintableName! built successfully!
        SET returnCode=0
    )

    CALL :fillDateTimeVariables endYear endMonth endDay endHour endMinute endSecond

    iF "!returnCode!" == "1" (
        SET buildSuccess=failed
    ) ELSE (
        SET buildSuccess=succeeded
    )

    @ECHO !SceneConfigurationPrintableName!,!startYear!/!startMonth!/!startDay!,!startHour!:!startMinute!:!startSecond!,!endYear!/!endMonth!/!endDay!,!endHour!:!endMinute!:!endSecond!,!buildSuccess!>>"!ResultsFileName!"
    
    EXIT /B 0

:fillDateTimeVariables yy mm dd hour minute second [/A]
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

    EXIT /b 0