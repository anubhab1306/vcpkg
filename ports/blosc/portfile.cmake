vcpkg_minimum_required(VERSION 2022-10-12) 
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Blosc/c-blosc
    REF "v${VERSION}"
    SHA512 e9542aa2d1ebae9f6dcc12916d7ac3b920d771281ab96e2b2d59c2951e5f51d02d2684859b8823643d43d320613fb9dd8a3ea411ade34e66e323fcefa8165a91
    HEAD_REF master
    PATCHES
      0001-find-deps.patch
      0002-export-blosc-config.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BLOSC_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BLOSC_SHARED)

file(REMOVE_RECURSE "${SOURCE_PATH}/internal-complibs")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DPREFER_EXTERNAL_LZ4=ON
        -DPREFER_EXTERNAL_ZLIB=ON
        -DPREFER_EXTERNAL_ZSTD=ON
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_STATIC=${BLOSC_STATIC}
        -DBUILD_SHARED=${BLOSC_SHARED}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/${PORT})

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_copy_tools(TOOL_NAMES compress_fuzzer decompress_fuzzer SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/tests/fuzz)
endif()

# cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSES/BLOSC.txt")

vcpkg_fixup_pkgconfig()
