#include "PerformanceChartWidget.h"

#undef DrawText

#include "UObject/UObjectGlobals.h"
#include "Blueprint/WidgetBlueprintLibrary.h"
#include "Rendering/DrawElements.h"
#include "Styling/CoreStyle.h"
#include "Engine/Font.h"

#include <vector>
#include <numeric>

PerformanceQuery::PerformanceQuery()
{
    PdhOpenQuery(NULL, NULL, &NamedQuery);
    //PdhOpenQuery(NULL, NULL, &TotalQuery);

    // You can also use L"\\Processor(*)\\% Processor Time" and get individual CPU values with PdhGetFormattedCounterArray()
    //PdhAddEnglishCounter(TotalQuery, L"\\Processor(_Total)\\% Processor Time", NULL, &TotalCounter);
    //PdhCollectQueryData(TotalQuery);
}

void PerformanceQuery::AddNamedCounter(const std::wstring& Name)
{
    PDH_STATUS Status = {};
    CounterInfo CI = {};
    CI.CounterName = Name;
    PdhAddCounter(NamedQuery, CI.CounterName.c_str(), 0 , &CI.Counter);

    NamedCounters.push_back(CI);
}

void PerformanceQuery::Query()
{
    ULONG CounterType = {};
    PDH_FMT_COUNTERVALUE DisplayValue = {};

    //ask named consumptions
    PdhCollectQueryData(NamedQuery);
    for(auto Iterator = NamedCounters.begin(); Iterator < NamedCounters.end(); ++Iterator)
    {
        PdhGetFormattedCounterValue(Iterator->Counter, PDH_FMT_DOUBLE, &CounterType, &DisplayValue);			
        Iterator->Value = DisplayValue.doubleValue;
    }

    //ask total consumption
    //PdhCollectQueryData(TotalQuery);
    //PdhGetFormattedCounterValue(TotalCounter, PDH_FMT_DOUBLE, NULL, &DisplayValue);
    //TotalValue = DisplayValue.doubleValue;
}

DWORD PerformanceQuery::GetProcessorsCount()
{
    SYSTEM_INFO SystemInfo = {};
    GetSystemInfo(&SystemInfo);

    return SystemInfo.dwNumberOfProcessors;
}

std::vector<std::wstring> PerformanceQuery::GetProcessNames()
{
    const int MAX_COUNT = 1024;

    std::vector<std::wstring> ProcessNames;

    auto CurrentProcessID = GetCurrentProcessId();

    DWORD ProcessIDs[MAX_COUNT];
    DWORD ProcessIDsSize = 0;
    if(EnumProcesses(ProcessIDs, sizeof(ProcessIDs), &ProcessIDsSize))
    {
        DWORD ProcessIDsCount = ProcessIDsSize / sizeof(DWORD);
        for (DWORD ProcessIndex = 0; ProcessIndex < ProcessIDsCount; ++ProcessIndex)
        {
            HANDLE ProcessHandle = OpenProcess(
                PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
                FALSE,
                ProcessIDs[ProcessIndex]
                );

            if (ProcessHandle)
            {
                DWORD NeededSize = 0;
                HMODULE Modules[MAX_COUNT];
                if (EnumProcessModulesEx(ProcessHandle, Modules, sizeof(Modules), &NeededSize, LIST_MODULES_ALL))
                {
                    TCHAR ProcessNameBuffer[MAX_PATH] = {};
                    if(GetModuleBaseName(ProcessHandle, Modules[0], ProcessNameBuffer, MAX_PATH))
                    {
                        int ProcessNameLength = _tcslen(ProcessNameBuffer);
                        _tcscpy_s(ProcessNameBuffer + ProcessNameLength - 4, MAX_PATH - ProcessNameLength + 4, TEXT("\0"));

                        TCHAR ProcessNameWithPrefix[MAX_PATH] = {};
                        _stprintf_s(ProcessNameWithPrefix, MAX_PATH, TEXT("%s"), ProcessNameBuffer);

                        for (int Counter = 0; ; ++Counter)
                        {
                            if(Counter > 0)
                            {
                                _stprintf_s(ProcessNameWithPrefix, MAX_PATH, TEXT("%s#%d"), ProcessNameBuffer, Counter);
                            }

                            bool ProcessExists = false;
                            for(auto ProcessName = ProcessNames.begin(); ProcessName < ProcessNames.end(); ++ProcessName)
                            {
                                if(!ProcessName->compare(ProcessNameWithPrefix))
                                {
                                    ProcessExists = true;

                                    break;
                                }
                            }

                            if (!ProcessExists)
                            {
                                break;
                            }
                        }

                        if (ProcessIDs[ProcessIndex] == CurrentProcessID)
                        {
                            ProcessNames.insert(ProcessNames.begin(), ProcessNameWithPrefix);
                        }
                        else
                        {
                            ProcessNames.push_back(ProcessNameWithPrefix);
                        }
                    }
                }
            }
        }
    }
        
    return ProcessNames;
}

