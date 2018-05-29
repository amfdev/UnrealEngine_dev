@ECHO %Verbose%
SETLOCALE

:choice
set /P c=Are you sure you want hard reset you git repository? (Y/N) 
if /I "%c%" EQU "Y" goto :yes
if /I "%c%" EQU "N" goto :no
goto :choice

:no
EXIT /B 0

:yes
@ECHO Hard reset git...
git reset --hard && git clean -fdx