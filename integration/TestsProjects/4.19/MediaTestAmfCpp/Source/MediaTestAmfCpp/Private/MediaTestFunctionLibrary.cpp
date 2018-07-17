// Fill out your copyright notice in the Description page of Project Settings.

#include "MediaTestFunctionLibrary.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Modules/ModuleManager.h"
#include "Misc/PackageName.h"

bool UMediaTestFunctionLibrary::FileSaveString(FString FileNameIn, FString SaveTextIn)
{
	                                 //*(FPaths::GameDir() + FileNameB)
	return FFileHelper::SaveStringToFile(SaveTextIn, *FileNameIn);
}

bool UMediaTestFunctionLibrary::FileLoadString(FString FileNameIn, FString& SaveTextOut)
{
	return FFileHelper::LoadFileToString(SaveTextOut, *FileNameIn);
}

bool UMediaTestFunctionLibrary::FileLoadStringArray(FString FileNameIn, TArray<FString>& StringArrayOut)
{
	return FFileHelper::LoadFileToStringArray(StringArrayOut, *FileNameIn);
}

FString UMediaTestFunctionLibrary::GetCurrentPath()
{
	return FPaths::LaunchDir();
}




