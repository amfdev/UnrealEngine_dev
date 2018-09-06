using UnrealBuildTool;
using System.IO;

public class MediaTestAmfCpp : ModuleRules
{
	public MediaTestAmfCpp(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
	
		PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore" });

		PrivateDependencyModuleNames.AddRange(
            new string[]
            {
                "Slate",
                "SlateCore",
                "Core",
                "CoreUObject",
                "Engine",
                "MediaAssets",
                "RenderCore",
                "RHI",
                "D3D11RHI"
            }
            );

        PublicIncludePaths.Add(UEBuildConfiguration.UEThirdPartySourceDirectory + "Windows/DirectX/Include");
        
        // Required for some private headers needed for the rendering support.
        var EngineDir = Path.GetFullPath(BuildConfiguration.RelativeEnginePath);
        PrivateIncludePaths.AddRange(
            new string[] {
                Path.Combine(EngineDir, @"Source\Runtime\Windows\D3D11RHI\Private"),
                Path.Combine(EngineDir, @"Source\Runtime\Windows\D3D11RHI\Private\Windows")
                }
            );

        AddEngineThirdPartyPrivateStaticDependencies(Target,
                new string[] {
                    "DX11",
                }
            );

        // Uncomment if you are using online features
        // PrivateDependencyModuleNames.Add("OnlineSubsystem");

        // To include OnlineSubsystemSteam, add it to the plugins section in your uproject file with the Enabled attribute set to true
    }
}
