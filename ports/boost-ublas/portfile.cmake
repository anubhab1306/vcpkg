# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/ublas
    REF boost-1.82.0
    SHA512 09b22a1e13348c110a38f504068bb6ed44945168c3749357cd6783193c11645680a92ebd7cddb5c4d6db4f4870b3f6a95c5e2b40cc4282e994da605700cdf868
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
