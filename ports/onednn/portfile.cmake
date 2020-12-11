vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneDNN
    REF v2.0
    SHA512 740fa871e29edc8bb8a54d4ba615e856712f7f63efe4c70f4a3d5f6d143d60bc51366b9355ab4b6702718ba711b48350ea49b1335ec10c1dc4f655cc9728ff3e
    HEAD_REF master
)

# BLAS vendor
if ("mkl" IN_LIST FEATURES)
  list(APPEND DNNL_OPTIONS "-DDNNL_BLAS_VENDOR=MKL")
endif()

# Linkeage (oneDNN default is shared)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)
if (ENABLE_STATIC)
  list(APPEND DNNL_OPTIONS "-DDNNL_LIBRARY_TYPE=STATIC")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${DNNL_OPTIONS}
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Copyright and license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/onednn RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/onednn RENAME license)
