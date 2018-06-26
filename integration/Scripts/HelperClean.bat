@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED PLUGIN_FOLDER (
    @ECHO Error: folder to clean undefined!
    GOTO :error
)

IF EXIST "%PLUGIN_FOLDER%" (

    CD %PLUGIN_FOLDER%
    IF ERRORLEVEL 1 GOTO :error

    git reset --hard
    IF ERRORLEVEL 1 GOTO :error

    git clean -fdx
    IF ERRORLEVEL 1 GOTO :error

    RD /S /Q "%CD%/.git/rebase-apply"

)

:done
    @ECHO Folder %PLUGIN_FOLDER% successfully cleaned
    EXIT /B 0

:error
    @ECHO Error: failed to clean folder %PLUGIN_FOLDER%
    EXIT /B 1