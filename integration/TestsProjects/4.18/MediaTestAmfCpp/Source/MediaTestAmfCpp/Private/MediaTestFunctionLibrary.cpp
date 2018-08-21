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
	return LoadFileToStringArray(StringArrayOut, *FileNameIn);
}

bool UMediaTestFunctionLibrary::LoadFileToStringArray( TArray<FString>& Result, const TCHAR* Filename )
{
    Result.Empty();

    FString Buffer;
    if(!FFileHelper::LoadFileToString(Buffer, Filename))
    {
        return false;
    }

    for(const TCHAR* Pos = *Buffer; *Pos != 0; )
    {
        const TCHAR* LineStart = Pos;
        while(*Pos != 0 && *Pos != '\r' && *Pos != '\n')
        {
            Pos++;
        }

        Result.Add(FString(Pos - LineStart, LineStart));

        if(*Pos == '\r')
        {
            Pos++;
        }
        if(*Pos == '\n')
        {
            Pos++;
        }
    }

    return true;
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

	int QuestionIndex = TrimStart(Options).Find(QuestionMark, ESearchCase::CaseSensitive);
	int SwitchIndex = TrimStart(Options).Find(SwitchMark, ESearchCase::CaseSensitive);

    if (0 == QuestionIndex)
    {
        return GrabParamEqualValue(Options, Result);
    }
    else if (0 == SwitchIndex)
    {
        return GrabLaunchOption(Options, Result);
    }

    return false;
}

bool UMediaTestFunctionLibrary::GrabParamEqualValue(FString& Options, FString& ResultString)
{
    FString LaunchOption;
    LaunchOption.Reserve(Options.Len());
    
    bool ParamFound = false;
    bool ValueFound = false;
    bool InQuotas = false;
    
    bool EndOption = false;
    int Index = 0;

    FString LaunchOptionAndValue;
    LaunchOptionAndValue.Reserve(Options.Len());

    for (Index = 1; !EndOption && Index < Options.Len(); ++Index)
    {
        TCHAR Char = Options[Index];

        switch (Char)
        {
        case ' ':
        case '\t':
            if (!InQuotas)
            {
                // Don't allow extra spaces before param name, only ?param=value or ?param="value with spaces" allowed
                if (!ParamFound)
                {
                    return false;
                }
                // Found end of the ?param=value sequence
                else if (ValueFound)
                {
                    EndOption = true;

                    break;
                }
                else
                {
                    // Don't allow extra spaces inside ?param=value sequence
                    return false;
                }
            }
            else
            {
                LaunchOptionAndValue.AppendChar(Char);
            }

            break;

        case '\\':
            // Don't allow escaping in the ?param=value sequence
            if (!InQuotas)
            {
                return false;
            }
            else
            {
                LaunchOptionAndValue.AppendChar(Char);
            }

            break;
            
        case '\'':
        case '\"':
            if (InQuotas)
            {
                // Test last symbol               Test space before other options
                if ((Index == Options.Len() - 1) || (Options[Index + 1] == ' ') || (Options[Index + 1] == '\t'))
                {
                    InQuotas = false;
                    EndOption = true;

                    break;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                if (ParamFound && (Options[Index - 1] == '='))
                {
                    InQuotas = true;
                }
                else
                {
                    return false;
                }
            }

            break;

        case '=':
            if (ParamFound)
            {
                LaunchOptionAndValue.AppendChar(Char);
            }
            else
            {
                return false;
            }

            break;

        default:
            if (!ParamFound)
            {
                ParamFound = true;
            }
            else if (LaunchOptionAndValue[LaunchOptionAndValue.Len() - 1] == '=')
            {
                ValueFound = true;
            }

            LaunchOptionAndValue.AppendChar(Char);
        }

        if (!InQuotas && ParamFound && ValueFound && (Index == Options.Len() - 1))
        {
            EndOption = true;
        }
    }

    if (LaunchOptionAndValue.Len() && EndOption)
    {
        ResultString = LaunchOptionAndValue;
        Options = Options.Right(Options.Len() - Index);

        return true;
    }

    return false;
}

bool UMediaTestFunctionLibrary::GrabLaunchOption(FString& Options, FString& ResultString)
{
    int Index = 0;

    FString LaunchOption;
    LaunchOption.Reserve(Options.Len());
    bool SkipDash = false;
    bool Break = false;

    for (Index = 1; !Break && (Index < Options.Len()); ++Index)
    {
        TCHAR Char = Options[Index];

        switch (Char)
        {
        // Skip first dash
        case '-':
            if (!SkipDash)
            {
                SkipDash = true;

                break;
            }

            // Don't allow --LaunchOptionName
            return false;

        case L' ':
        case L'\t':
            Break = true;

            break;

        // Don't allow escaping in the launch option
        case '\\':
            return false;

        // Don't allow quoted text in the launch option
        case '\'':
        case '\"':
            return false;

        default:
            LaunchOption.AppendChar(Char);
        }
    }

    if (LaunchOption.Len())
    {
        ResultString = LaunchOption;
        Options = Options.Right(Options.Len() - Index);
    }

    return LaunchOption.Len() > 0;
}

FString UMediaTestFunctionLibrary::TrimStart(const FString& String)
{
    FString Result(String);
    int32 Pos = 0;
    while(Pos < Result.Len() && FChar::IsWhitespace(Result[Pos]))
    {
        Pos++;
    }
    Result.RemoveAt(0, Pos);

    return Result;
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

bool UMediaTestFunctionLibrary::HasLaunchOption(FString Options, const FString& OptionToCheck)
{
	bool ReturnValue = false;
	FString Grabbed;
	while (GrabOption(Options, Grabbed))
	{
		if (OptionToCheck == Grabbed)
		{
			ReturnValue = true;
			break;
		}
	}
	return ReturnValue;
}