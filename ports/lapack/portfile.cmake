SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(READ "${CURRENT_PORT_DIR}/vcpkg.json" manifest_contents)
string(JSON ver_str GET "${manifest_contents}" version-string)

if(ver_str STREQUAL "default")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(BLA_STATIC ON)
    else()
        set(BLA_STATIC OFF)
    endif()

    set(BLA_VENDOR Generic)
    set(installed_wrapper "${CURRENT_INSTALLED_DIR}/share/lapack/vcpkg-cmake-wrapper.cmake")
    set(installed_module "${CURRENT_INSTALLED_DIR}/share/lapack/FindLAPACK.cmake")
    if(VCPKG_TARGET_IS_OSX)
        set(BLA_VENDOR Apple)
        configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/lapack/vcpkg-cmake-wrapper.cmake" @ONLY)
        set(libs "-framework Accelerate")
        set(cflags "-framework Accelerate")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/lapack.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack.pc" @ONLY)
        if(NOT VCPKG_BUILD_TYPE)
            configure_file("${CMAKE_CURRENT_LIST_DIR}/lapack.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack.pc" @ONLY)
        endif()
        unset(installed_module)
    elseif((VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm") OR VCPKG_TARGET_IS_UWP)
        configure_file("${CURRENT_INSTALLED_DIR}/share/clapack/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/lapack/vcpkg-cmake-wrapper.cmake" COPYONLY)
        configure_file("${CURRENT_INSTALLED_DIR}/share/clapack/FindLAPACK.cmake" "${CURRENT_PACKAGES_DIR}/share/lapack/FindLAPACK.cmake" COPYONLY)
        set(libs "-llapack -llibf2c")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/lapack.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack.pc" @ONLY)
        if(NOT VCPKG_BUILD_TYPE)
            set(libs "-llapackd -llibf2cd")
            configure_file("${CMAKE_CURRENT_LIST_DIR}/lapack.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack.pc" @ONLY)
        endif()
    else()
        configure_file("${CURRENT_INSTALLED_DIR}/share/lapack-reference/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/lapack/vcpkg-cmake-wrapper.cmake" COPYONLY)
        configure_file("${CURRENT_INSTALLED_DIR}/share/lapack-reference/FindLAPACK.cmake" "${CURRENT_PACKAGES_DIR}/share/lapack/FindLAPACK.cmake" COPYONLY)
    endif()
endif()