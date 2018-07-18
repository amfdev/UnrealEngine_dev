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

bool UMediaTestFunctionLibrary::GrabOption(FString& Options, FString& Result)
{
	FString QuestionMark(TEXT("?"));
	FString SwitchMark(TEXT("-"));

	Options = Options.TrimStart();

	int QuestionIndex = Options.Find(QuestionMark, ESearchCase::CaseSensitive);
	int SwitchIndex = Options.Find(SwitchMark, ESearchCase::CaseSensitive);

	// Option or switch found
	if (0 == QuestionIndex || 0 == SwitchIndex)
	{
		int NextQuestionIndex = Options.Find(QuestionMark, ESearchCase::CaseSensitive, ESearchDir::FromStart, 1);
		int NextSwitchIndex = Options.Find(SwitchMark, ESearchCase::CaseSensitive, ESearchDir::FromStart, 1);
		
		int NextIndex = INDEX_NONE == NextQuestionIndex
			? NextSwitchIndex
			: (INDEX_NONE == NextSwitchIndex ? NextQuestionIndex : FMath::Min(NextQuestionIndex, NextSwitchIndex));


		// Take a block before next param
		if (INDEX_NONE != NextIndex)
		{
			Result = Options.Mid(1, NextIndex - 1).TrimEnd();
			Options = Options.Right(Options.Len() - NextIndex);
		}
		// No next params
		else
		{
			Result = Options.Mid(1, MAX_int32);
			Options.Reset();
		}

		return true;
	}

	return false;
}

void UMediaTestFunctionLibrary::GetKeyValue(const FString& Pair, FString& Key, FString& Value)
{
	const int32 EqualSignIndex = Pair.Find(TEXT("="), ESearchCase::CaseSensitive);
	if (EqualSignIndex != INDEX_NONE)
	{
		Key = Pair.Left(EqualSignIndex);
		Value = Pair.Mid(EqualSignIndex + 1, MAX_int32);
	}
	else
	{
		Key = Pair;
		Value = TEXT("");
	}
}

bool UMediaTestFunctionLibrary::HasOption(FString Options, const FString& Key)
{
	FString Pair, PairKey, PairValue;
	while (GrabOption(Options, Pair))
	{
		GetKeyValue(Pair, PairKey, PairValue);
		if (Key == PairKey)
		{
			return true;
		}
	}
	return false;
}

FString UMediaTestFunctionLibrary::ParseOption(FString Options, const FString& Key)
{
	FString ReturnValue;
	FString Pair, PairKey, PairValue;
	while (GrabOption(Options, Pair))
	{
		GetKeyValue(Pair, PairKey, PairValue);
		if (Key == PairKey)
		{
			ReturnValue = MoveTemp(PairValue);
			break;
		}
	}
	return ReturnValue;
}