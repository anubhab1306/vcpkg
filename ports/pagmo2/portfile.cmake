vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  esa/pagmo2 
    REF v2.15.0
    SHA512 992c8a00018a2e84ccdc0f1f5ef46e97f3ec5c3167366a8b836016f3a13d6f915b2a6ae7271e220e3c7ce89372cab5c69aa52bd9b416f8c88b68396b15d49231
    HEAD_REF master
    PATCHES static-build-support.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
   FEATURES
   nlopt  PAGMO_WITH_NLOPT
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PAGMO_BUILD_STATIC_LIBRARY)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPAGMO_WITH_EIGEN3=ON
        -DPAGMO_BUILD_STATIC_LIBRARY=${PAGMO_BUILD_STATIC_LIBRARY}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/pagmo)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING.lgpl3 DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
