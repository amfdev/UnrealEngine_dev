#pragma once

#include "CoreMinimal.h"
#include "CoreTypes.h"

/**
 * 
 */
UCLASS()
class MEDIATESTAMFCPP_API UShortConsole:
    public UObject
{
	GENERATED_BODY()
	
	void AddMessageToConsole(const FString& Message);
};
