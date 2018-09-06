// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "MediaPlayer.h"
#include "MediaTexture.h"
#include "RenderingThread.h"

#ifndef D3D11RHI_API
#define D3D11RHI_API DLLEXPORT
#endif

#include "TextureResource.h"
#include "Runtime/Engine/Classes/Engine/Texture2D.h"
#include "Runtime/Engine/Public/HighResScreenshot.h"
#include "d3d11.h"
#include "Runtime/Windows/D3D11RHI/Public/D3D11State.h"
#include "Runtime/Windows/D3D11RHI/Public/D3D11Resources.h"
#include "Runtime/Windows/D3D11RHI/Private/D3D11RHIPrivate.h"
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

#include "HideWindowsPlatformTypes.h"

#include "ProfilingMediaPlayer.generated.h"

UCLASS(BlueprintType)
class MEDIATESTAMFCPP_API UProfilingMediaPlayer : public UMediaPlayer
{
    GENERATED_UCLASS_BODY()
	
    UFUNCTION(BlueprintCallable, Category="ProfilingMediaPlayer")
    bool SetProfilingInterval(const FTimespan& StartTime, const FTimespan& EndTime, int Frequency);

    void ProfilerCallerHelper();

protected:
    bool Profiling;
    FTimespan StartTime;
    FTimespan EndTime;
    int Frequency;
};
