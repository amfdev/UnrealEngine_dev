// Copyright 1998-2017 Epic Games, Inc. All Rights Reserved.

#include "FPSProjectGameMode.h"
#include "FPSProjectHUD.h"
#include "FPSProjectCharacter.h"
#include "UObject/ConstructorHelpers.h"

AFPSProjectGameMode::AFPSProjectGameMode()
	: Super()
{
	// set default pawn class to our Blueprinted character
	static ConstructorHelpers::FClassFinder<APawn> PlayerPawnClassFinder(TEXT("/Game/FirstPersonCPP/Blueprints/FirstPersonCharacter"));
	DefaultPawnClass = PlayerPawnClassFinder.Class;

	// use our custom HUD class
	HUDClass = AFPSProjectHUD::StaticClass();
}
