vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp" "emscripten" "wasm32" "android" "ios")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstreamer/gst-build
    REF 1.18.4
    SHA512 9b3927ba1a2ba1e384f2141c454978f582087795a70246709ed60875bc983a42eef54f3db7617941b8dacc20c434f81ef9931834861767d7a4dc09d42beeb900
    HEAD_REF master
)

if(VCPKG_TARGET_IS_OSX)
    # In Darwin platform, there can be an old version of `bison`, 
    # Which can't be used for `gst-build`. It requires 2.4+
    vcpkg_find_acquire_program(BISON)
    execute_process(
        COMMAND ${BISON} --version
        OUTPUT_VARIABLE BISON_OUTPUT
    )
    string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" BISON_VERSION "${BISON_OUTPUT}")
    set(BISON_MAJOR ${CMAKE_MATCH_1})
    set(BISON_MINOR ${CMAKE_MATCH_2})
    message(STATUS "Using bison: ${BISON_MAJOR}.${BISON_MINOR}.${CMAKE_MATCH_3}")
    if(NOT (BISON_MAJOR GREATER_EQUAL 2 AND BISON_MINOR GREATER_EQUAL 4))
        message(WARNING "'bison' upgrade is required. Please check the https://stackoverflow.com/a/35161881")
    endif()
elseif(VCPKG_TARGET_IS_WINDOWS)
    # make tools like 'glib-mkenums' visible
    get_filename_component(GLIB_TOOL_DIR ${CURRENT_INSTALLED_DIR}/tools/glib ABSOLUTE)
    message(STATUS "Using glib tools: ${GLIB_TOOL_DIR}")
    vcpkg_add_to_path(PREPEND ${GLIB_TOOL_DIR})
endif()

if("plugins-bad" IN_LIST FEATURES)
    # requires 'libdrm', 'dssim', 'libmicrodns'
    message(FATAL_ERROR "The feature 'plugins-bad' is not supported in this port version")
    set(PLUGIN_BAD_SUPPORT enabled)
else()
    set(PLUGIN_BAD_SUPPORT disabled)
endif()
if("plugins-ugly" IN_LIST FEATURES)
    set(PLUGIN_UGLY_SUPPORT enabled)
else()
    set(PLUGIN_UGLY_SUPPORT disabled)
endif()

if("nls" IN_LIST FEATURES)
    set(NATIVE_LANG_SUPPORT enabled)
else()
    set(NATIVE_LANG_SUPPORT disabled)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(LIBRARY_LINKAGE "shared")
else()
    set(LIBRARY_LINKAGE "static")
endif()

