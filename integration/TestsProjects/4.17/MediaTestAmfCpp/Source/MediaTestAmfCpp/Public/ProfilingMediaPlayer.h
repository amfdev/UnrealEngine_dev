#pragma once

#include "IMediaPlayer.h"
#include "CoreMinimal.h"
#include "MediaPlayer.h"
#include "MediaTexture.h"
#include "RenderingThread.h"
#include "TextureResource.h"
#include "Runtime/Engine/Classes/Engine/Texture2D.h"
#include "Engine/World.h"
#include "Misc/ScopeLock.h"

#include "AllowWindowsPlatformTypes.h"
// Disable macro redefinition warning for compatibility with Windows SDK 8+
#pragma warning(push)
#pragma warning(disable : 4005)	// macro redefinition
#include <D3D11.h>
#pragma warning(pop)
#include "HideWindowsPlatformTypes.h"

#include "Runtime/Windows/D3D11RHI/Public/D3D11State.h"
#include "Runtime/Windows/D3D11RHI/Public/D3D11Resources.h"
#include "Runtime/Windows/D3D11RHI/Private/D3D11RHIPrivate.h"

#include "ProfilingMediaPlayer.generated.h"

UCLASS(BlueprintType)
class MEDIATESTAMFCPP_API UProfilingMediaPlayer:
    public UMediaPlayer
{
    GENERATED_UCLASS_BODY()
	
    UFUNCTION(BlueprintCallable, Category="ProfilingMediaPlayer")
    bool ProfileMedia(
        const FTimespan& StartTime,
        const FTimespan& EndTime,
        int Frequency,
        const FString& OutputFolder
        );

    void ProfilerCallerHelper(const FTimespan& FrameTime);

    //UFUNCTION()
    void OnMediaEventHandler(EMediaEvent Event);

    //FOnMediaEvent& OnMediaEvent();
    /*DECLARE_DERIVED_EVENT(UProfilingMediaPlayer, IMediaPlayer::FOnMediaEvent, FOnMediaEvent);
    FOnMediaEvent& OnMediaEvent() /*override* /
    {
        return MediaEvent;
    }*/

    virtual bool Tick(float DeltaTime) override;

protected:
    bool Profiling;
    FTimespan StartTime;
    FTimespan EndTime;
    int Frequency;
    FString OutputFolder;
    bool Seeking;
    FTimespan SeekTime;

    TRefCountPtr<ID3D11Texture2D> AccessibleTextureCopy;
    D3D11_TEXTURE2D_DESC AccessibleTextureDescription;

    /** Event delegate that is invoked when a media event occurred. */
    FOnMediaEvent MediaEvent;
};
