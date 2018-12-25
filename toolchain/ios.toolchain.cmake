# This file is based off of the Platform/Darwin.cmake and Platform/UnixPaths.cmake
# files which are included with CMake 2.8.4
# It has been altered for iOS development

# Options:
#
# IOS_PLATFORM = DEVICE (default) or SIMULATOR
#   This decides if SDKS will be selected from the iPhoneOS.platform or iPhoneSimulator.platform folders
#   DEVICE - the default, used to build for iPhone and iPad physical devices, which have an arm arch.
#   SIMULATOR - used to build for the Simulator platforms, which have an x86 arch.
#
# XCODE_IOS_DEVELOPER_ROOT = automatic(default) or /path/to/platform/Developer folder
#   By default this location is automatcially chosen based on the IOS_PLATFORM value above.
#   If set manually, it will override the default location and force the user of a particular Developer Platform
#
# XCODE_IOS_SDK_ROOT = automatic(default) or /path/to/platform/Developer/SDKs/SDK folder
#   By default this location is automatcially chosen based on the XCODE_IOS_DEVELOPER_ROOT value.
#   In this case it will always be the most up-to-date SDK found in the XCODE_IOS_DEVELOPER_ROOT path.
#   If set manually, this will force the use of a specific SDK version

# Standard settings
set (CMAKE_SYSTEM_NAME Darwin)
set (CMAKE_SYSTEM_VERSION 1)
set (UNIX True)
set (APPLE True)
set (IOS True)
set (APPLE_IOS True)

# make sure all executables are bundles otherwise try compiles will fail
set (CMAKE_MACOSX_BUNDLE True)
set (CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer" CACHE STRING "how to sign executables" FORCE)

# Required as of cmake 2.8.10
set (CMAKE_OSX_DEPLOYMENT_TARGET "" CACHE STRING "Force unset of the deployment target for iOS" FORCE)

# make sure Xcode has been installed
set(XCODE_APP /Applications/Xcode.app)
if (EXISTS ${XCODE_APP}) 
  set(XCODE_TOOLCHAIN ${XCODE_APP}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain)
else()
  message (FATAL_ERROR "Unfined Xcode.app")
endif()

# config compiler
set(CMAKE_C_COMPILER ${XCODE_TOOLCHAIN}/usr/bin/cc)
set(CMAKE_CXX_COMPILER ${XCODE_TOOLCHAIN}/usr/bin/cc++)
set(CMAKE_AR ${XCODE_TOOLCHAIN}/usr/bin/ar)
set(CMAKE_C_COMPILER_AR "")
set(CMAKE_RANLIB ${XCODE_TOOLCHAIN}/usr/bin/ranlib)
set(CMAKE_C_COMPILER_RANLIB "")
set(CMAKE_LINKER ${XCODE_TOOLCHAIN}/usr/bin/ld)

# Setup iOS platform unless specified manually with IOS_PLATFORM
if (NOT DEFINED IOS_PLATFORM)
  set (IOS_PLATFORM "DEVICE")
endif()
set(IOS_PLATFORM ${IOS_PLATFORM} CACHE STRING "Type of iOS Platform")

# Check the platform selection and setup for developer root
if(${IOS_PLATFORM} STREQUAL "DEVICE")
  # device platform
  set(IOS_PLATFORM_LOCATION "iPhoneOS.platform")
  # device arch
  set(IOS_ARCH armv6 armv7 armv7s arm64 arm64e)
  # enable bitcode
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fembed-bitcode")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fembed-bitcode")
elseif(${IOS_PLATFORM} STREQUAL "SIMULATOR")
  # simulator platform
  set(IOS_PLATFORM_LOCATION "iPhoneSimulator.platform")
  # simulator arch
  set(IOS_ARCH i386 x86_64)
  # can set bitcode on iPhoneSimulator
else()
  message (FATAL_ERROR "Unsupported IOS_PLATFORM value selected. Please choose DEVICE or SIMULATOR")
endif()

# set the architecture for iOS
set(CMAKE_OSX_ARCHITECTURES ${IOS_ARCH} CACHE string  "Build architecture for iOS")

# set the sysroot for iOS
# iOS developer root
set(XCODE_IOS_DEVELOPER_ROOT ${XCODE_APP}/Contents/Developer/Platforms/${IOS_PLATFORM_LOCATION}/Developer CACHE PATH "Location of iOS Platform")

# Find and use the most recent iOS sdk unless specified manually with XCODE_IOS_SDK_ROOT
if(NOT DEFINED XCODE_IOS_SDK_ROOT)
  file(GLOB _CMAKE_IOS_SDKS "${XCODE_IOS_DEVELOPER_ROOT}/SDKs/*")
  if(_CMAKE_IOS_SDKS)
    list(SORT _CMAKE_IOS_SDKS)
    list(REVERSE _CMAKE_IOS_SDKS)
    list(GET _CMAKE_IOS_SDKS 0 XCODE_IOS_SDK_ROOT)
  else()
    message(FATAL_ERROR "No iOS SDK's found in default search path ${XCODE_IOS_DEVELOPER_ROOT}. Manually set XCODE_IOS_SDK_ROOT or install the iOS SDK.")
  endif()
  message (STATUS "Toolchain using default iOS SDK: ${XCODE_IOS_SDK_ROOT}")
endif()
set(XCODE_IOS_SDK_ROOT ${XCODE_IOS_SDK_ROOT} CACHE PATH "Location of the selected iOS SDK")

# Set the sysroot default to the most recent SDK
set(CMAKE_OSX_SYSROOT ${XCODE_IOS_SDK_ROOT} CACHE PATH "Sysroot used for iOS support")
