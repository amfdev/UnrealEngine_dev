ECHO OFF
SETLOCAL enabledelayedexpansion

CALL Scripts\UtilityTestDefines.bat
IF ERRORLEVEL 1 GOTO :error

SET Build_4_17=
SET Build_4_18=
SET Build_Amf=
SET Build_Standard=
SET Build_Development=
SET Build_Shipping=
SET Build_BluePrints=
SET Build_CPP=
SET Build_Engine=
SET Build_Tests=
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
    ) ELSE IF /i "%%~x"=="Amf" (
        SET Build_Amf=1
        SET Params=%Params%C
        SET ParamsEngine=%ParamsEngine%C
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
        SET Params=%Params%H
        SET ParamsEngine=%ParamsScene%I
    ) ELSE IF /i "%%~x"=="Tests" (
        SET Build_Tests=1
        SET Params=%Params%H
        SET ParamsScene=%ParamsScene%J
    ) ELSE IF /i "%%~x"=="Help" (
        @ECHO Available commands: Build.bat [Engine] [Tests] [4.17] [4.18] [Standard] [Amf] [Development] [Shipping] BluePrints CPP Help
        EXIT /B 0
    ) ELSE (
        @ECHO Error: unsupported option: %%~x
        GOTO :error
    )
)

IF NOT DEFINED Build_4_17 IF NOT DEFINED Build_4_18 (
    @ECHO No UnrealEngine version specified, 4.17 and 4.18 will be added
    SET Build_4_17=1
    SET Build_4_18=1
)

IF NOT DEFINED Build_Standard IF NOT DEFINED Build_Amf (
    @ECHO No build type specified by args, standard and Amf will be added 
    SET Build_Standard=1
    SET Build_Amf=1
)

IF NOT DEFINED Build_Development IF NOT DEFINED Build_Shipping (
    @ECHO No configuration specified by args, Development and Shipping will be added
    SET Build_Development=1
    SET Build_Shipping=1
)

IF NOT DEFINED Build_Engine IF NOT DEFINED Build_Tests (
    @ECHO Engine and tests will be built
    SET Build_Engine=1
    SET Build_Tests=1
    SET Build_BluePrints=1
    SET Build_CPP=1
)

@ECHO Prepare log folder
IF NOT EXIST Logs (
    MKDIR Logs
    IF ERRORLEVEL 1 GOTO :error
)

CALL :fillDateTimeVariables CurrentYear CurrentMonth CurrentDay CurrentHour CurrentMinute CurrentSecond
rem @ECHO %CurrentYear%/%CurrentMonth%/%CurrentDay%
rem @ECHO %CurrentHour%:%CurrentMinute%:%CurrentSecond%

SET LogFileName=Logs\TotalBuild_%CurrentYear%_%CurrentMonth%_%CurrentDay%__%CurrentHour%_%CurrentMinute%_%CurrentSecond%.log.csv
@ECHO project_name,start_date,start_time,end_date,end_time,result>>"%LogFileName%""

IF DEFINED Build_4_17 (
    CALL :processBuildUnrealClean 4.17
    )

IF DEFINED Build_4_18 (
    CALL :processBuildUnrealClean 4.18
    )

:done
    @ECHO:
    @ECHO Build successfully finished!
    EXIT /B 0

:error
    @ECHO:
    @ECHO Error: build failed!
    EXIT /B 1

:processBuildUnrealClean unreal_number
    IF DEFINED Build_Standard (        
        IF DEFINED Build_Development (
            CALL :prepareBuildUnrealClean %~1 Development
        )

        IF DEFINED Build_Shipping (
            CALL :prepareBuildUnrealClean %~1 Shipping
        )
    )
    
    IF DEFINED Build_Amf (
        IF DEFINED Build_Development (
            CALL :prepareBuildUnrealClean %~1 Development %~1
        )

        IF DEFINED Build_Shipping (
            CALL :prepareBuildUnrealClean %~1 Shipping %~1
        )
    )
    
    EXIT /B 0

:prepareBuildUnrealClean unreal_number configuration amf_number
    SET UE_VERSION=%~1

    if "%~3" == "" (
        SET AMF_VERSION=
        SET BuildTypePrintableName=Standard
    ) ELSE (
        SET AMF_VERSION=%~3
        SET BuildTypePrintableName=Amf
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

    SET UnrealConfigurationPrintableName=UnrealEngine_%UE_VERSION%_%UnrealConfiguration%_%BuildTypePrintableName%

    @ECHO:
    rem @ECHO Current engine configuration: %UnrealConfigurationPrintableName%
    
    IF DEFINED Build_Engine (
        rem @ECHO Configuration will be built

        CALL :fillDateTimeVariables startYear startMonth startDay startHour startMinute startSecond        
        CALL Scripts\BuildUnrealCleanImplementation.bat
        
        IF ERRORLEVEL 1 (
            @ECHO Error: failed to build "%UnrealConfigurationPrintableName%"
            SET returnCode=1
        ) ELSE (
            @ECHO Build for "%UnrealConfigurationPrintableName%" is done
            SET returnCode=0
        )

        CALL :fillDateTimeVariables endYear endMonth endDay endHour endMinute endSecond

        iF "%returnCode%" == "1" (
            SET buildSuccess=failed
        ) ELSE (
            SET buildSuccess=succeeded
        )

        @ECHO %UnrealConfigurationPrintableName%,%startYear%/%startMonth%/%startDay%,%startHour%:%startMinute%:%startSecond%,%endYear%/%endMonth%/%endDay%,%endHour%:%endMinute%:%endSecond%,%buildSuccess%>>"%LogFileName%"
    ) ELSE (
        rem @ECHO Skip building configuration
    )

    SET SceneSourceType=

    IF DEFINED Build_BluePrints (
        SET SceneSourceType=Blueprints
        SET SceneConfigurationPrintableName=TestPlane_%UE_VERSION%_%SceneConfiguration%_%BuildTypePrintableName%_Blueprints
        
        CALL :buildScene
    )
    
    SET SceneSourceType=
    IF DEFINED Build_CPP (
        SET SceneSourceType=CPP
        SET SceneConfigurationPrintableName=TestPlane_%UE_VERSION%_%SceneConfiguration%_%BuildTypePrintableName%_CPP

        CALL :buildScene
    )

    EXIT /B 0

:buildScene
    @ECHO:
    @ECHO Build %SceneConfigurationPrintableName%
    
    CALL :fillDateTimeVariables startYear startMonth startDay startHour startMinute startSecond
    CALL Scripts\BuildSceneImplementation.bat
    
    IF ERRORLEVEL 1 (
        @ECHO Error: failed to build scene %SceneConfigurationPrintableName%
        SET returnCode=1
    ) ELSE (
        @ECHO Scene %SceneConfigurationPrintableName% built successfully!
        SET returnCode=0
    )

    CALL :fillDateTimeVariables endYear endMonth endDay endHour endMinute endSecond

    iF "%returnCode%" == "1" (
        SET buildSuccess=failed
    ) ELSE (
        SET buildSuccess=succeeded
    )

    @ECHO %SceneConfigurationPrintableName%,%startYear%/%startMonth%/%startDay%,%startHour%:%startMinute%:%startSecond%,%endYear%/%endMonth%/%endDay%,%endHour%:%endMinute%:%endSecond%,%buildSuccess%>>"%LogFileName%"
    
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