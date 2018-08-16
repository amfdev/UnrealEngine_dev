#include "CustomPaintWidget.h"

#include "windows.h"
#include "psapi.h"
#include "pdh.h"
#pragma comment(lib, "Pdh.lib")

#undef DrawText

#include "UObject/UObjectGlobals.h"
#include "Blueprint/WidgetBlueprintLibrary.h"
#include "Engine/Font.h"

#include <vector>
#include <numeric>

static PDH_HQUERY cpuQuery;
static PDH_HCOUNTER cpuTotal;

void init(){
    PdhOpenQuery(NULL, NULL, &cpuQuery);
    // You can also use L"\\Processor(*)\\% Processor Time" and get individual CPU values with PdhGetFormattedCounterArray()
    PdhAddEnglishCounter(cpuQuery, L"\\Processor(_Total)\\% Processor Time", NULL, &cpuTotal);
    PdhCollectQueryData(cpuQuery);
}

double getCurrentValue(){
    PDH_FMT_COUNTERVALUE counterVal;

    PdhCollectQueryData(cpuQuery);
    PdhGetFormattedCounterValue(cpuTotal, PDH_FMT_DOUBLE, NULL, &counterVal);
    return counterVal.doubleValue;
}

DWORD GetProcessorCount() 
{ 
    SYSTEM_INFO sysinfo;  
    DWORD dwNumberOfProcessors; 


    GetSystemInfo(&sysinfo); 


    dwNumberOfProcessors = sysinfo.dwNumberOfProcessors; 


    return dwNumberOfProcessors; 
}

class Log
{
public:
    DWORD time;
    double value;
};

class CounterInfo
{
public:
    PCWSTR counterName;

    PDH_HCOUNTER counter;

    std::vector<Log> logs;
};

#define SIZE 1024

#define SAMPLE_INTERVAL 1

DWORD GetProcessorCount_()
{
    SYSTEM_INFO sysinfo; 
    DWORD dwNumberOfProcessors;

    GetSystemInfo(&sysinfo);

    dwNumberOfProcessors = sysinfo.dwNumberOfProcessors;

    return dwNumberOfProcessors;
}

std::vector<PCTSTR> GetProcessNames()
{
    DWORD dwProcessID[SIZE];
    DWORD cbProcess;
    DWORD cProcessID;
    BOOL fResult = FALSE;
    DWORD index;

    HANDLE hProcess;
    HMODULE lphModule[SIZE];
    DWORD cbNeeded;	
    int len;

    std::vector<PCTSTR> vProcessNames;

    TCHAR * szProcessName;
    TCHAR * szProcessNameWithPrefix;

    fResult = EnumProcesses(dwProcessID, sizeof(dwProcessID), &cbProcess);

    if(!fResult)
    {
        goto cleanup;
    }

    cProcessID = cbProcess / sizeof(DWORD);

    for( index = 0; index < cProcessID; index++ )
    {
        szProcessName = new TCHAR[MAX_PATH];		
        hProcess = OpenProcess( PROCESS_QUERY_INFORMATION |
            PROCESS_VM_READ,
            FALSE, dwProcessID[index] );
        if( NULL != hProcess )
        {
            if ( EnumProcessModulesEx( hProcess, lphModule, sizeof(lphModule), 
                &cbNeeded,LIST_MODULES_ALL) )
            {
                if( GetModuleBaseName( hProcess, lphModule[0], szProcessName, 
                    MAX_PATH ) )
                {
                    len = _tcslen(szProcessName);
                    _tcscpy(szProcessName+len-4, TEXT("\0"));

                    bool fProcessExists = false;
                    int count = 0;
                    szProcessNameWithPrefix = new TCHAR[MAX_PATH];
                    _stprintf(szProcessNameWithPrefix, TEXT("%s"), szProcessName);
                    do
                    {
                        if(count>0)
                        {
                            _stprintf(szProcessNameWithPrefix,TEXT("%s#%d"),szProcessName,count);
                        }
                        fProcessExists = false;
                        for(auto it = vProcessNames.begin(); it < vProcessNames.end(); it++)
                        {
                            if(_tcscmp(*it,szProcessNameWithPrefix)==0)
                            {
                                fProcessExists = true;
                                break;
                            }
                        }					
                        count++;
                    }
                    while(fProcessExists);

                    vProcessNames.push_back(szProcessNameWithPrefix);
                }
            }
        }
    }

cleanup:
    szProcessName = NULL;
    szProcessNameWithPrefix = NULL;
    return vProcessNames;
}

