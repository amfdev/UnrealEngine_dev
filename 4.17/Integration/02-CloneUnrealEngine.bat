@ECHO OFF

IF [%1]==[] GOTO usage ELSE GOTO :checkFolder
IF [%2]==[] GOTO usage ELSE GOTO :checkFolder
GOTO checkFolder

:usage
@ECHO "Error: git login and password must be set, usage: 02-CloneUnrealEngine.bat <Login> <Password>"
EXIT /B 1

:checkFolder
IF EXIST UnrealEngine (
    ECHO UnrealEngine-4.17 folder found!
    GOTO :update
) ELSE (
    MKDIR UnrealEngine
)

:update
SETLOCAL
pushd %~dp0

CD UnrealEngine

git init

REM git config user.email %1
git config user.name %1
git config user.password %2

git pull https://%1:%2@github.com/EpicGames/UnrealEngine.git 4.17
REM git clone https://github.com/EpicGames/UnrealEngine.git

cd ..