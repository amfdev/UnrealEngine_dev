# Build.bat

Build.bat is building and testing utility to works with UnrealEngine and Amf library. 
It provides building a list of the specified versions of Unreal Engine with diffrent configurations and to automatically apply
related Amf patches to the Unreal Engine. In additional it provides building if the demostration projects witch are specialy designed to
play 4k video to tests media playback inside Unreal Engine.

## Supported versions
Unreal Engine 4.17 
Unreal Engine 4.18
Unreal Engine 4.19

## Supported configurations
Development [Editor]
Shipping

## Supported tests types
Standard (using Windows media playback)
Amf (using improved Amf media playback)
Stitch (using Amf Stitch plugin)

## Supported project types
Blueprints (only) project
C++ project

## Supported platforms
Win64

# Futures
Build.bat could builds entire combinations of the all available configurations or just a list of the specified options. Build.bat can
builds Unreal Engine itself or with related tests projects, and separatly tests projects only (assuming that Unreal Engine with demanded configuration
are already built and placed in the correct folder).

# Usage
Build.bat supports of the followings params:
  
  - Engine - build Unreal Engine
  - Tests - build tests projects

  - 4.17 - specify Unreal Engine version 4.17
  - 4.18 - specify Unreal Engine version 4.18
  - 4.19 - specify Unreal Engine version 4.19

  - Amf - use Unreal Engine with Amf support (and patches)
  - Standard - use standard Unreal Engine without Amf patches
  - Stitch - use Stitch amf plugin for Unreal Engine without Amf patches

  - CPP - Build C++ based tests
  - BluePrints - Build blueprints based tests

  - Help - show short usage help

  An order of the arguments are not sencitive.

  *If no one of the Engine or Tests params specified, both will be built (Engine first, then related tests).
  *If no one of the versions specified both will be built (4.17, then 4.18).
  *If no one of the playback specified both will be built (Standart first, then with Amf patches and support).
  *If no one of the tests projects type specified both will be built (Blueprints and C++).

  *Adding of the parameter CPP or Blueprints automatically set Tests build to ON

# Examples
"Build.bat" - builds all possible list of combinations

"Build.bat Development 4.17 Blueprints Amf" - builds tests projects with Amf playback using Development configuration of UnrealEngine 4.17

"Build.bat Engine 4.18" - build Development and Shipping configuration of Unreal Engine with and without Amf patches

# Logs
Build logs are saved to the folder "Logs". Log saved in the CSV table for all built configuration.
Each line of the table means related build configuration and building result.
Collumns are saved in the following order:
project name, start date, start time, end date, end time, result of the build.