@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED PLUGIN_FOLDER (
    @ECHO Error: PLUGIN_FOLDER variable undefined!
    GOTO :error
)

IF NOT DEFINED PROJECT_URL (
    @ECHO Error: PROJECT_URL variable undefined!
    GOTO :error
)

IF NOT EXIST %PLUGIN_FOLDER% (
    @ECHO Clone project %PROJECT_URL% %PROJECT_BRANCH%

    git clone -b "%PROJECT_BRANCH%" --single-branch "%PROJECT_URL%" "%PLUGIN_FOLDER%"
    IF ERRORLEVEL 1 (
        @ECHO:
        @ECHO Unable to clone %PROJECT_URL% %PROJECT_BRANCH%
        @ECHO If this will continue try to manualy download and unpack repository!
        @ECHO:
        GOTO :error
    )
) ELSE (
    @ECHO Update project %PROJECT_URL% %PROJECT_BRANCH%

    CD %PLUGIN_FOLDER%
    IF ERRORLEVEL 1 GOTO :error

    @ECHO Git init
    git init
    IF ERRORLEVEL 1 GOTO :error

    @ECHO Git pull
    git pull %PROJECT_URL% %PROJECT_BRANCH%
    IF ERRORLEVEL 1 GOTO :error
)

:done
    @ECHO Project %PROJECT_URL% cloned or updated successfully
    EXIT /B 0

:error
    @ECHO Error: failed to clone or update project %PROJECT_URL%
    EXIT /B 1