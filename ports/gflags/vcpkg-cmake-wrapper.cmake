if(NOT DEFINED GFLAGS_USE_TARGET_NAMESPACE)
    # vcpkg legacy
    set(GFLAGS_USE_TARGET_NAMESPACE ON)
    z_vcpkg_underlying_find_package(${ARGS})
    unset(GFLAGS_USE_TARGET_NAMESPACE)
endif()
z_vcpkg_underlying_find_package(${ARGS})
