# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/phoenix
    REF boost-1.80.0
    SHA512 a8afd8d8318f9267cf4021de62d85332503a38b3f71ee6161f3b459e8fe890ab89813e99ac5d082b2dee7012797631b6641881d2964f5e964c6000ca02a13703
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
