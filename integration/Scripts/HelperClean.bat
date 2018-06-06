@ECHO %Verbose%
SETLOCAL

IF NOT DEFINED PROJECT_FOLDER (
    @ECHO Error: folder to clean undefined!
    GOTO :error
)

CD %PROJECT_FOLDER%
IF ERRORLEVEL 1 GOTO :error

git reset --hard
IF ERRORLEVEL 1 GOTO :error

git clean -fdx
IF ERRORLEVEL 1 GOTO :error

RD /S /Q "%CD%/.git/rebase-apply"

:done
    @ECHO Folder %PROJECT_FOLDER% successfully cleaned
    EXIT /B 0

:error
    @ECHO Error: failed to clean folder %PROJECT_FOLDER%
    EXIT /B 1