std::vector<std::wstring> PerformanceQuery::GetValidCounterNames()
{
    std::vector<std::wstring> ValidCounterNames;

    ValidCounterNames.push_back(TEXT("\\Processor(_Total)\\% Processor Time"));
    ValidCounterNames.push_back(TEXT("\\Processor(_Total)\\% Idle Time"));

    DWORD dwNumberOfProcessors = GetProcessorsCount();

    for(DWORD index = 0; index < dwNumberOfProcessors; index++ )
    {
        TCHAR szCounterName[MAX_PATH] = {};
            
        _stprintf_s(szCounterName, MAX_PATH, TEXT("\\Processor(%u)\\%% Processor Time"), unsigned(index));
        ValidCounterNames.push_back(szCounterName);
            
        _stprintf_s(szCounterName, MAX_PATH, TEXT("\\Processor(%u)\\%% Idle Time"), unsigned(index));
        ValidCounterNames.push_back(szCounterName);
    }

    auto ProcessNames = GetProcessNames();

    for
    (
        auto element = ProcessNames.begin(); 
        element < ProcessNames.end(); 
        element++
    )
    {
        TCHAR szCounterName[MAX_PATH] = {};

        _stprintf_s(szCounterName, MAX_PATH, TEXT("\\Process(%s)\\%% Processor Time"), element->c_str());
        ValidCounterNames.push_back(szCounterName);
    }	

    return ValidCounterNames;
}

void UPerformanceChartWidget::GetTextLength(UFont* Font, const FString& String, float FontSize, float& SizeX, float& SizeY)
{
    auto FontInfo = Font->GetLegacySlateFontInfo();
    float SizeDevider = FontInfo.Size / FontSize;

    int32 Width, Height;
    Font->GetStringHeightAndWidth(String, Height, Width);
    
    SizeX = float(Width) / SizeDevider;
    SizeY = float(Height) / SizeDevider;
}

void UPerformanceChartWidget::DrawLine(FVector2D PositionA, FVector2D PositionB, FLinearColor Tint, bool bAntiAlias, int32 LayerId, const FGeometry& AllottedGeometry, FSlateWindowElementList& OutDrawElements)
{
    TArray<FVector2D> Points;
    Points.Add(PositionA);
    Points.Add(PositionB);

    FSlateDrawElement::MakeLines(
        OutDrawElements,
        LayerId,
        AllottedGeometry.ToPaintGeometry(),
        Points,
        ESlateDrawEffect::None,
        Tint,
        bAntiAlias
        );
}

void UPerformanceChartWidget::DrawText(const FString& InString, FVector2D Position, FLinearColor Tint, int32 LayerId, const FGeometry& AllottedGeometry, FSlateWindowElementList& OutDrawElements)
{
    //Context.MaxLayer++;

    //TODO UMG Create a font asset usable as a UFont or as a slate font asset.
    FSlateFontInfo FontInfo = FCoreStyle::Get().GetWidgetStyle<FTextBlockStyle>("NormalText").Font;

    FSlateDrawElement::MakeText(
        OutDrawElements,
        LayerId,
        AllottedGeometry.ToOffsetPaintGeometry(Position),
        InString,
        FontInfo,
        ESlateDrawEffect::None,
        Tint
        );
}

