#include "windows.h"
#include "psapi.h"
#include "pdh.h"
#pragma comment(lib, "Pdh.lib")

#include "CustomPaintWidget.h"
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

/*
//CPU currently used by current process:
static ULARGE_INTEGER lastCPU, lastSysCPU, lastUserCPU;
static int numProcessors;
static HANDLE self;

void init(){
    SYSTEM_INFO sysInfo;
    FILETIME ftime, fsys, fuser;

    GetSystemInfo(&sysInfo);
    numProcessors = sysInfo.dwNumberOfProcessors;

    GetSystemTimeAsFileTime(&ftime);
    memcpy(&lastCPU, &ftime, sizeof(FILETIME));

    self = GetCurrentProcess();
    GetProcessTimes(self, &ftime, &ftime, &fsys, &fuser);
    memcpy(&lastSysCPU, &fsys, sizeof(FILETIME));
    memcpy(&lastUserCPU, &fuser, sizeof(FILETIME));
}

double getCurrentValue(){
    FILETIME ftime, fsys, fuser;
    ULARGE_INTEGER now, sys, user;
    double percent;

    GetSystemTimeAsFileTime(&ftime);
    memcpy(&now, &ftime, sizeof(FILETIME));

    GetProcessTimes(self, &ftime, &ftime, &fsys, &fuser);
    memcpy(&sys, &fsys, sizeof(FILETIME));
    memcpy(&user, &fuser, sizeof(FILETIME));
    percent = (sys.QuadPart - lastSysCPU.QuadPart) +
        (user.QuadPart - lastUserCPU.QuadPart);
    percent /= (now.QuadPart - lastCPU.QuadPart);
    percent /= numProcessors;
    lastCPU = now;
    lastUserCPU = user;
    lastSysCPU = sys;

    return percent * 100;
}
*/
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

UCustomPaintWidget::UCustomPaintWidget(const FObjectInitializer& ObjectInitializer):
    UUserWidget(ObjectInitializer)
{
    FpsRate.reserve(1000);
    CpuConsumption.reserve(1000);
    GpuConsumption.reserve(1000);
    LastQueryDelta = 0.0f;
}

void UCustomPaintWidget::NativePaint(FPaintContext& InContext) const
{
    UUserWidget::NativePaint(InContext);

    int CapacityX = 1001.f;
    int CapacityY1 = 200.f;
    int CapacityY2 = 120.f;

    float XRate = (InContext.MyCullingRect.Right - InContext.MyCullingRect.Left) / CapacityX;
    float YRate1 = (InContext.MyCullingRect.Bottom - InContext.MyCullingRect.Top) / CapacityY1;
    float YRate2 = (InContext.MyCullingRect.Bottom - InContext.MyCullingRect.Top) / CapacityY2;

    int Bottom = InContext.MyCullingRect.Bottom;
    int Right = InContext.MyCullingRect.Right;

    for (int PointIndex = 1; PointIndex < FpsRate.size(); ++PointIndex)
    {
        GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
            InContext,
            FVector2D(XRate * (PointIndex - 1), YRate2 * FpsRate[PointIndex - 1]),
            FVector2D(XRate * PointIndex, YRate2 * FpsRate[PointIndex])
            );

        GetDefault<UWidgetBlueprintLibrary>()->DrawLine(
            InContext,
            FVector2D(XRate * (PointIndex - 1), YRate2 * CpuConsumption[PointIndex - 1]),
            FVector2D(XRate * PointIndex, YRate2 * CpuConsumption[PointIndex]),
            FLinearColor::Blue
            );
    }
}

void UCustomPaintWidget::NativeTick(const FGeometry& MyGeometry, float InDeltaTime)
{
    UUserWidget::NativeTick(MyGeometry, InDeltaTime);

    if (1000 == FpsRate.size())
    {
        FpsRate.resize(0);
        CpuConsumption.resize(0);
    }

    if (0.0 == LastQueryDelta || LastQueryDelta >= 0.5f)
    {
        LastQueryDelta = 0.0;

        FpsRate.push_back(1.f / InDeltaTime);
        //CpuConsumption.push_back(getCurrentValue());

        query.Record();
        CpuConsumption.push_back(query.vciSelectedCounters[0].logs.back().value);
    }
    else
    {
        LastQueryDelta += InDeltaTime;
    }
}
