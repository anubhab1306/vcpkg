vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simdjson/simdjson
    REF 3faae676632e73aeaca9c0dcacac16988553d7ac # v0.4.3
    SHA512 c4a8c4caa1051941107905964a97eeeebf538a0df5670d033a90f3e9b400e13379a17a91af3c4d5a00eb366f698be4908e12803b688760fed488c37a738956e9
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SIMDJSON_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_TARGET_ARCHITECTURE}" "arm64" SIMDJSON_IMPLEMENTATION_ARM64)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSIMDJSON_BUILD_STATIC=${SIMDJSON_BUILD_STATIC}
        -DSIMDJSON_IMPLEMENTATION_ARM64=${SIMDJSON_IMPLEMENTATION_ARM64}
        -DSIMDJSON_JUST_LIBRARY=ON
        -DSIMDJSON_GOOGLE_BENCHMARKS=OFF
        -DSIMDJSON_COMPETITION=OFF
        -DSIMDJSON_SANITIZE=OFF # issue 10145, pr 11495
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
