#include "ProfilingMediaPlayer.h"

#include "MediaTestFunctionLibrary.h"

#include "Runtime/Media/Public/IMediaTextureSink.h"
#include "Runtime/Core/Public/Windows/COMPointer.h"

#include "RenderingThread.h"
#include "RHI.h"
#include "DynamicRHI.h"

#ifndef D3D11RHI_API
#define D3D11RHI_API DLLEXPORT
#endif

#include "Kismet/GameplayStatics.h"
#include "Kismet/KismetRenderingLibrary.h"
/*#include "TextureResource.h"
#include "Runtime/Engine/Classes/Engine/Texture2D.h"
#include "Runtime/Engine/Public/HighResScreenshot.h"
#include "d3d11.h"
#include "Runtime/Windows/D3D11RHI/Public/D3D11State.h"
#include "Runtime/Windows/D3D11RHI/Public/D3D11Resources.h"
#include "Engine/World.h"
#include "Misc/ScopeLock.h"
//#include "MediaTexture.h"

#include "AllowWindowsPlatformTypes.h"
#include "D3DX11tex.h"

// Disable macro redefinition warning for compatibility with Windows SDK 8+
#pragma warning(push)
#pragma warning(disable : 4005)	// macro redefinition
#include <D3D11.h>
#pragma warning(pop)

// AMF includes
//#include "public/include/components/VideoConverter.h"
//#include "public/include/components/Ambisonic2SRenderer.h"

#include "HideWindowsPlatformTypes.h"*/

#include <vector>

UProfilingMediaPlayer::UProfilingMediaPlayer(const FObjectInitializer& ObjectInitializer):
    Super(ObjectInitializer),
    Profiling(false),
    Frequency(0),
    Seeking(false)
{
    OnMediaEvent().AddLambda(
        [this](EMediaEvent Event)
        {
            this->OnMediaEventHandler(Event);
        }
        );
}

void UProfilingMediaPlayer::OnMediaEventHandler(EMediaEvent Event)
{
    AccessibleTextureCopy.SafeRelease();
}

bool UProfilingMediaPlayer::ProfileMedia(const FTimespan& Start, const FTimespan& End, int ShotsPerSecond, const FString& OutputPath)
{
    if (nullptr == GDynamicRHI)
    {
        return false;
    }

    if (!SupportsSeeking())
    {
        return false;
    }

    Profiling = true;
    StartTime = Start;
    EndTime = End;
    Frequency = ShotsPerSecond;
    OutputFolder = OutputPath;
    SeekTime = StartTime;
    
    return true;
}

//called in the
void UProfilingMediaPlayer::ProfilerCallerHelper(const FTimespan& FrameTime)
{
    /*auto Sink = GetVideoTexture();
    check(Sink);

    FRHITexture *TextureRHI = Sink->GetTextureSinkTexture();
    check(TextureRHI);

    ID3D11Device *EngineDevice = static_cast<ID3D11Device*>(GDynamicRHI->RHIGetNativeDevice());
    check(EngineDevice != nullptr);

    TRefCountPtr<ID3D11DeviceContext> EngineDeviceContext;
    EngineDevice->GetImmediateContext(EngineDeviceContext.GetInitReference());

    FRHITexture2D *Texture2DRHI = TextureRHI->GetTexture2D();
    check(Texture2DRHI != nullptr);

    ID3D11Texture2D *NativeTexture(static_cast<ID3D11Texture2D*>(Texture2DRHI->GetNativeResource()));

    //D3D11_TEXTURE2D_DESC NativeTextureDescription;
    //NativeTexture->GetDesc(&NativeTextureDescription);

    //assume that the texture's format could not be changed without events
    if (!AccessibleTextureCopy /*|| 0 != memcmp(&AccessibleTextureDescription, &NativeTextureDescription, sizeof(D3D11_TEXTURE2D_DESC))* /)
    {
        //D3D11_TEXTURE2D_DESC NativeTextureDescription;
        NativeTexture->GetDesc(&AccessibleTextureDescription/*NativeTextureDescription* /);
        //AccessibleTextureDescription = NativeTextureDescription;

        //extends access rights
        AccessibleTextureDescription.BindFlags = 0;
        AccessibleTextureDescription.CPUAccessFlags = D3D11_CPU_ACCESS_READ | D3D11_CPU_ACCESS_WRITE;
        AccessibleTextureDescription.Usage = D3D11_USAGE_STAGING;

        if (FAILED(EngineDevice->CreateTexture2D(&AccessibleTextureDescription, NULL, AccessibleTextureCopy.GetInitReference())))
        {
            return;
        }
    }

    EngineDeviceContext->CopyResource(AccessibleTextureCopy.GetReference(), NativeTexture);

    D3D11_MAPPED_SUBRESOURCE MappedTexture = {};

    if (FAILED(EngineDeviceContext->Map(AccessibleTextureCopy.GetReference(), 0, D3D11_MAP_READ, 0, &MappedTexture)))
    {
        return;
    }

    std::vector<BYTE> Pixels(AccessibleTextureDescription.Width * AccessibleTextureDescription.Height * 4);    

    BYTE *Source = (BYTE*)(MappedTexture.pData);
    BYTE *TargetPixel = &(*Pixels.begin());

    for 
    (
        UINT SkanLine = 0;
        SkanLine < AccessibleTextureDescription.Height;
        ++SkanLine, Source += MappedTexture.RowPitch, TargetPixel += AccessibleTextureDescription.Width * 4
    )
    {
        memcpy(TargetPixel, Source, AccessibleTextureDescription.Width * 4);
    }

    EngineDeviceContext->Unmap(AccessibleTextureCopy.GetReference(), 0);

    /*UMediaTestFunctionLibrary::SavePixmap(
        Pixels.data(),
        AccessibleTextureDescription.Width,
        AccessibleTextureDescription.Height,
        4,
        OutputFolder + UMediaTestFunctionLibrary::Timespan2Filename(SeekTime) + ".png"
        );*/
}

//called in the BP thread
bool UProfilingMediaPlayer::Tick(float DeltaTime)
{
    bool Ticked = UMediaPlayer::Tick(DeltaTime);

    /*if (Seeking)
    {
        FTimespan Step = FTimespan(0, 0, 0, 0, 1000 / Frequency);

        if (SeekTime <= EndTime)
        {
            Seek(SeekTime);

            ENQUEUE_UNIQUE_RENDER_COMMAND_TWOPARAMETER(
                RequireTextureSink,
                UProfilingMediaPlayer*,
                ProfilingMediaPlayer,
                this,
                FTimespan,
                SeekTime,
                SeekTime,
                {
                    ProfilingMediaPlayer->ProfilerCallerHelper(SeekTime);
                }
                );

            FlushRenderingCommands();

            SeekTime += Step;
        }
    }*/

    return Ticked;
}