@ECHO OFF
SETLOCAL

IF NOT DEFINED AmfHome (
    @ECHO Error: AmfHome variable undefined!
    GOTO :error
)

CD %AmfHome%
IF ERRORLEVEL 1 GOTO :error

SET target=build
SET maxcpucount=/maxcpucount 
SET solution=Engine\Source\ThirdParty\AMD\AMF_SDK\amf\public\proj\vs2015\AmfMediaCommon.sln
SET configuration="Release"
SET platform="x64"

TIME /T > build_time_begin.txt
%MSBUILD_EXE% /target:%target% %maxcpucount% /property:Configuration=%configuration%;Platform=%platform% %parameters% %solution%
time /T > build_time_end.txt

:done
    @ECHO Amf libraries built
    EXIT /B 0

:error
    @ECHO Error: failed to build Amf libraries
    EXIT /B 1