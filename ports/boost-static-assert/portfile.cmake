# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/static_assert
    REF boost-1.82.0
    SHA512 334b467feaf8ec091dd21e78cf85b60f79d59316a6c1b43840a006c7bd373734b2f3403ba8bb8924f60f08fe339cee9df392e1c883b8c5f4319ec9efc5ae879e
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
