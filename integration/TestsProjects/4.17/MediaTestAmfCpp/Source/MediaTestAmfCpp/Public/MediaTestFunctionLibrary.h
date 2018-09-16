#pragma once

#include "CoreMinimal.h"
#include "Misc/FileHelper.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "MediaTestFunctionLibrary.generated.h"

/**
 * 
 */
UCLASS()
class MEDIATESTAMFCPP_API UMediaTestFunctionLibrary:
    public UBlueprintFunctionLibrary
{
	GENERATED_BODY()

public:	
	UFUNCTION(BlueprintCallable, Category = "Files")
	static bool FileSaveString(const FString& FileNameIn, const FString& SaveTextIn);

	UFUNCTION(BlueprintPure, Category = "Files")
	static bool FileLoadString(const FString& FileNameIn, FString& SaveTextOut);

	UFUNCTION(BlueprintPure, Category = "Files")
	static bool FileLoadStringArray(const FString& FileNameIn, TArray<FString>& StringArrayOut);

    /**
    * Load a text file to an array of strings. Supports all combination of ANSI/Unicode files and platforms.
    *
    * @param Result       String representation of the loaded file
    * @param Filename     Name of the file to load
    * @param VerifyFlags  Flags controlling the hash verification behavior ( see EHashOptions )
    */
    static bool LoadFileToStringArray( TArray<FString>& Result, const TCHAR* Filename );

	UFUNCTION(BlueprintPure, Category = "System")
	static FString GetCurrentPath();

	UFUNCTION(BlueprintPure, Category = "System")
	static FString GetRootDir();

	//UFUNCTION(BlueprintPure, Category = "System")
	//static FString GetBaseDir();

	UFUNCTION(BlueprintPure, Category = "System")
	static void PrepareFullPath(const FString& BaseDirIn, const FString& FileNameIn, FString& FileNameOut);

	UFUNCTION(BlueprintPure, Category = "System")
	static bool IsFileExist(const FString& FileNameIn);

	static bool GrabOption(FString& Options, FString& ResultString);
    static bool GrabParamEqualValue(FString& Options, FString& ResultString);
    static bool GrabLaunchOption(FString& Options, FString& ResultString);

    /**
    * Removes whitespace characters from the start of this string.
    * @note Unlike Trim() this function returns a copy, and does not mutate the string.
    */
    UFUNCTION(BlueprintPure, Category = "System")
    static FString TrimStart(const FString& String);

    /**
	* Break up a key=value pair into its key and value.
	* @param Pair			The string containing a pair to split apart.
	* @param Key			(out) Key portion of Pair. If no = in string will be the same as Pair.
	* @param Value			(out) Value portion of Pair. If no = in string will be empty.
	*/
	UFUNCTION(BlueprintPure, Category = "System", meta = (BlueprintThreadSafe))
	static void GetKeyValue(const FString& Pair, FString& Key, FString& Value);

	/**
	* Returns whether a key exists in an options string.
	* @param Options		The string containing the options.
	* @param Key			The key to determine if it exists in Options.
	* @return				Whether Key was found in Options.
	*/
	UFUNCTION(BlueprintPure, Category = "System", meta = (BlueprintThreadSafe))
	static bool HasOption(FString Options, const FString& InKey);

	/**
	* Find an option in the options string and return it.
	* @param Options		The string containing the options.
	* @param Key			The key to find the value of in Options.
	* @return				The value associated with Key if Key found in Options string.
	*/
	UFUNCTION(BlueprintPure, Category = "System", meta = (BlueprintThreadSafe))
	static FString ParseOption(FString Options, const FString& Key);

	/**
	* Checks the commandline to see if the desired option was specified on the commandline (e.g. -demobuild)
	* @return				True if the launch option was specified on the commandline, false otherwise
	*/
	UFUNCTION(BlueprintPure, Category = "System")
	static bool HasLaunchOption(FString Options, const FString& OptionToCheck);

    UFUNCTION(BlueprintPure, Category = "System", meta = (BlueprintThreadSafe))
    static FTimespan ParseTimespan(const FString& String);

    UFUNCTION(BlueprintPure, Category = "System", meta = (BlueprintThreadSafe))
    static FString Timespan2Filename(const FTimespan& Timespan);

    static int32 GetMilliseconds(const FTimespan& Timespan)
    {
        return (int32)((Timespan.GetTicks() / ETimespan::TicksPerMillisecond) % 1000);
    }

    //UFUNCTION(BlueprintPure, Category = "System")
    static bool SavePixmap(const uint8* Pixels, int Width, int Height, int Stride, const FString& Filename);
};
