#include "CustomPaintWidget.h"

#undef DrawText

#include "UObject/UObjectGlobals.h"
#include "Blueprint/WidgetBlueprintLibrary.h"
#include "Engine/Font.h"

#include <vector>
#include <numeric>

PerformanceQuery::PerformanceQuery()
{
    PdhOpenQuery(NULL, NULL, &NamedQuery);
    PdhOpenQuery(NULL, NULL, &TotalQuery);

    // You can also use L"\\Processor(*)\\% Processor Time" and get individual CPU values with PdhGetFormattedCounterArray()
    PdhAddEnglishCounter(TotalQuery, L"\\Processor(_Total)\\% Processor Time", NULL, &TotalCounter);
    PdhCollectQueryData(TotalQuery);
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
    PdhCollectQueryData(TotalQuery);
    PdhGetFormattedCounterValue(TotalCounter, PDH_FMT_DOUBLE, NULL, &DisplayValue);
    TotalValue = DisplayValue.doubleValue;
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

    DWORD ProcessIDs[MAX_COUNT];
    DWORD ProcessIDsSize;
    if(EnumProcesses(ProcessIDs, sizeof(ProcessIDs), &ProcessIDsSize))
    {
        DWORD ProcessIDsCount = ProcessIDsSize / sizeof(DWORD);
        for (DWORD ProcessIndex = 0; ProcessIndex < ProcessIDsCount; ++ProcessIndex)
        {
            HANDLE Process = OpenProcess(
                PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
                FALSE,
                ProcessIDs[ProcessIndex]
                );

            if (Process)
            {
                DWORD NeededSize = 0;
                HMODULE Modules[MAX_COUNT];
                if (EnumProcessModulesEx(Process, Modules, sizeof(Modules), &NeededSize, LIST_MODULES_ALL))
                {
                    TCHAR ProcessNameBuffer[MAX_PATH] = {};
                    if(GetModuleBaseName(Process, Modules[0], ProcessNameBuffer, MAX_PATH))
                    {
                        int ProcessNameLength = _tcslen(ProcessNameBuffer);
                        _tcscpy(ProcessNameBuffer + ProcessNameLength - 4, TEXT("\0"));

                        TCHAR ProcessNameWithPrefix[MAX_PATH] = {};
                        _stprintf(ProcessNameWithPrefix, TEXT("%s"), ProcessNameBuffer);

                        for (int Counter = 0; ; ++Counter)
                        {
                            if(Counter > 0)
                            {
                                _stprintf(ProcessNameWithPrefix, TEXT("%s#%d"), ProcessNameBuffer, Counter);
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

                        ProcessNames.push_back(ProcessNameWithPrefix);
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
            
        wsprintf(szCounterName, TEXT("\\Processor(%u)\\%% Processor Time"), index);
        ValidCounterNames.push_back(szCounterName);
            
        wsprintf(szCounterName, TEXT("\\Processor(%u)\\%% Idle Time"), index);
        ValidCounterNames.push_back(szCounterName);
    }

    std::vector<std::wstring> ProcessNames = GetProcessNames();

    for
    (
        auto element = ProcessNames.begin(); 
        element < ProcessNames.end(); 
        element++
    )
    {
        TCHAR szCounterName[MAX_PATH] = {};

        wsprintf(szCounterName, TEXT("\\Process(%s)\\%% Processor Time"), element->c_str());
        ValidCounterNames.push_back(szCounterName);
    }	

    return ValidCounterNames;
}

void UCustomPaintWidget::GetTextLength(UFont* Font, const FString& String, float FontSize, float& SizeX, float& SizeY)
{
    auto FontInfo = Font->GetLegacySlateFontInfo();
    float SizeDevider = FontInfo.Size / FontSize;

    int32 Width, Height;
    Font->GetStringHeightAndWidth(String, Height, Width);
    
    SizeX = float(Width) / SizeDevider;
    SizeY = float(Height) / SizeDevider;
}

UCustomPaintWidget::UCustomPaintWidget(const FObjectInitializer& ObjectInitializer):
    UUserWidget(ObjectInitializer),
    LastQueryDelta(-0.5f),
    ConsoleFont(nullptr),
    Query(new PerformanceQuery)
{
    FpsRateCache.resize(128);
    CpuConsumptionCache.resize(128);

    Query->AddNamedCounter(Query->GetValidCounterNames()[ 0 ]);
}

void UCustomPaintWidget::NativePaint(FPaintContext& InContext) const
{
    UUserWidget::NativePaint(InContext);

    const FVector2D ViewportSize = InContext.AllottedGeometry.Size;

    if (!ConsoleFont)
    {
        GetDefault<UWidgetBlueprintLibrary>()->DrawText(
            InContext,
            "Error: font not set for performace widget",
            FVector2D(ViewportSize.X / 2.0f, ViewportSize.Y / 2.0f),
            FLinearColor::Red
            );

        return;
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

            GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
                InContext,
                FVector2D(XL, Y1),
                FVector2D(XR, Y2),
                FpsColor
                );

            GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
                InContext,
                FVector2D(XL, Y3),
                FVector2D(XR, Y4),
                CpuColor
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

            GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
                InContext,
                FText::FromString(Value),
                FVector2D(XR, YR),
                ConsoleFont,
                ConsoleFontSize,
                ConsoleFontTypeFace,
                FpsColor
                );
        }

        if (CpuConsumptionRounded.size())
        {
            FString Value = FString::Printf(TEXT("CPU: %lld%%"), int(*CpuConsumptionRounded.rbegin()));

            float ValueWidth, ValueHeight;
            GetTextLength(ConsoleFont, Value, ConsoleFontSize, ValueWidth, ValueHeight);

            float XR = ChartMarginX + ChartDensityTime * (CpuConsumptionRounded.size() + 1);
            float YR = LeftPartHeight - ChartMarginY - ChartDensityCpu * *CpuConsumptionRounded.rbegin() - ValueHeight;

            GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
                InContext,
                FText::FromString(Value),
                FVector2D(XR, YR),
                ConsoleFont,
                ConsoleFontSize,
                ConsoleFontTypeFace,
                CpuColor
                );
        }
    }
    //draw arrows
    {
        // ---
        GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
            InContext,
            FVector2D(ChartMarginX, LeftPartHeight - ChartMarginY),
            FVector2D(LeftPartWidth - ChartMarginX, LeftPartHeight - ChartMarginY),
            CpuColor
            );
        // \

        GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
            InContext,
            FVector2D(LeftPartWidth - ChartMarginX, LeftPartHeight - ChartMarginY),
            FVector2D(LeftPartWidth - ChartMarginX - ArrowLength, LeftPartHeight - ChartMarginY - ArrowIndent),
            CpuColor
            );
        // /
        GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
            InContext,
            FVector2D(LeftPartWidth - ChartMarginX, LeftPartHeight - ChartMarginY),
            FVector2D(LeftPartWidth - ChartMarginX - ArrowLength, LeftPartHeight - ChartMarginY + ArrowIndent),
            CpuColor
            );

        // |
        GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
            InContext,
            FVector2D(ChartMarginX, LeftPartHeight - ChartMarginY),
            FVector2D(ChartMarginX, ChartMarginY),
            CpuColor
            );

        // /
        GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
            InContext,
            FVector2D(ChartMarginX, ChartMarginY),
            FVector2D(ChartMarginX - ArrowIndent, ChartMarginY + ArrowLength),
            CpuColor
            );
        // \

        GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
            InContext,
            FVector2D(ChartMarginX, ChartMarginY),
            FVector2D(ChartMarginX + ArrowIndent, ChartMarginY + ArrowLength),
            CpuColor
            );
    }

    //draw arrow hints
    {
        {
            FString Hint = "CPU";
            float SizeX = 0.0f, SizeY = 0.0f;
            GetTextLength(ConsoleFont, Hint, ConsoleFontSize, SizeX, SizeY);

            GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
                InContext,
                FText::FromString(Hint),
                FVector2D(ChartMarginX - 0.01 * ArrowLength - SizeX, ChartMarginY - SizeY),
                ConsoleFont,
                ConsoleFontSize,
                ConsoleFontTypeFace,
                CpuColor
                );
        }

        {
            FString Hint = "FPS";
            float SizeX = 0.0f, SizeY = 0.0f;
            GetTextLength(ConsoleFont, Hint, ConsoleFontSize, SizeX, SizeY);

            GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
                InContext,
                FText::FromString(Hint),
                FVector2D(ChartMarginX + 0.01, ChartMarginY - SizeY),
                ConsoleFont,
                ConsoleFontSize,
                ConsoleFontTypeFace,
                FpsColor
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
                GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
                    InContext,
                    FVector2D(ChartMarginX, LeftPartHeight - ChartMarginY - ChartDensityCpu * Point),
                    FVector2D(ChartMarginX - ArrowIndent / 2.0f - ArrowIndent / 4.0, LeftPartHeight - ChartMarginY - ChartDensityCpu * Point),
                    CpuColor
                    );

                GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
                    InContext,
                    FText::FromString(FString::Printf(TEXT("%lld"), Point)),
                    FVector2D(ChartMarginX - ArrowIndent / 2.0f - ArrowIndent / 4.0, LeftPartHeight - ChartMarginY - ChartDensityCpu * Point),
                    ConsoleFont,
                    StepFontSize,
                    ConsoleFontTypeFace,
                    CpuColor
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

                GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
                    InContext,
                    FVector2D(ChartMarginX, LeftPartHeight - ChartMarginY - ChartDensityFps * Point),
                    FVector2D(ChartMarginX + ArrowIndent / 2.0f + ArrowIndent / 4.0, LeftPartHeight - ChartMarginY - ChartDensityFps * Point),
                    FpsColor
                    );

                GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
                    InContext,
                    FText::FromString(Value),
                    FVector2D(ChartMarginX + ArrowIndent / 2.0f + ArrowIndent / 4.0 - ValueWidth, LeftPartHeight - ChartMarginY - ChartDensityFps * Point),
                    ConsoleFont,
                    StepFontSize,
                    ConsoleFontTypeFace,
                    FpsColor
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
                GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
                    InContext,
                    FText::FromString(std::get<0>(*Message)),
                    FVector2D(LeftPartWidth, MessageIndex * 2 * ConsoleFontSize),
                    ConsoleFont,
                    ConsoleFontSize,
                    ConsoleFontTypeFace,
                    ConsoleFontColor
                    );
            }
            else
            {
                GetDefault<UWidgetBlueprintLibrary>()->DrawText(
                    InContext,
                    std::get<0>(*Message),
                    FVector2D(LeftPartWidth, MessageIndex * (LeftPartHeight / 11.0f)),
                    CpuColor
                    );
            }
        }
    }
}

void UCustomPaintWidget::NativeTick(const FGeometry& MyGeometry, float InDeltaTime)
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

void UCustomPaintWidget::AddMessage(const FString& Message)
{
    ConsoleMessages.push_back(std::make_tuple(Message, FDateTime::Now()));
}

void UCustomPaintWidget::SetConsoleFont(UFont* Font, int32 FontSize, FName FontTypeFace, FLinearColor Tint, int32 DelaySeconds)
{
    ConsoleFont = Font;
    ConsoleFontSize = FontSize;
    ConsoleFontTypeFace = FontTypeFace;
    ConsoleFontColor = Tint;
    ConsoleDelaySeconds = DelaySeconds;
}