# Build.bat

Build.bat is building and testing utility to works with UnrealEngine and Amf library.
It provides building a list of the specified versions of Unreal Engine with diffrent configurations and to automatically apply
related Amf patches to the Unreal Engine. In additional it provides building if the demostration projects witch are specialy designed to
play 4k video to tests media playback inside Unreal Engine.

## Supported Unreal Engine versions
Unreal Engine 4.17
Unreal Engine 4.18
Unreal Engine 4.19
Unreal Engine 4.20
Unreal Engine 4.21

## Supported Visual Studio versions
Visual Studio 2015
Visual Studio 2017

## Supported configurations
Development [Editor]
Shipping

## Supported rendering types
Standard (using Windows media playback)
Amf (using  Amf media playback)
Stitch (using Amf Stitch plugin)

## Supported project types
Blueprints (only) project
C++ project

## Supported platforms
Win64

# Features
Build.bat could builds entire combinations of the all available configurations or just a list of the specified options. Build.bat can
builds Unreal Engine itself or with related tests projects, and separatly tests projects only (assuming that Unreal Engine with demanded configuration
are already built and placed in the correct folder).

# Usage
Build.bat [Command1] [Command2] [Command3] ...

    Available commands:
        Engine - build Unreal Engine
        Tests - build tests
        4.17 4.18 4.19 4.20 4.21 - specify Unreal Engine version
        Standard - build Unreal Engine and related tests with standard media playback
        Amf - build Unreal Engine and related tests with accelerated AMF media playback
        Stitch - build Unreal Engine and related tests with stitch media playback
        Development - Unreal Engine and related tests with development configuration
        Shipping - Unreal Engine and related tests with shipping configuration
        BluePrints - build blueprints variant of the related tests
        CPP - build c++ variant of the related tests
        Plane, X360, MediaTest - specify the name of the tests for standard and amf configuration
        Clean - clean up Unreal Engine and plugin repository before build
        Dirty - don't clean Unreal Engine and plugin repository before build
        PatchPlugin - use test repository, download branch, then patch it with our patches
                      Attention: not-patched plugin will be used if this command are not specified!
        AmfBranch: branch_name - download specified branch of AMF plugin
        StitchBranch: branch_name - download specified branch of Stitch plugin
        Verbose - show extended information
        Help - show this help

  An order of the arguments are not sensitive.

  *If no one of the Engine or Tests params specified, both will be built (Engine first, then related tests).
  *If no one of the versions specified both will be built (4.17, then 4.18).
  *If no one of the playback specified both will be built (Standart first, then with Amf patches and support).
  *If no one of the tests projects type specified both will be built (Blueprints and C++).

  *Adding of the parameter CPP or Blueprints automatically set Tests build to ON

# Examples
"Build.bat" - builds all possible list of combinations

"Build.bat Development 4.17 Blueprints Amf" - builds tests projects with Amf playback using Development configuration of UnrealEngine 4.17

"Build.bat Engine 4.18 4.21" - builds Development and Shipping configuration of Unreal Engine 4.18 and 4.21 with and without Amf patches

"Build.bat Amf Engine Mediatest" -builds cumulative mediatest example for all supported Unreal Engine versions

# Logs
Build logs are saved to the folder "Logs". Log saved in the CSV table for all built configuration.
Each line of the table means related build configuration and building result.
Collumns are saved in the following order:
project name, start date, start time, end date, end time, result of the build.