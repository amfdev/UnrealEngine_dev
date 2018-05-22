@ECHO OFF
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

FOR %%x IN (%*) DO (
   IF /i "%%~x"=="4.17" (
        rem @ECHO 4.17 enabled
        SET Build_4_17=1
    ) ELSE IF /i "%%~x"=="4.18" (
        rem @ECHO 4.18 enabled
        SET Build_4_18=1
    ) ELSE IF /i "%%~x"=="Amf" (
        rem @ECHO Amf enabled
        SET Build_Amf=1
    ) ELSE IF /i "%%~x"=="Standard" (
        rem @ECHO Standard enabled
        SET Build_Standard=1
    ) ELSE IF /i "%%~x"=="Development" (
        rem @ECHO Development build enabled
        SET Build_Development=1
    ) ELSE IF /i "%%~x"=="Shipping" (
        rem @ECHO Shipping build enabled
        SET Build_Shipping=1
    ) ELSE IF /i "%%~x"=="BluePrints" (
        rem @ECHO BluePrints enabled
        SET Build_BluePrints=1
    ) ELSE IF /i "%%~x"=="CPP" (
        rem @ECHO CPP enabled
        SET Build_CPP=1
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

@ECHO Prepare log folder
IF NOT EXIST Logs (
    MKDIR Logs
    IF ERRORLEVEL 1 GOTO :error
)

CALL :fillDateTimeVariables aaa bbb ccc CurrentHour CurrentMinute CurrentSecond
@ECHO %aaa%/%bbb%/%ccc%
@ECHO %CurrentHour%:%CurrentMinute%:%CurrentSecond%

CALL :fillDateTimeVariables CurrentYear CurrentMonth CurrentDay CurrentHour CurrentMinute CurrentSecond
@ECHO %CurrentYear%/%CurrentMonth%/%CurrentDay%
@ECHO %CurrentHour%:%CurrentMinute%:%CurrentSecond%


exit /b 0
SET LogFileName=Logs\TotalBuild_%CurrentYear%_%CurrentMonth%_%CurrentDay%__%CurrentHour%_%CurrentMinute%_%CurrentSecond%.log

IF DEFINED Build_4_17 (
    CALL :processBuildUnrealClean 4.17
    )
IF DEFINED Build_4_18 (
    CALL :processBuildUnrealClean 4.18
    )

:done
    @ECHO Total build successfully finished!
    EXIT /B 0

:error
    @ECHO Error: total build failed!
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
    SET UnrealConfiguration=%~2

    if "%~3" == "" (
        SET AMF_VERSION=
        SET BuildTypePrintableName=Standard
    ) ELSE (
        SET AMF_VERSION=%~3
        SET BuildTypePrintableName=Amf
    )

    SET UnrealConfiguration=%~2
    SET UnrealConfigurationPrintableName=%1_%2_%BuildTypePrintableName%

    @ECHO:
    @ECHO Build UnrealEngine %UnrealConfigurationPrintableName%

    CALL :fillDateTimeVariables startYear startMonth startDay startHour startMinute startSecond
    @ECHO %startYear%/%startMonth%/%startDay%
    @ECHO %startHour%:%startMinute%:%startSecond%

    rem CALL Scripts\BuildUnrealCleanImplementation.bat
    
    IF ERRORLEVEL 1 (
        @ECHO Error: failed to build UnrealEngine %UnrealConfigurationPrintableName%
        SET returnCode=1
    ) ELSE (
        @ECHO UnrealEngine %UnrealConfigurationPrintableName% built successfully!
        SET returnCode=0
    )

    CALL :fillDateTimeVariables endYear endMonth endDay endHour endMinute endSecond

    iF "%returnCode%" == "1" (
        SET buildSuccess=failed
    ) ELSE (
        SET buildSuccess=succeeded
    )

    @ECHO %UnrealConfigurationPrintableName% %startYear%/%startMonth%/%startDay%_%startHour%:%startMinute%:%startSecond% %startYear%/%startMonth%/%startDay%_%startHour%:%startMinute%:%startSecond% %buildSuccess%>>"%LogFileName%""

    EXIT /B !returnCode!

:fillDateTimeVariables yy mm dd hour minute second [/A]
    SETLOCAL ENABLEEXTENSIONS
    if "%date%A" LSS "A" (set toks=1-3) else (set toks=2-4)
    for /f "tokens=2-4 delims=(-)" %%a in ('echo:^|date') do (
    for /f "tokens=%toks% delims=.-/ " %%i in ('date/t') do (
        set '%%a'=%%i
        set '%%b'=%%j
        set '%%c'=%%k
    )
    )
    if /I "%'yy'%"=="" set "'yy'=%'aa'%"
    if /I "%'yy'%"=="" ( set "'yy'=%'jj'%" & set "'dd'=%'tt'%" )
    if %'yy'% LSS 100 set 'yy'=20%'yy'%
    endlocal&set %1=%'yy'%&set %7 %2=%'mm'%&set %7 %3=%'dd'%
    
    SET currentTimeValue=%TIME%
    IF "%currentTimeValue:~0,1%" == " " (SET currentTimeValue=0%currentTimeValue:~1,7%)
    
    SET %4=%currentTimeValue:~0,2%
    SET %5=%currentTimeValue:~3,2%
    SET %6=%currentTimeValue:~6,2%

    EXIT /b 0

:getDateValues yy mm dd [/A]
    :: Returns the current date on any machine with regional-independent settings
    :: Arguments:
    ::   yy = variable name for the year output
    ::   mm = variable name for the month output
    ::   dd = variable name for the day output
    ::   /A = OPTIONAL, removes leading 0 on days/months smaller than 10 (example: 01 becomes 1)
    :: Remarks:
    ::  Will return month in text format in regions with MMM month
    ::
    SETLOCAL ENABLEEXTENSIONS
    if "%date%A" LSS "A" (set toks=1-3) else (set toks=2-4)
    for /f "tokens=2-4 delims=(-)" %%a in ('echo:^|date') do (
    for /f "tokens=%toks% delims=.-/ " %%i in ('date/t') do (
        set '%%a'=%%i
        set '%%b'=%%j
        set '%%c'=%%k
    )
    )
    if /I "%'yy'%"=="" set "'yy'=%'aa'%"
    if /I "%'yy'%"=="" ( set "'yy'=%'jj'%" & set "'dd'=%'tt'%" )
    if %'yy'% LSS 100 set 'yy'=20%'yy'%
    endlocal&set %1=%'yy'%&set %4 %2=%'mm'%&set %4 %3=%'dd'%

    EXIT /B 0