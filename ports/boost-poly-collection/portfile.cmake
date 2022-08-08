# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/poly_collection
    REF boost-1.80.0.beta1
    SHA512 3298231e9c39497c3af2fc02ec24c0ce6334189d9b1f4c02b30df5ca92cdb04551ede97d94b19fa112069f0cebbb20128a6cd1844f3bfea0052a18ab82d737e9
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
