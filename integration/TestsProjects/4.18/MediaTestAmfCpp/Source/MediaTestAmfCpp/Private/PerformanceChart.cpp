#include "PerformanceChart.h"

#include "Engine/Canvas.h"
#include "TextureResource.h"
#include "CanvasItem.h"

APerformanceChart::APerformanceChart()
{
    // Set the crosshair texture
    //static ConstructorHelpers::FObjectFinder<UTexture2D> CrosshiarTexObj(TEXT("/Game/FirstPerson/Textures/FirstPersonCrosshair"));
    //CrosshairTex = CrosshiarTexObj.Object;
}

void APerformanceChart::PostInitializeComponents()
{
    Super::PostInitializeComponents();

    //Establish the PC
    ThePC = GetOwningPlayerController();
}


void APerformanceChart::DrawHUD()
{
    //Default template code

    Super::DrawHUD();

    // Draw very simple crosshair

    // find center of the Canvas
    const FVector2D Center(Canvas->ClipX * 0.5f, Canvas->ClipY * 0.5f);

    // offset by half the texture's dimensions so that the center of the texture aligns with the center of the Canvas
    const FVector2D CrosshairDrawPosition((Center.X),
        (Center.Y));

    // draw the crosshair
    //FCanvasTileItem TileItem(CrosshairDrawPosition, CrosshairTex->Resource, FLinearColor::White);
    //TileItem.BlendMode = SE_BLEND_Translucent;
    //Canvas->DrawItem(TileItem);

    FVector2D RadarCenter(200, 200);// = GetRadarCenterPosition();

    for (float i = 0; i < 360; i+=10.f)
    {
        //We want to draw a circle in order to represent our radar
        //In order to do so, we calculate the sin and cos of almost every degree
        //It it impossible to calculate each and every possible degree because they are infinite
        //Lower the degree step in case you need a more accurate circle representation

        //We multiply our coordinates by radar size 
        //in order to draw a circle with radius equal to the one we will input through the editor
        float fixedX = FMath::Cos(i) * 100.f;
        float fixedY = FMath::Sin(i) * 100.f;

        //Actual draw
        DrawLine(RadarCenter.X, RadarCenter.Y, RadarCenter.X + fixedX, RadarCenter.Y + fixedY, FLinearColor::Gray, 1.f);
    } 
} 