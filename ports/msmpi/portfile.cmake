vcpkg_fail_port_install(ON_TARGET "Linux" "OSX" "UWP")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/Microsoft-MPI
    REF v10.1.1
    SHA512 c5aef7c15e815dab22a46bdc7ad14fea20e6ed4324f560c3d9df2dd236338b282ec2d4a45522eb04801e3733a0d3db8017ce0ed9f18c3844a452c182296b9e59
    HEAD_REF master
    PATCHES
        # PlatformToolset and WindowsTargetPlatformVersion are explicitly set by `vcpkg_install_msbuild`
        # and VCToolsVersion is automatically selected
        no-toolsversion.patch

        # Some symbols referenced from Basestd.h end up unresolved, so we just use the macro version
        # of them directly.
        fix-external-symbols.patch

        # mpif.h uses invalid BOZ integer constants, which will not be accepted without `-fallow-invalid-boz`
        # by gfortran >= 10.0, so we convert them to regular integer constants.
        fix-invalid-boz-literals.patch

        # Replace CBT project by packages.config
        # See https://github.com/CommonBuildToolset/CBT.Modules/issues/292
        fix-nuget-restore.patch

        # Replace usage of the `MessageCompile` target by a custom build step.
        # This removes the dependency to the Windows Driver Kit
        no-wdk.patch

        # Remove the NetworkDirect NuGet dependency because we want to use the library provided by vcpkg.
        # It will be picked up because of USE_VCPKG_INTEGRATION used below.
        networkdirect-no-nuget.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(PROPERTY_FILE_PATHS "${SOURCE_PATH}/Directory.Build.props" "${SOURCE_PATH}/src/mpi.props" )
    foreach(PROPERTY_FILE_PATH IN LISTS PROPERTY_FILE_PATHS)
        file(READ ${PROPERTY_FILE_PATH} _contents)
        string(REPLACE "<ConfigurationType>MultiThreaded</ConfigurationType>" "<ConfigurationType>MultiThreadedDLL</ConfigurationType>" _contents "${_contents}")
        string(REPLACE "<ConfigurationType>MultiThreadedDebug</ConfigurationType>" "<ConfigurationType>MultiThreadedDebugDLL</ConfigurationType>" _contents "${_contents}")
        file(WRITE ${PROPERTY_FILE_PATH} "${_contents}")
    endforeach()
endif()

# Acquire gfortran
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(MINGW_PATH mingw32)
    set(MSYS_TARGET i686)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(MINGW_PATH mingw64)
    set(MSYS_TARGET x86_64)
else()
    message(FATAL_ERROR "Unknown architecture '${VCPKG_TARGET_ARCHITECTURE}' for MinGW Fortran build!")
endif()

vcpkg_acquire_msys(MSYS_ROOT PACKAGES "mingw-w64-${MSYS_TARGET}-gcc-fortran")
set(MINGW_BIN "${MSYS_ROOT}/${MINGW_PATH}/bin")
vcpkg_add_to_path(PREPEND "${MINGW_BIN}")

# Acquire Perl
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

# Build the project
list(GET CONFIGURATIONS 0 HEADER_CONFIGURATION)
vcpkg_install_msbuild(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH .
    BINARIES_SUBPATH out/*/bin
    LICENSE_SUBPATH LICENSE.txt
    SKIP_CLEAN
    PLATFORM ${VCPKG_TARGET_ARCHITECTURE}
    USE_VCPKG_INTEGRATION
    OPTIONS
      "/p:GFORTRAN_BIN=${MINGW_BIN}"
)

# The headers to install are located in the build directories
get_filename_component(SOURCE_PATH_SUFFIX "${SOURCE_PATH}" NAME)
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(INCLUDES_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${SOURCE_PATH_SUFFIX}/out/Release-${VCPKG_TARGET_ARCHITECTURE}/bin/sdk/inc)
elseif(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(INCLUDES_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-deb/${SOURCE_PATH_SUFFIX}/out/Debug-${VCPKG_TARGET_ARCHITECTURE}/bin/sdk/inc)
endif()

file(COPY ${INCLUDES_DIR}/${TRIPLET_SYSTEM_ARCH}/mpifptr.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/)
file(REMOVE_RECURSE ${INCLUDES_DIR}/x64)
file(REMOVE_RECURSE ${INCLUDES_DIR}/x86)

file(COPY ${INCLUDES_DIR}/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

vcpkg_clean_msbuild()