void UPerformanceChartWidget::DrawTextFormatted(const FText& Text, FVector2D Position, UFont* Font, int32 FontSize, FName FontTypeFace, FLinearColor Tint, int32 LayerId, const FGeometry& AllottedGeometry, FSlateWindowElementList& OutDrawElements)
{
    if ( Font )
    {
        //Context.MaxLayer++;

        //TODO UMG Create a font asset usable as a UFont or as a slate font asset.
        FSlateFontInfo FontInfo(Font, FontSize, FontTypeFace);

        FSlateDrawElement::MakeText(
            OutDrawElements,
            LayerId,
            AllottedGeometry.ToOffsetPaintGeometry(Position),
            Text,
            FontInfo,
            ESlateDrawEffect::None,
            Tint
            );
    }
}

UPerformanceChartWidget::UPerformanceChartWidget(const FObjectInitializer& ObjectInitializer):
    UUserWidget(ObjectInitializer),
    Query(new PerformanceQuery),
    ConsoleFont(nullptr),
    LastQueryDelta(-0.5f)
{
    FpsRateCache.resize(128);
    CpuConsumptionCache.resize(128);

    Query->AddNamedCounter(Query->GetValidCounterNames()[ 0 ]);
}

//void UPerformanceChartWidget::NativePaint(FPaintContext& InContext) const
int32 UPerformanceChartWidget::NativePaint(const FPaintArgs& Args, const FGeometry& AllottedGeometry, const FSlateRect& MyCullingRect, FSlateWindowElementList& OutDrawElements, int32 LayerId, const FWidgetStyle& InWidgetStyle, bool bParentEnabled) const
{
    UUserWidget::NativePaint(Args, AllottedGeometry, MyCullingRect, OutDrawElements, LayerId, InWidgetStyle, bParentEnabled);

    const FVector2D ViewportSize = AllottedGeometry.Size;

    if (!ConsoleFont)
    {
        DrawText(
            "Error: font not set for performace widget",
            FVector2D(ViewportSize.X / 2.0f, ViewportSize.Y / 2.0f),
            FLinearColor::Red,
            ++LayerId,
            AllottedGeometry,
            OutDrawElements
            );

        return LayerId;
    }

    //count frames
    {
        auto Now = FDateTime::Now();
        auto CounterStartDelta = Now - FrameCounterStart;
        static auto OneSecond = FTimespan(0, 0, 1);

        if (CounterStartDelta >= OneSecond)
        {
            auto Fps = double(FrameCounter) / CounterStartDelta.GetTotalSeconds();
            FrameCount = Fps;
            FrameCounter = 0;
            FrameCounterStart = Now;
        }
        else
        {
            ++FrameCounter;
        }
    }

    float LeftPartWidth = 2 * ViewportSize.X / 3;// InContext.MyCullingRect.Right - InContext.MyCullingRect.Left;
    float LeftPartHeight = ViewportSize.Y;

    float ArrowLength = LeftPartWidth / 20.0f;
    float ArrowIndent = LeftPartWidth / 40.0f;

    float ChartWidth = 2.0f * LeftPartWidth / 3.0f;
    float ChartHeight = 6.0f * LeftPartHeight / 8.0f;
    float ChartMarginX = LeftPartWidth / 12.0f;
    float ChartMarginY = LeftPartHeight / 8.0f;

    float ChartDensityTime = float(ChartWidth) / (ChartCapacityTime + 1);
    float ChartDensityCpu = ( ChartHeight - 1.01f * ArrowLength ) / ChartCapacityCpu;
    float ChartDensityFps = ( ChartHeight - 1.01f * ArrowLength ) / ChartCapacityFps;

    //draw values chart
    {
        auto CpuIterator = CpuConsumptionRounded.begin();
        auto FpsIterator = FpsRateRounded.begin();
        int PointIndex = 0;

        for
        (
            ;
            (FpsRate.size() > 1) && (PointIndex < FpsRate.size() - 1);
            ++PointIndex
        )
        {
            float XL = ChartMarginX + ChartDensityTime * PointIndex;
            float XR = ChartMarginX + ChartDensityTime * (PointIndex + 1);

            float Y1 = LeftPartHeight - ChartMarginY - ChartDensityFps * *FpsIterator;
            float Y2 = LeftPartHeight - ChartMarginY - ChartDensityFps * *++FpsIterator;

            float Y3 = LeftPartHeight - ChartMarginY - ChartDensityCpu * *CpuIterator;
            float Y4 = LeftPartHeight - ChartMarginY - ChartDensityCpu * *++CpuIterator;

            DrawLine(
                FVector2D(XL, Y1),
                FVector2D(XR, Y2),
                FpsColor,
                true,
                ++LayerId,
                AllottedGeometry,
                OutDrawElements
                );

            DrawLine(
                FVector2D(XL, Y3),
                FVector2D(XR, Y4),
                CpuColor,
                true,
                ++LayerId,
                AllottedGeometry,
                OutDrawElements
                );
        }
    }

    //draw last (current) values
    {
        if (FpsRateRounded.size())
        {
            FString Value = FString::Printf(TEXT("FPS: %lld"), int(*FpsRateRounded.rbegin()));

            float ValueWidth, ValueHeight;
            GetTextLength(ConsoleFont, Value, ConsoleFontSize, ValueWidth, ValueHeight);

            float XR = ChartMarginX + ChartDensityTime * (FpsRateRounded.size() + 1);
            float YR = LeftPartHeight - ChartMarginY - ChartDensityFps * *FpsRateRounded.rbegin() - ValueHeight;

            DrawTextFormatted(
                FText::FromString(Value),
                FVector2D(XR, YR),
                ConsoleFont,
                ConsoleFontSize,
                ConsoleFontTypeFace,
                FpsColor,
                ++LayerId,
                AllottedGeometry,
                OutDrawElements
                );
        }

        if (CpuConsumptionRounded.size())
        {
            FString Value = FString::Printf(TEXT("CPU: %lld%%"), int(*CpuConsumptionRounded.rbegin()));

            float ValueWidth, ValueHeight;
            GetTextLength(ConsoleFont, Value, ConsoleFontSize, ValueWidth, ValueHeight);

            float XR = ChartMarginX + ChartDensityTime * (CpuConsumptionRounded.size() + 1);
            float YR = LeftPartHeight - ChartMarginY - ChartDensityCpu * *CpuConsumptionRounded.rbegin() - ValueHeight;

            DrawTextFormatted(
                FText::FromString(Value),
                FVector2D(XR, YR),
                ConsoleFont,
                ConsoleFontSize,
                ConsoleFontTypeFace,
                CpuColor,
                ++LayerId,
                AllottedGeometry,
                OutDrawElements
                );
        }
    }
    //draw arrows
    {
        // ---
        DrawLine(
            FVector2D(ChartMarginX, LeftPartHeight - ChartMarginY),
            FVector2D(LeftPartWidth - ChartMarginX, LeftPartHeight - ChartMarginY),
            CpuColor,
            true,
            ++LayerId,
            AllottedGeometry,
            OutDrawElements
            );
        // \

        DrawLine(
            FVector2D(LeftPartWidth - ChartMarginX, LeftPartHeight - ChartMarginY),
            FVector2D(LeftPartWidth - ChartMarginX - ArrowLength, LeftPartHeight - ChartMarginY - ArrowIndent),
            CpuColor,
            true,
            ++LayerId,
            AllottedGeometry,
            OutDrawElements
            );
        // /
        DrawLine(
            FVector2D(LeftPartWidth - ChartMarginX, LeftPartHeight - ChartMarginY),
            FVector2D(LeftPartWidth - ChartMarginX - ArrowLength, LeftPartHeight - ChartMarginY + ArrowIndent),
            CpuColor,
            true,
            ++LayerId,
            AllottedGeometry,
            OutDrawElements
            );

        // |
        DrawLine(
            FVector2D(ChartMarginX, LeftPartHeight - ChartMarginY),
            FVector2D(ChartMarginX, ChartMarginY),
            CpuColor,
            true,
            ++LayerId,
            AllottedGeometry,
            OutDrawElements
            );

        // /
        DrawLine(
            FVector2D(ChartMarginX, ChartMarginY),
            FVector2D(ChartMarginX - ArrowIndent, ChartMarginY + ArrowLength),
            CpuColor,
            true,
            ++LayerId,
            AllottedGeometry,
            OutDrawElements
            );
        // \

        DrawLine(
            FVector2D(ChartMarginX, ChartMarginY),
            FVector2D(ChartMarginX + ArrowIndent, ChartMarginY + ArrowLength),
            CpuColor,
            true,
            ++LayerId,
            AllottedGeometry,
            OutDrawElements
            );
    }

    //draw arrow hints
    {
        {
            FString Hint = "CPU";
            float SizeX = 0.0f, SizeY = 0.0f;
            GetTextLength(ConsoleFont, Hint, ConsoleFontSize, SizeX, SizeY);

            DrawTextFormatted(
                FText::FromString(Hint),
                FVector2D(ChartMarginX - 0.01 * ArrowLength - SizeX, ChartMarginY - SizeY),
                ConsoleFont,
                ConsoleFontSize,
                ConsoleFontTypeFace,
                CpuColor,
                ++LayerId,
                AllottedGeometry,
                OutDrawElements
                );
        }

        {
            FString Hint = "FPS";
            float SizeX = 0.0f, SizeY = 0.0f;
            GetTextLength(ConsoleFont, Hint, ConsoleFontSize, SizeX, SizeY);

            DrawTextFormatted(
                FText::FromString(Hint),
                FVector2D(ChartMarginX + 0.01, ChartMarginY - SizeY),
                ConsoleFont,
                ConsoleFontSize,
                ConsoleFontTypeFace,
                FpsColor,
                ++LayerId,
                AllottedGeometry,
                OutDrawElements
                );
        }
    }

    //draw measurements
    {
        float StepFontSize = ConsoleFontSize / 2.0f;

        for (int Point = 10; ; Point += 10)
        {
            if (Point < ChartCapacityCpu)
            {
                DrawLine(
                    FVector2D(ChartMarginX, LeftPartHeight - ChartMarginY - ChartDensityCpu * Point),
                    FVector2D(ChartMarginX - ArrowIndent / 2.0f - ArrowIndent / 4.0, LeftPartHeight - ChartMarginY - ChartDensityCpu * Point),
                    CpuColor,
                    true,
                    ++LayerId,
                    AllottedGeometry,
                    OutDrawElements
                    );

                DrawTextFormatted(
                    FText::FromString(FString::Printf(TEXT("%lld"), Point)),
                    FVector2D(ChartMarginX - ArrowIndent / 2.0f - ArrowIndent / 4.0, LeftPartHeight - ChartMarginY - ChartDensityCpu * Point),
                    ConsoleFont,
                    StepFontSize,
                    ConsoleFontTypeFace,
                    CpuColor,
                    ++LayerId,
                    AllottedGeometry,
                    OutDrawElements
                    );
            }
            else
            {
                if (ChartCapacityCpu > ChartCapacityFps)
                {
                    break;
                }
            }

            if (Point < ChartCapacityFps)
            {
                FString Value = FString::Printf(TEXT("%lld"), Point);

                float ValueWidth, ValueHeight;
                GetTextLength(ConsoleFont, Value, StepFontSize, ValueWidth, ValueHeight);

                DrawLine(
                    FVector2D(ChartMarginX, LeftPartHeight - ChartMarginY - ChartDensityFps * Point),
                    FVector2D(ChartMarginX + ArrowIndent / 2.0f + ArrowIndent / 4.0, LeftPartHeight - ChartMarginY - ChartDensityFps * Point),
                    FpsColor,
                    true,
                    ++LayerId,
                    AllottedGeometry,
                    OutDrawElements
                    );

                DrawTextFormatted(
                    FText::FromString(Value),
                    FVector2D(ChartMarginX + ArrowIndent / 2.0f + ArrowIndent / 4.0 - ValueWidth, LeftPartHeight - ChartMarginY - ChartDensityFps * Point),
                    ConsoleFont,
                    StepFontSize,
                    ConsoleFontTypeFace,
                    FpsColor,
                    ++LayerId,
                    AllottedGeometry,
                    OutDrawElements
                    );
            }
            else
            {
                if (ChartCapacityFps > ChartCapacityCpu)
                {
                    break;
                }
            }
        }
    }
    
    //draw console messages
    {
        int MessageIndex = 0;

        for (auto Message = ConsoleMessages.rbegin(); Message != ConsoleMessages.rend(); ++Message, ++MessageIndex)
        {
            if (ConsoleFont)
            {
                DrawTextFormatted(
                    FText::FromString(std::get<0>(*Message)),
                    FVector2D(LeftPartWidth/3, MessageIndex * 2 * ConsoleFontSize),
                    ConsoleFont,
                    ConsoleFontSize,
                    ConsoleFontTypeFace,
                    ConsoleFontColor,
                    ++LayerId,
                    AllottedGeometry,
                    OutDrawElements
                    );
            }
            else
            {
                DrawText(
                    std::get<0>(*Message),
                    FVector2D(LeftPartWidth/3, MessageIndex * (LeftPartHeight / 11.0f)),
                    CpuColor,
                    ++LayerId,
                    AllottedGeometry,
                    OutDrawElements
                    );
            }
        }
    }

    return LayerId;
}

