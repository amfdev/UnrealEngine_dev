#include "ProfilingMediaPlayer.h"

//#include "../AmfMediaPrivate.h"
//#include "AmfMediaOutput.h"

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

UProfilingMediaPlayer::UProfilingMediaPlayer(const FObjectInitializer& ObjectInitializer):
    Super(ObjectInitializer),
    Profiling(false),
    Frequency(0)
{
}

void SaveTexture2DDebug_(const uint8* PPixelData, int width, int height, FString Filename)
{
    TArray<FColor> OutBMP;
    int w = width;
    int h = height;

    OutBMP.InsertZeroed(0, w*h);

    for (int i = 0; i < (w*h); ++i)
    {
        uint8 R = PPixelData[i * 4 + 2];
        uint8 G = PPixelData[i * 4 + 1];
        uint8 B = PPixelData[i * 4 + 0];
        uint8 A = PPixelData[i * 4 + 3];

        OutBMP[i].R = R;
        OutBMP[i].G = G;
        OutBMP[i].B = B;
        OutBMP[i].A = A;
    }

    FIntPoint DestSize(w, h);

    FString ResultPath;
    FHighResScreenshotConfig& HighResScreenshotConfig = GetHighResScreenshotConfig();
    bool bSaved = HighResScreenshotConfig.SaveImage(Filename, OutBMP, DestSize, &ResultPath);

    //UE_LOG(LogHTML5UI, Warning, TEXT("UHTML5UIWidget::SaveTexture2DDebug: %d %d"), w, h);
    //UE_LOG(LogHTML5UI, Warning, TEXT("UHTML5UIWidget::SaveTexture2DDebug: %s %d"), *ResultPath, bSaved == true ? 1 : 0);
}

bool UProfilingMediaPlayer::SetProfilingInterval(const FTimespan& Start, const FTimespan& End, int Frequency_)
{
    if (!SupportsSeeking())
    {
        return false;
    }

    Profiling = true;
    StartTime = Start;
    EndTime = End;
    Frequency = Frequency_;

    FTimespan step = FTimespan(0, 0, 0, 0, 1000 / Frequency);

    for (FTimespan seekTime = StartTime; seekTime <= EndTime; seekTime += step)
    {
        Seek(seekTime);

        ENQUEUE_UNIQUE_RENDER_COMMAND_ONEPARAMETER(
            RequireTextureSink,
            /*IMediaTextureSink**/UProfilingMediaPlayer*,
            ProfilingMediaPlayer,
            this,
            {
                ProfilingMediaPlayer->ProfilerCallerHelper();
            }
            );
        FlushRenderingCommands();
    }

    return true;
}

/*class D3D11RHI_API FD3D11TextureBaseAccess:
    public FD3D11TextureBase
{
public:
    FD3D11TextureBaseAccess(
        const FD3D11TextureBase& source
    ):
        FD3D11TextureBase(
            source.D3DRHI,
            source.IHVResourceHandle,
            source.MemorySize,
            source.BaseShaderResource,
            source.Resource,
            source.ShaderResourceView,
            source.RenderTargetViews,
            source.bCreatedRTVsPerSlice,
            source.RTVArraySize,
            source.NumDepthStencilViews
        )
    {
    }

    virtual ~FD3D11TextureBaseAccess() {}

    //public FD3D11DynamicRHI* GetD3DRHI() { return D3DRHI; }
};*/

void UProfilingMediaPlayer::ProfilerCallerHelper()
{
    //IMediaTextureSink* Sink = dynamic_cast<IMediaTextureSink*>(GetVideoTexture());
    auto Sink = GetVideoTexture();
    if (!Sink)
    {
        return;
    }

    FRHITexture* TextureRHI = Sink->GetTextureSinkTexture();
    if (!TextureRHI)
    {
        return;
    }

    FRHITexture2D* Texture2DRHI = TextureRHI->GetTexture2D();
    check(Texture2DRHI != nullptr);

    if (Texture2DRHI->GetSizeX() == 1 && Texture2DRHI->GetSizeY() == 1)
    {
        return;
    }

    /*
    CopiedSurface = SubmittedSurface;
    SubmittedSurface = nullptr;

    TRefCountPtr<IDXGIResource>	DxgiResource;
    static_cast<ID3D11Texture2D*>(CopiedSurface->GetPlaneAt(0)->GetNative())->
    QueryInterface(IID_PPV_ARGS(DxgiResource.GetInitReference()));
    check(DxgiResource != nullptr);

    HANDLE SharedHandle = nullptr;
    DxgiResource->GetSharedHandle(&SharedHandle);
    check(SharedHandle != nullptr);

    TRefCountPtr<ID3D11Resource> SharedResource;
    EngineDevice->OpenSharedResource(SharedHandle, IID_PPV_ARGS(SharedResource.GetInitReference()));
    check(SharedResource != nullptr);

    EngineDeviceContext->CopyResource(
    static_cast<ID3D11Texture2D*>(Texture2DRHI->GetNativeResource()),
    SharedResource
    );
    EngineDeviceContext->End(CopyEventQuery);
    */

    //TD3D11Texture2D<FD3D11BaseTexture2D> *textureWrapper(static_cast< TD3D11Texture2D<FD3D11BaseTexture2D> *>(Texture2DRHI));
    if (nullptr == GDynamicRHI)
    {
        return;
    }

    ID3D11Device* EngineDevice = static_cast<ID3D11Device*>(GDynamicRHI->RHIGetNativeDevice());
    check(EngineDevice != nullptr);

    TRefCountPtr<ID3D11DeviceContext> EngineDeviceContext;
    EngineDevice->GetImmediateContext(EngineDeviceContext.GetInitReference());
    
    ID3D11Texture2D *texture(static_cast<ID3D11Texture2D*>(Texture2DRHI->GetNativeResource()));

    /////////////////////////////
    D3D11_TEXTURE2D_DESC description;
    texture->GetDesc(&description);
    
    description.BindFlags = 0;
    description.CPUAccessFlags = D3D11_CPU_ACCESS_READ |     D3D11_CPU_ACCESS_WRITE;
    description.Usage = D3D11_USAGE_STAGING;

    ID3D11Texture2D* texTemp = NULL;

    HRESULT hr = EngineDevice->CreateTexture2D(&description, NULL, &texTemp);
    if (FAILED(hr))
    {
        if (hr == E_OUTOFMEMORY) {
        printf("GetImageData - CreateTexture2D - OUT OF MEMORY \n");
        }
        if (texTemp)
        {
            texTemp->Release();
            texTemp = NULL;
        }
        return;
    }
    EngineDeviceContext->CopyResource(texTemp, texture);

    D3D11_MAPPED_SUBRESOURCE  mapped;
    unsigned int subresource = 0;
    hr = EngineDeviceContext->Map(texTemp, 0, D3D11_MAP_READ, 0, &mapped);
    if (FAILED(hr))
    {
        return;
    }

    DWORD nWidth = description.Width;
    DWORD nHeight = description.Height;
    const int pitch = mapped.RowPitch;
    BYTE* source = (BYTE*)(mapped.pData);
    BYTE* dest = new BYTE[(nWidth)*(nHeight) * 4];
    BYTE* destTemp = dest;
    for (DWORD i = 0; i < nHeight; ++i)
    {
        memcpy(destTemp, source, nWidth * 4);
        source += pitch;
        destTemp += nWidth * 4;
    }
    EngineDeviceContext->Unmap(texTemp, 0);

    FDateTime dateTime = FDateTime::Now();

    SaveTexture2DDebug_(dest, nWidth, nHeight, FString("E:/out") + dateTime.ToString() + ".png");
}