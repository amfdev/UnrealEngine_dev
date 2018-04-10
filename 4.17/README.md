# UnrealEngine 4.17 with AMF GPUOpen-UnrealEngine patches

### Prepare VisualStudio 2017 Community Edition
This instruction represents the steps needed after the clean installation without modifying
target frameworks

In the VisualStudio install utility please check the following:
* Windows SDK 10.0.14393 must be is installed
* .Net Framework 4.5 Targeting pack must be installed

### Build GPUOpen-UnrealEngine
* Verify that your githab account are marked as UnrealEngine Developer (you must enter your hithub name in the epic unreal site)
* After some hours your account will be approved - an email will be sent to your github account email address
* Download UnrealEngine repository from Unreal github
* Attention! Switch branch version to the 4.17
* Download Amf repository from https://github.com/GPUOpenSoftware/UnrealEngine
* Attention! Switch to the demanded branch (4.17)
* Open AmfMediaCommon.sln in the following path: ".\Engine\Source\ThirdParty\AMD\AMF_SDK\amf\public\proj\vs2017"
* If you are using default VisualStudio Community 2017 (version 15.6.5) with Visual C++ 2017 (version 00369-60000-00001-AA611)
  you must to make some changes to the source code:
     1) in file ".\Engine\Source\ThirdParty\AMD\AMF_SDK\amf\public\common\AMFSTL.cpp" 
        in line 53 change version check from _MSC_VER <= 1910 to the _MSC_VER <= 1913
     
     2) in file ".\Engine\Source\ThirdParty\AMD\AMF_SDK\amf\public\samples\CPPSamples\common\CmdLogger.h" 
        in line 43 and line 50 change enum name from "LogLevel" to "AmdLogLevel"

     3) in file ".\Engine\Source\ThirdParty\AMD\AMF_SDK\amf\public\samples\CPPSamples\common\CmdLogger.cpp" 
        in line 37 and line 61 change enum name from "LogLevel" to "AmdLogLevel"

* Build release (sic!) verions of AmfMediaCommon for target platforms (x64 or x32)
* In file ".\AmfMediaInstall.bat" change second line from "set VS_VERSION=vs2015" to "set VS_VERSION=%2"
* Run this bat file with the path to your UnrealEngine reposity in the first argument and "vs2017" version specifier in the second argumnent
  The bat file will copy demanded Amf source files to the Unreal's engine directory
* In the UnrealEngine folder follow readme instructions (run setup.bat, then run GenerateProjectFiles.bat)
* Copy demanded AmfMediaCommon .lib files from Amf directory
  If you build x64 release binaries with vs2017 they will be placed in the ".\Engine\Source\ThirdParty\AMD\AMF_SDK\amf\bin\vs2017x64Release"
  Copy them to the UnrealEngine folder to the path ".\Engine\Source"
  i.e. there would be file ".\Engine\Source\AmfMediaCommon.lib"
* In the root UnrealEngine folder open solution file UE4.sln, change configuration to the development x64
* Build engine. If you have not change any settings this will produce Unreal Engine 4.17 version with Amf support