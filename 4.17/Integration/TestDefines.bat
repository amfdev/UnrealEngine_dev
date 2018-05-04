@ECHO OFF

SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 GOTO :noExt
@ECHO Command line extensions found
GOTO checkRights

:noExt
    ECHO Unable to enable extensions
    EXIT /B 1

:checkRights
FSUTIL DIRTY QUERY %systemdrive% >nul
if %errorlevel% == 0 (
    echo Running with administrator rights.
) else (
    ECHO Error: administrator rights required!
    EXIT /B 1
)

:checkMSBuild
SET "MSBuildFound=0"
IF DEFINED MSBUILD (SET "MSBuildFound=1")
IF "%MSBuildFound%"=="1" (GOTO testPath)

:noMSBuild
    @ECHO Error: MSBUILD variable with command for run MSBuild.exe must be defined!
    EXIT /B 1

:testPath
    @ECHO MSBuild variable found
    rem FOR /F "delims=" %%I IN ("%MSBUILD%") DO SET MSBUILD_Unquoted=%%I
    rem IF NOT EXIST "%MSBUILD_Unquoted%" GOTO :noMSBuild

@ECHO Defines tested...

ENDLOCAL
EXIT /B 0