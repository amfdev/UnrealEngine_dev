#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"

#include <list>
#include <vector>
#include <tuple>

#include "CustomPaintWidget.generated.h"

UCLASS()
class MEDIATESTAMFCPP_API UCustomPaintWidget:
    public UUserWidget
{
protected:
    std::list< float > FpsRate;
    std::list< float > FpsRateRounded;
    std::vector< float > FpsRateCache;
    
    std::list< float > CpuConsumption;
    std::list< float > CpuConsumptionRounded;
    std::vector< float > CpuConsumptionCache;
    
    std::list< float > GpuConsumption;
    
    std::list< std::tuple<FString, FDateTime> > ConsoleMessages;
    UFont *ConsoleFont;
    int32 ConsoleFontSize;
    FName ConsoleFontTypeFace;
    FLinearColor ConsoleFontColor;
    
    mutable int32 FrameCounter;
    mutable int32 FrameCount;
    mutable FDateTime FrameCounterStart;

    float LastQueryDelta;
    bool SkipFirstFrame = true;

    //static
    int RoundingWindow = 5;
    int ChartCapacityTime = 200;
    float ChartCapacityCpu = 110.0f;
    float ChartCapacityFps = 130.0f;
    int ConsoleDelaySeconds = 12;

public:
    GENERATED_BODY()

    UCustomPaintWidget(const FObjectInitializer& ObjectInitializer);

    void NativePaint(FPaintContext& InContext) const override;
    void NativeTick(const FGeometry& MyGeometry, float InDeltaTime) override;

    UFUNCTION(BlueprintCallable, Category = "PerformanceWidget", meta = (BlueprintThreadSafe))
    void AddMessage(const FString& Message);

    UFUNCTION(BlueprintCallable, Category = "PerformanceWidget", meta = (BlueprintThreadSafe))
    void SetConsoleFont(UFont* Font, int32 FontSize = 16, FName FontTypeFace = FName(TEXT("Regular")), FLinearColor Tint = FLinearColor::White, int32 DelaySeconds = 12);

    UFUNCTION(BlueprintCallable, Category = "PerformanceWidget", meta = (BlueprintThreadSafe))
    static void GetTextLength(UFont* Font, const FString& String, float FontSize, float& SizeX, float& SizeY);
};