#
# check scripts/cmake/vcpkg_configure_meson.cmake
#   --wrap-mode=nodownload
#
# References
#   https://github.com/GStreamer/gst-build/blob/1.18.4/meson_options.txt
#   https://github.com/GStreamer/gst-plugins-base/blob/1.18.4/meson_options.txt
#   https://github.com/GStreamer/gst-plugins-good/blob/1.18.4/meson_options.txt
#   https://github.com/GStreamer/gst-plugins-bad/blob/1.18.4/meson_options.txt
#   https://github.com/GStreamer/gst-plugins-ugly/blob/1.18.4/meson_options.txt
#
vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # gstreamer
        -Dgstreamer:default_library=${LIBRARY_LINKAGE} # static, shared
        -Dgstreamer:check=disabled
        -Dgstreamer:libunwind=disabled
        -Dgstreamer:libdw=disabled
        -Dgstreamer:dbghelp=disabled
        -Dgstreamer:bash-completion=disabled
        -Dgstreamer:coretracers=disabled
        -Dgstreamer:examples=disabled
        -Dgstreamer:tests=disabled
        -Dgstreamer:benchmarks=disabled
        -Dgstreamer:tools=disabled
        -Dgstreamer:gtk_doc=disabled
        -Dgstreamer:introspection=disabled
        -Dgstreamer:nls=${NATIVE_LANG_SUPPORT}
        # gst-plugins-base
        -Dgst-plugins-base:default_library=${LIBRARY_LINKAGE}
        -Dgst-plugins-base:examples=disabled
        -Dgst-plugins-base:tests=disabled
        -Dgst-plugins-base:tools=disabled
        -Dgst-plugins-base:introspection=disabled
        -Dgst-plugins-base:nls=${NATIVE_LANG_SUPPORT}
        -Dgst-plugins-base:orc=disabled
        # gst-plugins-good
        -Dgst-plugins-good:default_library=${LIBRARY_LINKAGE}
        -Dgst-plugins-good:qt5=disabled
        -Dgst-plugins-good:soup=disabled
        -Dgst-plugins-good:speex=auto
        -Dgst-plugins-good:taglib=auto
        -Dgst-plugins-good:vpx=auto
        -Dgst-plugins-good:examples=disabled
        -Dgst-plugins-good:tests=disabled
        -Dgst-plugins-good:nls=${NATIVE_LANG_SUPPORT}
        -Dgst-plugins-good:orc=disabled
        # gst-plugins-bad
        -Dbad=${PLUGIN_BAD_SUPPORT}
        -Dgst-plugins-bad:default_library=${LIBRARY_LINKAGE}
        -Dgst-plugins-bad:opencv=disabled
        -Dgst-plugins-bad:hls-crypto=openssl
        -Dgst-plugins-bad:examples=disabled
        -Dgst-plugins-bad:tests=disabled
        -Dgst-plugins-bad:introspection=disabled
        -Dgst-plugins-bad:nls=${LIBRARY_LINKAGE}
        -Dgst-plugins-bad:orc=disabled
        # gst-plugins-ugly
        -Dugly=${PLUGIN_UGLY_SUPPORT}
        -Dgst-plugins-ugly:default_library=${LIBRARY_LINKAGE}
        -Dgst-plugins-ugly:tests=disabled
        -Dgst-plugins-ugly:nls=${NATIVE_LANG_SUPPORT}
        -Dgst-plugins-ugly:orc=disabled
        # see ${SOURCE_PATH}/meson_options.txt
        -Dpython=disabled
        -Dlibav=disabled
        -Ddevtools=disabled
        -Dges=disabled
        -Drtsp_server=disabled
        -Domx=disabled
        -Dvaapi=disabled
        -Dsharp=disabled
        -Drs=disabled
        -Dgst-examples=disabled
        -Dtls=disabled
        -Dtests=disabled    # common options
        -Dexamples=disabled
        -Dintrospection=disabled
        -Dnls=${NATIVE_LANG_SUPPORT}
        -Dorc=disabled
        -Ddoc=disabled
        -Dgtk_doc=disabled
    OPTIONS_DEBUG
        -Dgstreamer:gst_debug=true # gst-plugins-good references the value
        -Dgst-plugins-bad:gst_debug=true
    OPTIONS_RELEASE
        -Dgstreamer:gst_debug=false
        -Dgstreamer:gobject-cast-checks=disabled
        -Dgstreamer:glib-asserts=disabled
        -Dgstreamer:glib-checks=disabled
        -Dgstreamer:extra-checks=disabled
        -Dgst-plugins-base:gobject-cast-checks=disabled
        -Dgst-plugins-base:glib-asserts=disabled
        -Dgst-plugins-base:glib-checks=disabled
        -Dgst-plugins-good:gobject-cast-checks=disabled
        -Dgst-plugins-good:glib-asserts=disabled
        -Dgst-plugins-good:glib-checks=disabled
        -Dgst-plugins-bad:gst_debug=false
        -Dgst-plugins-bad:gobject-cast-checks=disabled
        -Dgst-plugins-bad:glib-asserts=disabled
        -Dgst-plugins-bad:glib-checks=disabled
)
vcpkg_install_meson()

vcpkg_copy_tools(
    TOOL_NAMES "gst-ptp-helper"
    SEARCH_DIR ${CURRENT_PACKAGES_DIR}/libexec
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/gstreamer-1.0
)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/gstreamer-1.0)

# Remove duplicated GL headers (we already have `opengl-registry`)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/KHR
                    ${CURRENT_PACKAGES_DIR}/include/GL
)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/include/gst/gl/gstglconfig.h 
            ${CURRENT_PACKAGES_DIR}/include/gstreamer-1.0/gst/gl/gstglconfig.h
)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/libexec
                    ${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/include
                    ${CURRENT_PACKAGES_DIR}/libexec
                    ${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/include
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin
                        ${CURRENT_PACKAGES_DIR}/bin
    )
endif()