std::vector<PCTSTR> GetValidCounterNames()
{
    std::vector<PCTSTR> validCounterNames;
    DWORD dwNumberOfProcessors = GetProcessorCount_();
    DWORD index;
    std::vector<PCTSTR> vszProcessNames;
    TCHAR * szCounterName;

    validCounterNames.push_back(TEXT("\\Processor(_Total)\\% Processor Time"));
    validCounterNames.push_back(TEXT("\\Processor(_Total)\\% Idle Time"));

    for( index = 0; index < dwNumberOfProcessors; index++ )
    {
        szCounterName = new TCHAR[MAX_PATH];
        wsprintf(szCounterName, TEXT("\\Processor(%u)\\%% Processor Time"),index);
        validCounterNames.push_back(szCounterName);
        szCounterName = new TCHAR[MAX_PATH];
        wsprintf(szCounterName, TEXT("\\Processor(%u)\\%% Idle Time"),index);
        validCounterNames.push_back(szCounterName);
    }

    vszProcessNames = GetProcessNames();

    for(auto element = vszProcessNames.begin(); 
        element < vszProcessNames.end(); 
        element++ )
    {
        szCounterName = new TCHAR[MAX_PATH];
        wsprintf(szCounterName, TEXT("\\Process(%s)\\%% Processor Time"),*element);
        validCounterNames.push_back(szCounterName);
    }	

    //cleanup:
    szCounterName = NULL;
    return validCounterNames;
}

class Query
{
private:
    PDH_HQUERY query;

    HANDLE Event;

    int time;

    bool fIsWorking;

public:
    std::vector<CounterInfo> vciSelectedCounters;

    Query();

    void Init();

    void AddCounterInfo(PCWSTR name);

    void Record();

    int CleanOldRecord()
    {
        if(time>100)
        {
            for(auto it = vciSelectedCounters.begin(); it < vciSelectedCounters.end(); it++ )
            {
                if(it->logs.size()>100)
                {
                    it->logs.erase(it->logs.begin());
                }
            }
            return time-100;
        }
        else
        {
            return 0;
        }
    }
};

Query::Query()
{
}

void Query::Init()
{
    fIsWorking = false;

    time = 0;

    PDH_STATUS status;

    status = PdhOpenQuery(NULL, 0, &query);

    if(status != ERROR_SUCCESS)
    {
        return;
    }

    Event = CreateEvent(NULL, FALSE, FALSE, L"MyEvent");

    if(Event == NULL)
    {
        return;
    }

    fIsWorking = true;
}

void Query::AddCounterInfo(PCWSTR name)
{
    if(fIsWorking)
    {
        PDH_STATUS status;
        CounterInfo ci;
        ci.counterName = name;
        status = PdhAddCounter(query, ci.counterName, 0 , &ci.counter);

        if(status != ERROR_SUCCESS)
        {
            return;
        }

        vciSelectedCounters.push_back(ci);
    }
}

void Query::Record()
{
    PDH_STATUS status;
    ULONG CounterType;
    //ULONG WaitResult;
    PDH_FMT_COUNTERVALUE DisplayValue;	

    status = PdhCollectQueryData(query);

    if(status != ERROR_SUCCESS)
    {
        return;
    }

    /*status = PdhCollectQueryDataEx(query, SAMPLE_INTERVAL, Event);

    if(status != ERROR_SUCCESS)
    {
        return;
    }

    WaitResult = WaitForSingleObject(Event, INFINITE);

    if (WaitResult == WAIT_OBJECT_0) */
    {
        for(auto it = vciSelectedCounters.begin(); it < vciSelectedCounters.end(); it++)
        {
            status = PdhGetFormattedCounterValue(it->counter, PDH_FMT_DOUBLE, &CounterType, &DisplayValue);			

            /*if(status != ERROR_SUCCESS)
            {
                continue;
            }*/

            Log log;
            log.time = time;
            log.value = DisplayValue.doubleValue;
            it->logs.push_back(log);				
        }
    }

    time++;
}

Query query;

struct ConsumptionHelper
{
    ConsumptionHelper()
    {
        init();
        query.Init();

        auto names = GetValidCounterNames();
        query.AddCounterInfo(names[0]);
    }
};

static ConsumptionHelper consumptionHelper;

void UCustomPaintWidget::GetTextLength(UFont* Font, const FString& String, float FontSize, float& SizeX, float& SizeY)
{
    auto FontInfo = Font->GetLegacySlateFontInfo();
    float SizeDevider = FontInfo.Size / FontSize;

    int32 Width, Height;
    Font->GetStringHeightAndWidth(String, Height, Width);
    
    SizeX = float(Width) / SizeDevider;
    SizeY = float(Height) / SizeDevider;
}

