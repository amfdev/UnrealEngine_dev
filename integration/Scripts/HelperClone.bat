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

    @ECHO Git checkout demanded branch
    git checkout %PLUGIN_BRANCH%
    rem IF ERRORLEVEL 1 GOTO :error

    @ECHO Git test switch to demanded branch
    git rev-parse --abbrev-ref HEAD
    rem SET GIT_BRANCH_TEST="git rev-parse --abbrev-ref HEAD"
    rem FOR /F %%i IN (
    rem     '%GIT_BRANCH_TEST%'
    rem ) DO (
    rem     @ECHO here: %%i
    rem     SET GIT_CURRENT_BRANCH=%%i
    rem )

    rem @ECHO Current branch: %GIT_CURRENT_BRANCH%

    rem IF NOT ["%GIT_CURRENT_BRANCH%"] == ["%PLUGIN_BRANCH%"] (
    rem     @ECHO Git test for demanded branch failed
    rem     GOTO :error
    rem )
)

:done
    @ECHO Project %PLUGIN_URL% cloned or updated successfully
    EXIT /B 0

:error
    @ECHO Error: failed to clone or update project %PLUGIN_URL%
    EXIT /B 1