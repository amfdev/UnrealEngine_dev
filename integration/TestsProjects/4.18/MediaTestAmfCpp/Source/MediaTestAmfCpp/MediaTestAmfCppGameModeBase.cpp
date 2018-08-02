#include "MediaTestAmfCppGameModeBase.h"
#include "UObject/ConstructorHelpers.h"
#include "GameFramework/HUD.h"

AMediaTestAmfCppGameModeBase::AMediaTestAmfCppGameModeBase()
{
    // You can obtain the asset path of your HUD blueprint through the editor 
    // by right-clicking the Blueprint asset and choosing "Copy Reference".
    // You should then add the "_C" suffix so that the class finder properly 
    // points to the actual class used by the game, as opposed to its Blueprint
    // which is an editor-only concept).
    // 
    // For instance, given a blueprint named BP_JoyHUD, the class path would be
    //	"/Game/Blueprints/BP_JoyHUD_C"
    static ConstructorHelpers::FClassFinder<AHUD> TheHUDOb(TEXT("/Game/UI/BP_PerformanceChart"));
    if (TheHUDOb.Class != NULL)
    {
        HUDClass = TheHUDOb.Class;
    }
}