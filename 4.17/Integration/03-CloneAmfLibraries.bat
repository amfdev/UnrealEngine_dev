mkdir .\AmfMedia-4.17
cd .\AmfMedia-4.17
git init
rem git config user.email %1
rem git config user.name %1
rem git config user.password %2
git pull https://%1:%2@github.com/GPUOpenSoftware/UnrealEngine.git AmfMedia-4.17
rem git clone https://github.com/EpicGames/UnrealEngine.git
cd ..