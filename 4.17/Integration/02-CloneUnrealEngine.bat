mkdir .\UnrealEngine
cd .\UnrealEngine
git init
rem git config user.email %1
rem git config user.name %1
rem git config user.password %2
git pull https://%1:%2@github.com/EpicGames/UnrealEngine.git 4.17
rem git clone https://github.com/EpicGames/UnrealEngine.git
cd ..