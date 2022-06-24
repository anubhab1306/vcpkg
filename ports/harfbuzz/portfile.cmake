vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 4.2.0
    SHA512 2aff1e6a41d6186b71f2915296c46c0b2ffc67371e1f05c13a62c237ff7a84d7d78d414d7a395e1616a2861c83c4792ef5936a492713780564b994d18e2d3e38
    HEAD_REF master
)

if("icu" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dicu=enabled) # Enable ICU library unicode functions
else()
    list(APPEND FEATURE_OPTIONS -Dicu=disabled)
endif()
if("graphite2" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dgraphite=enabled) #Enable Graphite2 complementary shaper
else()
    list(APPEND FEATURE_OPTIONS -Dgraphite=disabled)
endif()
if("coretext" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dcoretext=enabled) # Enable CoreText shaper backend on macOS
else()
    list(APPEND FEATURE_OPTIONS -Dcoretext=disabled)
endif()
if("glib" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dglib=enabled) # Enable GLib unicode functions
    list(APPEND FEATURE_OPTIONS -Dgobject=enabled) #Enable GObject bindings
else()
    list(APPEND FEATURE_OPTIONS -Dglib=disabled)
    list(APPEND FEATURE_OPTIONS -Dgobject=disabled)
endif()
list(APPEND FEATURE_OPTIONS -Dfreetype=enabled) #Enable freetype interop helpers
#if(VCPKG_TARGET_IS_WINDOWS)
    #link errors in qt5-base. probably requires changes to the pc files generated by meson
    #list(APPEND FEATURE_OPTIONS -Dgdi=enabled) # enable gdi helpers and uniscribe shaper backend (windows only)
#endif()


vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dcairo=disabled # Use Cairo graphics library
        -Dintrospection=disabled # Generate gobject-introspection bindings (.gir/.typelib files)
        -Ddocs=disabled          # Generate documentation with gtk-doc
        -Dtests=disabled
        -Dbenchmark=disabled
    ADDITIONAL_NATIVE_BINARIES  glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                                glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
    ADDITIONAL_CROSS_BINARIES   glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                                glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
	file(GLOB PC_FILES 
		"${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc" 
		"${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc")
	
	foreach(PC_FILE IN LISTS PC_FILES)
		file(READ "${PC_FILE}" PC_FILE_CONTENT)
		string(REGEX REPLACE 
			"\\$\\{prefix\}\\/lib\\/([a-zA-Z0-9\-]*)\\.lib" 
			"-l\\1" PC_FILE_CONTENT 
			"${PC_FILE_CONTENT}")
		file(WRITE "${PC_FILE}" ${PC_FILE_CONTENT})
	endforeach()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
configure_file("${CMAKE_CURRENT_LIST_DIR}/harfbuzzConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/harfbuzzConfig.cmake" @ONLY)

vcpkg_list(SET TOOL_NAMES)
if("glib" IN_LIST FEATURES)
    vcpkg_list(APPEND TOOL_NAMES hb-subset hb-shape hb-ot-shape-closure)
endif()
if(TOOL_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
