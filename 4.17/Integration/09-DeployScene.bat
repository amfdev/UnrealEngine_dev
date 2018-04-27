SETLOCAL
pushd %~dp0

CD TestsProjects
CD FPSProject

RunUAT BuildCookRun -project="FPSProject.uproject" -noP4 -platform=Win64 -clientconfig=Development -serverconfig=Development -cook -allmaps -NoCompile -stage -pak -archive -archivedirectory="Output Directory"