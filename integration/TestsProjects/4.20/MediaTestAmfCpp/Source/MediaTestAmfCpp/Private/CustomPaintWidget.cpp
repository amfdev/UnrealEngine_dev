#include "CustomPaintWidget.h"

#include "windows.h"
#include "psapi.h"
#include "pdh.h"
#pragma comment(lib, "Pdh.lib")

#undef DrawText

#include "UObject/UObjectGlobals.h"
#include "Blueprint/WidgetBlueprintLibrary.h"

#include <vector>

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

int ChartCapacity = 200;
float ChartResolution = 0.1f;
FLinearColor FpsColor = FLinearColor::Blue;
FLinearColor CpuColor = FLinearColor::White;
float SmothingWindow = 5;

UCustomPaintWidget::UCustomPaintWidget(const FObjectInitializer& ObjectInitializer):
    UUserWidget(ObjectInitializer),
    LastQueryDelta(-0.5f),
    ConsoleFont(nullptr),
    ConsoleDelaySeconds(12)
{
}

void UCustomPaintWidget::NativePaint(FPaintContext& InContext) const
{
    UUserWidget::NativePaint(InContext);

    const FVector2D ViewportSize = InContext.AllottedGeometry.Size;

    float ChartWidth = 2 * ViewportSize.X / 3;// InContext.MyCullingRect.Right - InContext.MyCullingRect.Left;
    float ChartHeight = ViewportSize.Y;

    int Bottom = ChartHeight;
    int Right = ChartWidth;

    float Part1Width = 2.0f * ChartWidth / 3.0f;
    float Part1Height = 6.0f * ChartHeight / 8.0f;

    float Part2Width = ChartWidth / 3.0f;
    
    float Part1CapacityX = ChartCapacity + 1;
    float Part1CapacityY1 = 110.0f;
    float Part1CapacityY2 = 200.0f;

    float Part1RateX = Part1Width / Part1CapacityX;
    float Part1RateY1 = ChartHeight / Part1CapacityY1;
    float Part1RateY2 = ChartHeight / Part1CapacityY2;

    float Part1IndentX = ChartWidth / 6.0f;
    float Part1IndentY = ChartHeight / 8.0f;

    auto FpsIterator = FpsRate.begin();
    auto CpuIterator = CpuConsumption.begin();
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

        float Y1 = ChartHeight - Part1IndentY - Part1RateY1 * *FpsIterator;
        float Y2 = ChartHeight - Part1IndentY - Part1RateY1 * *++FpsIterator;
        float Y3 = ChartHeight - Part1IndentY - Part1RateY2 * *CpuIterator;
        float Y4 = ChartHeight - Part1IndentY - Part1RateY2 * *++CpuIterator;

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

    float ArrowIndent = ChartWidth / 40.0f;
    float ArrowLength = ChartWidth / 20.0f;

    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX, ChartHeight - Part1IndentY),
        FVector2D(ChartWidth - Part1IndentX / 2.0f, ChartHeight - Part1IndentY),
        CpuColor
        );
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(ChartWidth - Part1IndentX / 2.0f, ChartHeight - Part1IndentY),
        FVector2D(ChartWidth - Part1IndentX / 2.0f - ArrowLength, ChartHeight - Part1IndentY - ArrowIndent),
        CpuColor
        );
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(ChartWidth - Part1IndentX / 2.0f, ChartHeight - Part1IndentY),
        FVector2D(ChartWidth - Part1IndentX / 2 - ArrowLength, ChartHeight - Part1IndentY + ArrowIndent),
        CpuColor
        );
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX, ChartHeight - Part1IndentY),
        FVector2D(Part1IndentX, Part1IndentY / 2.0f),
        CpuColor
        );
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX, Part1IndentY / 2.0f),
        FVector2D(Part1IndentX - ArrowIndent, Part1IndentY / 2.0f + ArrowLength),
        CpuColor
        );
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX, Part1IndentY / 2.0f),
        FVector2D(Part1IndentX + ArrowIndent, Part1IndentY / 2.0f + ArrowLength),
        CpuColor
        );
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX, ChartHeight - Part1IndentY),
        FVector2D(Part1IndentX, Part1IndentY / 2.0f),
        CpuColor
        );
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX, Part1IndentY / 2.0f),
        FVector2D(Part1IndentX - ArrowIndent, Part1IndentY / 2.0f + ArrowLength),
        CpuColor
        );
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX, Part1IndentY / 2.0f),
        FVector2D(Part1IndentX + ArrowIndent, Part1IndentY / 2.0f + ArrowLength),
        CpuColor
        );
    
    GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
        InContext,
        FText::FromString("CPU"),
        FVector2D(Part1IndentX, Part1IndentY / 2.0f),
        ConsoleFont,
        ConsoleFontSize,
        ConsoleFontTypeFace,
        CpuColor
        );

    

    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX / 2.0f, ChartHeight - Part1IndentY),
        FVector2D(Part1IndentX / 2.0f, Part1IndentY / 2.0f),
        FpsColor
        );
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX / 2.0f, Part1IndentY / 2.0f),
        FVector2D(Part1IndentX / 2.0f - ArrowIndent, Part1IndentY / 2.0f + ArrowLength),
        FpsColor
        );
    GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
        InContext,
        FVector2D(Part1IndentX / 2.0f, Part1IndentY / 2.0f),
        FVector2D(Part1IndentX / 2.0f + ArrowIndent, Part1IndentY / 2.0f + ArrowLength),
        FpsColor
        );
    GetDefault<UWidgetBlueprintLibrary>()->DrawTextFormatted(
        InContext,
        FText::FromString("FPS"),
        FVector2D(Part1IndentX / 2.0f, Part1IndentY / 2.0f),
        ConsoleFont,
        ConsoleFontSize,
        ConsoleFontTypeFace,
        FpsColor
    );

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
        CpuConsumption.pop_front();
    }

    if ((LastQueryDelta < 0) || (LastQueryDelta >= ChartResolution))
    {
        LastQueryDelta = 0.0;

        {
            float CurrentValue = 1.f / InDeltaTime;

            int Step = 1;
            float Summary = CurrentValue;

            /*for (auto FpsIterator = FpsRate.rbegin(); (Step < SmothingWindow) && (FpsIterator != FpsRate.rend()); ++FpsIterator, ++Step)
            {
                Summary += *FpsIterator;
            }

            Summary /= float(Step);*/

            FpsRate.push_back(Summary);
        }

        {
            query.Record();
            float CurrentValue = query.vciSelectedCounters[0].logs.back().value;

            int Step = 1;
            float Summary = CurrentValue;

            /*for (auto FpsIterator = FpsRate.rbegin(); (Step < SmothingWindow) && (FpsIterator != FpsRate.rend()); ++FpsIterator, ++Step)
            {
                Summary += *FpsIterator;
            }

            Summary /= float(Step);*/

            CpuConsumption.push_back(Summary);
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