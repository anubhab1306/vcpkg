# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/describe
    REF boost-1.80.0.beta1
    SHA512 5fb955daf92e2d57d9b484023394ac32d422aacff905232341f3c4e148315e08be5acf84823b2e8e6b751f97019aacc8431793428ba8959ad115bee9c19d32f7
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
