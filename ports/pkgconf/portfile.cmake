vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pkgconf/pkgconf
    REF "pkgconf-${VERSION}"
    SHA512 182a186c0cb8fa0abd7b23809eef5956f7c0b924076bad0d61c0221536497ee339b16ec69dae432b3e8ed6e016da6f2b1905fb377856939cbcd15c7ac4612762
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_PKG_CONFIG
    OPTIONS -Dtests=disabled
)

set(systemsuffix "")
set(architectureprefix "")

set(SYSTEM_LIBDIR "")
set(PKG_DEFAULT_PATH "")
set(SYSTEM_INCLUDEDIR "")
set(PERSONALITY_PATH "personality.d")


if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_CROSSCOMPILING AND VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    # These defaults are obtained from pkgconf/pkg-config on Ubuntu and OpenSuse
    # vcpkg cannot do system introspection to obtain/set these values since it would break binary caching.
    set(SYSTEM_INCLUDEDIR "/usr/include")
    # System lib dirs will be stripped from -L from the pkg-config output
    set(SYSTEM_LIBDIR "/lib:/lib/i386-linux-gnu:/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnux32:/lib64:/lib32:/libx32:/usr/lib:/usr/lib/i386-linux-gnu:/usr/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnux32:/usr/lib64:/usr/lib32:/usr/libx32")
    set(PKG_DEFAULT_PATH "/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig")
    set(PERSONALITY_PATH "/usr/share/pkgconfig/personality.d:/etc/pkgconfig/personality.d")
endif()

if(DEFINED VCPKG_pkgconf_SYSTEM_LIBDIR)
    set(SYSTEM_LIBDIR "${VCPKG_pkgconf_SYSTEM_LIBDIR}")
endif()
if(DEFINED VCPKG_pkgconf_PKG_DEFAULT_PATH)
    set(PKG_DEFAULT_PATH "${VCPKG_pkgconf_PKG_DEFAULT_PATH}")
endif()
if(DEFINED VCPKG_pkgconf_SYSTEM_INCLUDEDIR)
    set(SYSTEM_INCLUDEDIR "${VCPKG_pkgconf_SYSTEM_INCLUDEDIR}")
endif()
if(DEFINED VCPKG_pkgconf_PERSONALITY_PATH)
    set(PERSONALITY_PATH "${VCPKG_pkgconf_PERSONALITY_PATH}")
endif()


set(pkgconfig_file "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libpkgconf/config.h")
if(EXISTS "${pkgconfig_file}")
    file(READ "${pkgconfig_file}" contents)
    string(REGEX REPLACE "#define PKG_DEFAULT_PATH [^\n]+" "#define PKG_DEFAULT_PATH \"${PKG_DEFAULT_PATH}\"" contents "${contents}")
    string(REGEX REPLACE "#define SYSTEM_INCLUDEDIR [^\n]+" "#define SYSTEM_INCLUDEDIR \"${SYSTEM_INCLUDEDIR}\"" contents "${contents}")
    string(REGEX REPLACE "#define SYSTEM_LIBDIR [^\n]+" "#define SYSTEM_LIBDIR \"${SYSTEM_LIBDIR}\"" contents "${contents}")
    string(REGEX REPLACE "#define PERSONALITY_PATH [^\n]+" "#define PERSONALITY_PATH \"${PERSONALITY_PATH}\"" contents "${contents}")
    file(WRITE "${pkgconfig_file}" "${contents}")
endif()
set(pkgconfig_file "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libpkgconf/config.h")
if(EXISTS "${pkgconfig_file}")
    file(READ "${pkgconfig_file}" contents)
    string(REGEX REPLACE "#define PKG_DEFAULT_PATH [^\n]+" "#define PKG_DEFAULT_PATH \"${PKG_DEFAULT_PATH}\"" contents "${contents}")
    string(REGEX REPLACE "#define SYSTEM_INCLUDEDIR [^\n]+" "#define SYSTEM_INCLUDEDIR \"${SYSTEM_INCLUDEDIR}\"" contents "${contents}")
    string(REGEX REPLACE "#define SYSTEM_LIBDIR [^\n]+" "#define SYSTEM_LIBDIR \"${SYSTEM_LIBDIR}\"" contents "${contents}")
    string(REGEX REPLACE "#define PERSONALITY_PATH [^\n]+" "#define PERSONALITY_PATH \"${PERSONALITY_PATH}\"" contents "${contents}")
    file(WRITE "${pkgconfig_file}" "${contents}")
endif()

vcpkg_install_meson()
vcpkg_fixup_pkgconfig(SKIP_CHECK)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pkgconf/libpkgconf/libpkgconf-api.h" "#if defined(PKGCONFIG_IS_STATIC)" "#if 1")
endif()

vcpkg_copy_tools(TOOL_NAMES pkgconf AUTO_CLEAN)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