void UPerformanceChartWidget::NativeTick(const FGeometry& MyGeometry, float InDeltaTime)
{
    UUserWidget::NativeTick(MyGeometry, InDeltaTime);

    if (FpsRate.size() == ChartCapacityTime)
    {
        FpsRate.pop_front();
        FpsRateRounded.pop_front();

        CpuConsumption.pop_front();
        CpuConsumptionRounded.pop_front();
    }

    float CurrentFps = FrameCount;
    FpsRateCache.push_back(CurrentFps);
    
    if (!SkipFirstFrame && (LastQueryDelta < 0) || (LastQueryDelta >= ChartResolution))
    {
        Query->Query();

        float CurrentCpuConsumption = Query->NamedCounters[0].Value;
        //CpuConsumptionCache.push_back(CurrentCpuConsumption);

        LastQueryDelta = 0.0;

        {
            FpsRate.push_back(int(std::accumulate(FpsRateCache.begin(), FpsRateCache.end(), 0.0f) / float(FpsRateCache.size())));
            FpsRateCache.resize(0);

            /*if (FpsRate.size() >= RoundingWindow)
            {
                auto Element = FpsRate.rbegin();
                float Rounded = *Element++;
                for (int Index = 2; Index < RoundingWindow; ++Index)
                {
                    Rounded += *Element++;
                }
                FpsRateRounded.push_back(Rounded/float(RoundingWindow));
            }
            else*/
            {
                FpsRateRounded.push_back(*FpsRate.rbegin());
            }
        }

        {
            CpuConsumption.push_back(CurrentCpuConsumption);
            //CpuConsumption.push_back(int(std::accumulate(CpuConsumptionCache.begin(), CpuConsumptionCache.end(), 0.0f) / float(CpuConsumptionCache.size())));
            //CpuConsumptionCache.resize(0);

            /*if (CpuConsumption.size() >= RoundingWindow)
            {
                auto Element = CpuConsumption.rbegin();
                float Rounded = *Element++;
                for (int Index = 2; Index < RoundingWindow; ++Index)
                {
                    Rounded += *Element++;
                }
                CpuConsumptionRounded.push_back(Rounded/float(RoundingWindow));
            }
            else*/
            {
                CpuConsumptionRounded.push_back(*CpuConsumption.rbegin());
            }
        }

        {
            auto ToRemoveEnd = ConsoleMessages.end();

            for (auto MessageIterator = ConsoleMessages.begin(); MessageIterator != ConsoleMessages.end(); ++MessageIterator)
            {
                auto Now = FDateTime::Now();
                auto FinishTime = std::get<1>(*MessageIterator) + FTimespan(0, 0, ConsoleDelaySeconds);
                
                if (FinishTime < Now)
                {
                    ToRemoveEnd = MessageIterator;
                }
                else
                {
                    break;
                }
            }

            if (ConsoleMessages.end() != ToRemoveEnd)
            {
                ConsoleMessages.erase(ConsoleMessages.begin(), ++ToRemoveEnd);
            }
        }
    }
    else
    {
        LastQueryDelta += InDeltaTime;
    }
}

void UPerformanceChartWidget::AddMessage(const FString& Message)
{
    ConsoleMessages.push_back(std::make_tuple(Message, FDateTime::Now()));
}

void UPerformanceChartWidget::SetConsoleFont(UFont* Font, int32 FontSize, FName FontTypeFace, FLinearColor Tint, int32 DelaySeconds)
{
    ConsoleFont = Font;
    ConsoleFontSize = FontSize;
    ConsoleFontTypeFace = FontTypeFace;
    ConsoleFontColor = Tint;
    ConsoleDelaySeconds = DelaySeconds;
}