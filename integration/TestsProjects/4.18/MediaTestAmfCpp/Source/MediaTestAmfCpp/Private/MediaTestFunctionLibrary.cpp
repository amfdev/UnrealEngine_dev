// Fill out your copyright notice in the Description page of Project Settings.

#include "MediaTestFunctionLibrary.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Modules/ModuleManager.h"
#include "Misc/PackageName.h"

bool UMediaTestFunctionLibrary::FileSaveString(const FString& FileNameIn, const FString& SaveTextIn)
{
	                                 //*(FPaths::GameDir() + FileNameB)
	return FFileHelper::SaveStringToFile(SaveTextIn, *FileNameIn);
}

bool UMediaTestFunctionLibrary::FileLoadString(const FString& FileNameIn, FString& SaveTextOut)
{
	return FFileHelper::LoadFileToString(SaveTextOut, *FileNameIn);
}

bool UMediaTestFunctionLibrary::FileLoadStringArray(const FString& FileNameIn, TArray<FString>& StringArrayOut)
{
	return FFileHelper::LoadFileToStringArray(StringArrayOut, *FileNameIn);
}

FString UMediaTestFunctionLibrary::GetCurrentPath()
{
	return FPaths::LaunchDir();
}

FString UMediaTestFunctionLibrary::GetRootDir()
{
	return FPaths::RootDir();
}

//FString UMediaTestFunctionLibrary::GetBaseDir()
//{
//	return FPaths::BaseDir();
//}

void UMediaTestFunctionLibrary::PrepareFullPath(const FString& BaseDirIn, const FString& FileNameIn, FString& FileNameOut)
{
	FileNameOut = FPaths::ConvertRelativePathToFull(BaseDirIn, FileNameIn);
}

bool UMediaTestFunctionLibrary::IsFileExist(const FString& FileNameIn)
{
	return FPaths::FileExists(FileNameIn);
}