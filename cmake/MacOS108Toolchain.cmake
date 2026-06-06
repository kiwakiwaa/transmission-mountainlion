# This file Copyright © Transmission authors and contributors.
# It may be used under the MIT (SPDX: MIT) license.
# License text can be found in the licenses/ folder.

set(CMAKE_SYSTEM_NAME Darwin)

set(CMAKE_OSX_DEPLOYMENT_TARGET 10.8
    CACHE STRING "Minimum macOS version to target for deployment" FORCE)

if(NOT CMAKE_OSX_SYSROOT AND DEFINED ENV{CMAKE_OSX_SYSROOT})
    file(TO_CMAKE_PATH "$ENV{CMAKE_OSX_SYSROOT}" CMAKE_OSX_SYSROOT)
endif()

if(NOT CMAKE_OSX_SYSROOT AND EXISTS "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk")
    set(CMAKE_OSX_SYSROOT "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk"
        CACHE PATH "macOS SDK to use for this build")
endif()

set(_tr_macos_10_8_tool_paths)
if(NOT CMAKE_PREFIX_PATH AND EXISTS "/opt/local")
    list(APPEND CMAKE_PREFIX_PATH "/opt/local")
endif()

foreach(_tr_macos_10_8_prefix IN LISTS CMAKE_PREFIX_PATH)
    list(APPEND _tr_macos_10_8_tool_paths "${_tr_macos_10_8_prefix}/bin")
endforeach()

if(CMAKE_PREFIX_PATH)
    set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}"
        CACHE STRING "Installation prefixes for dependency lookup")
endif()

if(NOT CMAKE_C_COMPILER)
    find_program(TR_MACOS_10_8_C_COMPILER
        NAMES clang-mp-16 clang
        PATHS ${_tr_macos_10_8_tool_paths})

    if(TR_MACOS_10_8_C_COMPILER)
        set(CMAKE_C_COMPILER "${TR_MACOS_10_8_C_COMPILER}"
            CACHE FILEPATH "C compiler for the OS X 10.8 compatibility build" FORCE)
    endif()
endif()

if(NOT CMAKE_CXX_COMPILER)
    find_program(TR_MACOS_10_8_CXX_COMPILER
        NAMES clang++-mp-16 clang++
        PATHS ${_tr_macos_10_8_tool_paths})

    if(TR_MACOS_10_8_CXX_COMPILER)
        set(CMAKE_CXX_COMPILER "${TR_MACOS_10_8_CXX_COMPILER}"
            CACHE FILEPATH "C++ compiler for the OS X 10.8 compatibility build" FORCE)
    endif()
endif()

if(CMAKE_GENERATOR MATCHES "Ninja" AND NOT CMAKE_MAKE_PROGRAM)
    find_program(TR_MACOS_10_8_NINJA
        NAMES ninja
        PATHS ${_tr_macos_10_8_tool_paths})

    if(TR_MACOS_10_8_NINJA)
        set(CMAKE_MAKE_PROGRAM "${TR_MACOS_10_8_NINJA}"
            CACHE FILEPATH "Ninja executable for the OS X 10.8 compatibility build" FORCE)
    endif()
endif()

foreach(_tr_macos_10_8_prefix IN LISTS CMAKE_PREFIX_PATH)
    set(_tr_macos_10_8_libcxx_dir "${_tr_macos_10_8_prefix}/libexec/llvm-16/lib/libc++")
    if(EXISTS "${_tr_macos_10_8_libcxx_dir}/libc++.dylib")
        foreach(_tr_macos_10_8_linker_flags_var
                CMAKE_EXE_LINKER_FLAGS_INIT
                CMAKE_MODULE_LINKER_FLAGS_INIT
                CMAKE_SHARED_LINKER_FLAGS_INIT)
            string(APPEND ${_tr_macos_10_8_linker_flags_var}
                " -L${_tr_macos_10_8_libcxx_dir} -Wl,-rpath,${_tr_macos_10_8_libcxx_dir}")
        endforeach()
        break()
    endif()
endforeach()