int ChartCapacity = 200;
float ChartResolution = 0.999f;
FLinearColor FpsColor = FLinearColor::Blue;
FLinearColor CpuColor = FLinearColor::White;

UCustomPaintWidget::UCustomPaintWidget(const FObjectInitializer& ObjectInitializer):
    UUserWidget(ObjectInitializer),
    LastQueryDelta(-0.5f),
    ConsoleFont(nullptr),
    ConsoleDelaySeconds(12),
    RoundingWindow(5)
{
    FpsRateCache.resize(128);
    CpuConsumptionCache.resize(128);
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

    auto Now = FDateTime::Now();
    auto CounterStartDelta = Now - FrameCounterStart;
    static auto OneSecond = FTimespan(0, 0, 1);

    if (CounterStartDelta >= OneSecond)
    {
        auto Fps = double(FrameCounter) / CounterStartDelta.GetTotalSeconds();
        FrameCount = Fps;//int(Fps);
        FrameCounter = 0;
        FrameCounterStart = Now;
    }
    else
    {
        ++FrameCounter;
    }    

    float ChartWidth = 2 * ViewportSize.X / 3;// InContext.MyCullingRect.Right - InContext.MyCullingRect.Left;
    float ChartHeight = ViewportSize.Y;

    float ArrowLength = ChartWidth / 20.0f;
    float ArrowIndent = ChartWidth / 40.0f;

    int Bottom = ChartHeight;
    int Right = ChartWidth;

    float Part1Width = 2.0f * ChartWidth / 3.0f;
    float Part1Height = 6.0f * ChartHeight / 8.0f;

    float Part2Width = ChartWidth / 3.0f;
    
    float Part1CapacityX = ChartCapacity + 1;
    float Part1CapacityCpu = 110.0f;
    float Part1CapacityFps = 130.0f;

    float Part1RateX = Part1Width / Part1CapacityX;
    float Part1RateYCpu = ( ChartHeight - 1.01f * ArrowLength ) / Part1CapacityCpu;
    float Part1RateYFps = ( ChartHeight - 1.01f * ArrowLength ) / Part1CapacityFps;

    float Part1IndentX = ChartWidth / 12.0f;
    float Part1IndentY = ChartHeight / 8.0f;

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
        float XL = Part1IndentX + Part1RateX * PointIndex;
        float XR = Part1IndentX + Part1RateX * (PointIndex + 1);

        float Y1 = ChartHeight - Part1IndentY - Part1RateYFps * *FpsIterator;
        float Y2 = ChartHeight - Part1IndentY - Part1RateYFps * *++FpsIterator;

        float Y3 = ChartHeight - Part1IndentY - Part1RateYCpu * *CpuIterator;
        float Y4 = ChartHeight - Part1IndentY - Part1RateYCpu * *++CpuIterator;

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

    if(FpsRateRounded.size())
    {
        FString Value = FString::Printf(TEXT("FPS: %lld"), int(*FpsRateRounded.rbegin()));

        float ValueWidth, ValueHeight;
        GetTextLength(ConsoleFont, Value, ConsoleFontSize, ValueWidth, ValueHeight);

        float XR = Part1IndentX + Part1RateX * (FpsRateRounded.size() + 1);
        float YR = ChartHeight - Part1IndentY - Part1RateYFps * *FpsRateRounded.rbegin() - ValueHeight;

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

    if(CpuConsumptionRounded.size())
    {
        FString Value = FString::Printf(TEXT("CPU: %lld%%"), int(*CpuConsumptionRounded.rbegin()));

        float ValueWidth, ValueHeight;
        GetTextLength(ConsoleFont, Value, ConsoleFontSize, ValueWidth, ValueHeight);

        float XR = Part1IndentX + Part1RateX * (CpuConsumptionRounded.size() + 1);
        float YR = ChartHeight - Part1IndentY - Part1RateYCpu * *CpuConsumptionRounded.rbegin() - ValueHeight;

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

    //draw arrows
    // ---
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX, ChartHeight - Part1IndentY),
        FVector2D(ChartWidth - Part1IndentX, ChartHeight - Part1IndentY),
        CpuColor
        );
    // \

    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(ChartWidth - Part1IndentX, ChartHeight - Part1IndentY),
        FVector2D(ChartWidth - Part1IndentX - ArrowLength, ChartHeight - Part1IndentY - ArrowIndent),
        CpuColor
        );
    // /
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(ChartWidth - Part1IndentX, ChartHeight - Part1IndentY),
        FVector2D(ChartWidth - Part1IndentX - ArrowLength, ChartHeight - Part1IndentY + ArrowIndent),
        CpuColor
        );

    // |
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX, ChartHeight - Part1IndentY),
        FVector2D(Part1IndentX, Part1IndentY / 2.0f),
        CpuColor
        );

    // /
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX, Part1IndentY / 2.0f),
        FVector2D(Part1IndentX - ArrowIndent, Part1IndentY / 2.0f + ArrowLength),
        CpuColor
        );
    // \

    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX, Part1IndentY / 2.0f),
        FVector2D(Part1IndentX + ArrowIndent, Part1IndentY / 2.0f + ArrowLength),
        CpuColor
        );

    float StepFontSize = ConsoleFontSize / 2.0f;

    for (int Point = 10; ; Point += 10 )
    {        
        if (Point < Part1CapacityCpu)
        {
            GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
                InContext,
                FVector2D(Part1IndentX, ChartHeight - Part1IndentY - Part1RateYCpu * Point),
                FVector2D(Part1IndentX - ArrowIndent / 2.0f - ArrowIndent / 4.0, ChartHeight - Part1IndentY - Part1RateYCpu * Point),
                CpuColor
                );

            GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
                InContext,
                FText::FromString(FString::Printf(TEXT("%lld"), Point)),
                FVector2D(Part1IndentX - ArrowIndent / 2.0f - ArrowIndent / 4.0, ChartHeight - Part1IndentY - Part1RateYCpu * Point),
                ConsoleFont,
                StepFontSize,
                ConsoleFontTypeFace,
                CpuColor
                );
        }
        else
        {
            if (Part1CapacityCpu > Part1CapacityFps)
            {
                break;
            }
        }

        if (Point < Part1CapacityFps)
        {
            FString Value = FString::Printf(TEXT("%lld"), Point);

            float ValueWidth, ValueHeight;
            GetTextLength(ConsoleFont, Value, StepFontSize, ValueWidth, ValueHeight);

            GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
                InContext,
                FVector2D(Part1IndentX, ChartHeight - Part1IndentY - Part1RateYFps * Point),
                FVector2D(Part1IndentX + ArrowIndent / 2.0f + ArrowIndent / 4.0, ChartHeight - Part1IndentY - Part1RateYFps * Point),
                FpsColor
                );

            GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
                InContext,
                FText::FromString(Value),
                FVector2D(Part1IndentX + ArrowIndent / 2.0f + ArrowIndent / 4.0 - ValueWidth, ChartHeight - Part1IndentY - Part1RateYFps * Point),
                ConsoleFont,
                StepFontSize,
                ConsoleFontTypeFace,
                FpsColor
                );
        }
        else
        {
            if (Part1CapacityFps > Part1CapacityCpu)
            {
                break;
            }
        }
    }

    {
        FString Hint = "CPU";
        float SizeX = 0.0f, SizeY = 0.0f;
        GetTextLength(ConsoleFont, Hint, ConsoleFontSize, SizeX, SizeY);

        GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
            InContext,
            FText::FromString(Hint),
            FVector2D(Part1IndentX - 0.01 * ArrowLength - SizeX, Part1IndentY / 2.0f - SizeY),
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
            FVector2D(Part1IndentX + 0.01, Part1IndentY / 2.0f - SizeY),
            ConsoleFont,
            ConsoleFontSize,
            ConsoleFontTypeFace,
            FpsColor
            );
    }

    int MessageIndex = 0;
    
    for (auto Message = ConsoleMessages.rbegin(); Message != ConsoleMessages.rend(); ++Message, ++MessageIndex)
    {
        if (ConsoleFont)
        {
            GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
                InContext,
                FText::FromString(std::get<0>(*Message)),
                FVector2D(ChartWidth, MessageIndex * 2 * ConsoleFontSize),
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
                FVector2D(ChartWidth, MessageIndex * (ChartHeight / 11.0f)),
                CpuColor
                );
        }
    }
}

void UCustomPaintWidget::NativeTick(const FGeometry& MyGeometry, float InDeltaTime)
{
    UUserWidget::NativeTick(MyGeometry, InDeltaTime);

    if (FpsRate.size() == ChartCapacity)
    {
        FpsRate.pop_front();
        FpsRateRounded.pop_front();

        CpuConsumption.pop_front();
        CpuConsumptionRounded.pop_front();
    }

    float CurrentFps = FrameCount;// ? FrameCount : 1.f / InDeltaTime;
    FpsRateCache.push_back(CurrentFps);
    
    if ((LastQueryDelta < 0) || (LastQueryDelta >= ChartResolution))
    {
        query.Record();
        float CurrentCpuConsumption = query.vciSelectedCounters[0].logs.back().value;
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