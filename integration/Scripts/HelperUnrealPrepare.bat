@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED UnrealHome (
    @ECHO Error: UnrealHome variable undefined!
    GOTO :error
)

:checkRights
FSUTIL DIRTY QUERY %systemdrive% >nul
if %errorlevel% == 0 (
    echo Running with administrator rights.
) else (
    ECHO Error: administrator rights required!
    GOTO :error
)

CD %UnrealHome%
IF ERRORLEVEL 1 GOTO :error

@ECHO Generate UnrealEngine project files
CALL GenerateProjectFiles.bat
IF ERRORLEVEL 1 GOTO :error

rem @ECHO Add dependency to shipping configuration
rem git apply ..\Patches\UE4.sln.patch
rem IF ERRORLEVEL 1 (
rem     COLOR 4
rem     @ECHO Patch unsuccessfull, try to continue without patch...
rem     )
rem COLOR

:done
    @ECHO Create of UnrealEngine project files completed
    EXIT /B 0

:error
    @ECHO Error: failed to create UnrealEngine project files
    EXIT /B 1