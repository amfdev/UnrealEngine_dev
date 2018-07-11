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
	static bool FileSaveString(FString FileNameIn, FString SaveTextIn);

	UFUNCTION(BlueprintPure, Category = "Files")
	static bool FileLoadString(FString FileNameIn, FString& SaveTextOut);

	UFUNCTION(BlueprintPure, Category = "Files")
	static bool FileLoadStringArray(FString FileNameIn, TArray<FString>& StringArrayOut);
};
