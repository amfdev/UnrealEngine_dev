// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "MediaTestFunctionLibrary.generated.h"

/**
 * 
 */
UCLASS()
class MEDIATESTAMFCPP_API UMediaTestFunctionLibrary : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()
	
	UFUNCTION(BlueprintCallable, Category = "Files")
	static bool FileSaveString(const FString& FileNameIn, const FString& SaveTextIn);

	UFUNCTION(BlueprintPure, Category = "Files")
	static bool FileLoadString(const FString& FileNameIn, FString& SaveTextOut);

	UFUNCTION(BlueprintPure, Category = "Files")
	static bool FileLoadStringArray(const FString& FileNameIn, TArray<FString>& StringArrayOut);

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
};
