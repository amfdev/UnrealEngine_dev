@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED PLUGIN_FOLDER (
    @ECHO Error: folder to clean undefined!
    GOTO :error
)

IF EXIST "%PLUGIN_FOLDER%" (

    CD %PLUGIN_FOLDER%
    IF ERRORLEVEL 1 GOTO :error

    git config --global core.longpaths true
    IF ERRORLEVEL 1 GOTO :error

    SET GIT_ASK_YESNO=false

    git reset --hard
    IF ERRORLEVEL 1 GOTO :error

    git clean -fdx
    IF ERRORLEVEL 1 GOTO :error

    IF EXIST "%CD%/.git/rebase-apply" (
        RD /S /Q "%CD%/.git/rebase-apply"
    )
)

:done
    @ECHO Folder %PLUGIN_FOLDER% successfully cleaned
    EXIT /B 0

:error
    @ECHO Error: failed to clean folder %PLUGIN_FOLDER%
    EXIT /B 1