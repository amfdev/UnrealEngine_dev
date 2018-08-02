// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/HUD.h"
#include "PerformanceChart.generated.h"

/**
 * 
 */
UCLASS()
class MEDIATESTAMFCPP_API APerformanceChart : public AHUD
{
	GENERATED_BODY()

protected:
    APlayerController* ThePC;

    /** after all game elements are created */
    virtual void PostInitializeComponents() override;

public:
    APerformanceChart();

    /** Primary draw call for the HUD */
    virtual void DrawHUD() override;
};
