set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_ENV_PASSTHROUGH PATH INCLUDE LIB GameDKLatest)
set(VCPKG_CMAKE_SYSTEM_VERSION 10.0)
set(VCPKG_C_FLAGS "/D_GAMING_XBOX /D_GAMING_XBOX_SCARLETT /favor:AMD64 /arch:AVX2")
set(VCPKG_CXX_FLAGS ${VCPKG_C_FLAGS})
set(VCPKG_LINKER_FLAGS "/SUBSYSTEM:WINDOWS,10.0")
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../../scripts/toolchains/xbox.cmake")
