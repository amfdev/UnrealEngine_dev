#include "CustomPaintWidget.h"
#include "UObject/UObjectGlobals.h"
#include "Blueprint/WidgetBlueprintLibrary.h"

//#include "TCHAR.h"
#include "pdh.h"
#pragma comment(lib, "Pdh.lib")

#include "windows.h"

static PDH_HQUERY cpuQuery;
static PDH_HCOUNTER cpuTotal;

/*void init(){
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
}*/

DWORD GetProcessorCount() 
{ 
    SYSTEM_INFO sysinfo;  
    DWORD dwNumberOfProcessors; 


    GetSystemInfo(&sysinfo); 


    dwNumberOfProcessors = sysinfo.dwNumberOfProcessors; 


    return dwNumberOfProcessors; 
}

/*std::vector<PCTSTR> GetProcessNames() 
{ 
    DWORD dwProcessID[1024]; 
    DWORD cbProcess; 
    DWORD cProcessID; 
    BOOL fResult = FALSE; 
    DWORD index; 


    HANDLE hProcess; 
    HMODULE lphModule[1024]; 
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
}*/

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

struct ConsumptionHelper
{
    ConsumptionHelper()
    {
        init();
    }
};

static ConsumptionHelper;

UCustomPaintWidget::UCustomPaintWidget(const FObjectInitializer& ObjectInitializer):
    UUserWidget(ObjectInitializer)
{
    FpsRate.reserve(1000);
    CpuConsumption.reserve(1000);
    GpuConsumption.reserve(1000);
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

    FpsRate.push_back(1.f / InDeltaTime);
    CpuConsumption.push_back(getCurrentValue());
}
