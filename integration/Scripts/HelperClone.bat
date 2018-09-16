@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED PLUGIN_FOLDER (
    @ECHO Error: PLUGIN_FOLDER variable undefined!
    GOTO :error
)

IF NOT DEFINED PLUGIN_URL (
    @ECHO Error: PLUGIN_URL variable undefined!
    GOTO :error
)

IF NOT EXIST %PLUGIN_FOLDER% (

    @ECHO:
    @ECHO git clone:
    @ECHO url: %PLUGIN_URL%
    @ECHO branch: %PLUGIN_BRANCH%
    @ECHO folder: %PLUGIN_FOLDER%

    git clone -b "%PLUGIN_BRANCH%" --single-branch "%PLUGIN_URL%" "%PLUGIN_FOLDER%"
    IF ERRORLEVEL 1 (
        @ECHO:
        @ECHO Unable to clone %PLUGIN_URL% %PLUGIN_BRANCH%
        @ECHO If this will continue try to manualy download and unpack repository!
        @ECHO:
        GOTO :error
    )
) ELSE (
    @ECHO Update project %PLUGIN_URL% %PLUGIN_BRANCH%

    CD %PLUGIN_FOLDER%
    IF ERRORLEVEL 1 GOTO :error

    @ECHO Git init
    git init
    IF ERRORLEVEL 1 GOTO :error

    @ECHO Git pull
    git pull %PLUGIN_URL% %PLUGIN_BRANCH%
    IF ERRORLEVEL 1 GOTO :error

    @ECHO Git checkout
    git checkout %PLUGIN_BRANCH%
    IF ERRORLEVEL 1 GOTO :error
)

:done
    @ECHO Project %PLUGIN_URL% cloned or updated successfully
    EXIT /B 0

:error
    @ECHO Error: failed to clone or update project %PLUGIN_URL%
    EXIT /B 1