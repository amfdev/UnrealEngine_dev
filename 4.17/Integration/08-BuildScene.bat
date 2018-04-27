cd TestsProjects

RunUAT BuildCookRun -project="FPSProject.uproject" -noP4 -platform=Win64 -clientconfig=Development -serverconfig=Development -cook -allmaps -build -stage -pak -archive -archivedirectory="Output Directory"

cd ..