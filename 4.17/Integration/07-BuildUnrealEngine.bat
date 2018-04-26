CD UnrealEngine-4.17

SET msbuild=%1
SET target=build
SET maxcpucount=/maxcpucount 
SET solution=Engine\Source\ThirdParty\AMD\AMF_SDK\amf\public\proj\vs2015\AmfMediaCommon.sln
SET configuration="Release"
SET platform="x64"

TIME /T > build_time_begin.txt

%msbuild% /target:%target% %maxcpucount% /property:Configuration=%configuration%;Platform=%platform% %parameters% %solution%

TIME /T > build_time_end.txt

CD ..