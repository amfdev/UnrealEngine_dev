#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"

#include <vector>

#include "CustomPaintWidget.generated.h"

UCLASS()
class MEDIATESTAMFCPP_API UCustomPaintWidget:
    public UUserWidget
{
protected:
    std::vector< float > FpsRate;
    std::vector< float > CpuConsumption;
    std::vector< float > GpuConsumption;

public:
    GENERATED_BODY()

    UCustomPaintWidget(const FObjectInitializer& ObjectInitializer);

    void NativePaint(FPaintContext& InContext) const override;
    void NativeTick(const FGeometry& MyGeometry, float InDeltaTime) override;
};
