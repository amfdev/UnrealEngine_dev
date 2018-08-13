#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"

#include <list>

#include "CustomPaintWidget.generated.h"

UCLASS()
class MEDIATESTAMFCPP_API UCustomPaintWidget:
    public UUserWidget
{
protected:
    std::list< float > FpsRate;
    std::list< float > CpuConsumption;
    std::list< float > GpuConsumption;
    
    std::list< FString > ConsoleMessages;
    UFont *ConsoleFont;
    int32 ConsoleFontSize;
    FName ConsoleFontTypeFace;
    FLinearColor ConsoleFontColor;

    float LastQueryDelta;

public:
    GENERATED_BODY()

    UCustomPaintWidget(const FObjectInitializer& ObjectInitializer);

    void NativePaint(FPaintContext& InContext) const override;
    void NativeTick(const FGeometry& MyGeometry, float InDeltaTime) override;

    UFUNCTION(BlueprintCallable, Category = "PerformanceWidget", meta = (BlueprintThreadSafe))
    void AddMessage(const FString& Message);

    UFUNCTION(BlueprintCallable, Category = "PerformanceWidget", meta = (BlueprintThreadSafe))
    void SetConsoleFont(UFont* Font, int32 FontSize = 16, FName FontTypeFace = FName(TEXT("Regular")), FLinearColor Tint = FLinearColor::White);
};
