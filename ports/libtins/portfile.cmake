vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mfontanini/libtins
    REF v4.2
    SHA512 46d07712604c780e418135c996f195046fd85a9e1411962c9bcee3c8d0fc64f494aa50164236ffd1e77ff8a398e9617bbf040b3e01a5771c5621c0faa1ce312f
    HEAD_REF master
    PATCHES fix-tins-target.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBTINS_BUILD_SHARED)

set(ENABLE_PCAP FALSE)
if(VCPKG_TARGET_IS_WINDOWS)
  set(ENABLE_PCAP TRUE)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT LIBTINS_BUILD_SHARED)
  set(ENV{PACKET_LIB_PATH} ${CURRENT_INSTALLED_DIR}/lib/Packet.lib)
endif()
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLIBTINS_BUILD_SHARED=${LIBTINS_BUILD_SHARED}
        -DLIBTINS_ENABLE_PCAP=${ENABLE_PCAP}
)

vcpkg_install_cmake()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libtins)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtins RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME libtins)
