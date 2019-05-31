# This portfile adds the Qt Cryptographic Arcitecture
# Changes to the original build:
#   No -qt5 suffix, which is recommended just for Linux
#   Output directories according to vcpkg
#   Updated certstore. See certstore.pem in the output dirs
#

include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_EXE_PATH})

if(EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/qca
    REF db5f82be2ad72658f7b575ebd1e97f4748033d04
    SHA512 28bb67648ed2407d066e434c31099d0b54f2662aa65c5d85d24357121d338aad8821910a99538d35afab8a5de6f2e69eeba7d7cef8794ab2c8240d0c76d37218
    PATCHES 0001-fix-path-for-vcpkg.patch
)

# According to:
#   https://www.openssl.org/docs/faq.html#USER16
# it is up to developers or admins to maintain CAs.
# So we do it here:
message(STATUS "Importing certstore")
file(REMOVE ${SOURCE_PATH}/certs/rootcerts.pem)
# Using file(DOWNLOAD) to use https
file(DOWNLOAD https://raw.githubusercontent.com/mozilla/gecko-dev/master/security/nss/lib/ckfw/builtins/certdata.txt
    ${CURRENT_BUILDTREES_DIR}/cert/certdata.txt
    TLS_VERIFY ON
)
vcpkg_execute_required_process(
    COMMAND ${PERL} ${CMAKE_CURRENT_LIST_DIR}/mk-ca-bundle.pl -n ${SOURCE_PATH}/certs/rootcerts.pem
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/cert
    LOGNAME ca-bundle
)
message(STATUS "Importing certstore done")

# Configure and build
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_RELATIVE_PATHS=ON
        -DQT4_BUILD=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_TOOLS=OFF
        -DQCA_SUFFIX=OFF
        -DQCA_FEATURE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/share/qca/mkspecs/features
    OPTIONS_DEBUG
        -DQCA_PLUGINS_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug/bin/Qca
    OPTIONS_RELEASE
        -DQCA_PLUGINS_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/bin/Qca
)

vcpkg_install_cmake()

# Patch and copy cmake files
message(STATUS "Patching files")
file(READ 
    ${CURRENT_PACKAGES_DIR}/debug/share/qca/cmake/QcaTargets-debug.cmake
    QCA_DEBUG_CONFIG
)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" QCA_DEBUG_CONFIG "${QCA_DEBUG_CONFIG}")
file(WRITE 
    ${CURRENT_PACKAGES_DIR}/share/qca/cmake/QcaTargets-debug.cmake
    "${QCA_DEBUG_CONFIG}"
)

file(READ ${CURRENT_PACKAGES_DIR}/share/qca/cmake/QcaTargets.cmake
    QCA_TARGET_CONFIG
)
string(REPLACE "packages/qca_" "installed/" QCA_TARGET_CONFIG "${QCA_TARGET_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/qca/cmake/QcaTargets.cmake
    "${QCA_TARGET_CONFIG}"
)

# Remove unneeded dirs
file(REMOVE_RECURSE 
    ${CURRENT_BUILDTREES_DIR}/share/man
    ${CURRENT_PACKAGES_DIR}/share/man
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)
message(STATUS "Patching files done")

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/qca)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/qca/COPYING ${CURRENT_PACKAGES_DIR}/share/qca/copyright)
