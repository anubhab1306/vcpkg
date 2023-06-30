# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/optional
    REF boost-1.82.0
    SHA512 5439e9a1ecd2e74e7f9dfb958989edc0a68f0a9275fb8d472fcb32b6b8d120c9eb26e92a345485e0bb04950606cc065a9bfdf6a4cfc28602a5bcc8e13629e934
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
