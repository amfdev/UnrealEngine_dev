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
};
