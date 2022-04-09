set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES fix-taglib-search.patch # Strictly this is only required if qt does not use pkg-config since it forces it to off. 
                    49b44d4.diff)
set(TOOL_NAMES 
        ifmedia-simulation-server
        ifvehiclefunctions-simulation-server
    )

qt_download_submodule(PATCHES ${${PORT}_PATCHES})
if(QT_UPDATE_VERSION)
    return()
endif()

if(_qis_DISABLE_NINJA)
    set(_opt DISABLE_NINJA)
endif()

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${PYTHON3_DIR}")
vcpkg_add_to_path(PREPEND "${PYTHON3_DIR}/Scripts")
x_vcpkg_get_python_packages(PYTHON_EXECUTABLE "${PYTHON3}" PACKAGES virtualenv 
                                                                    Jinja2==2.10.3
                                                                    antlr4-python3-runtime==4.7.1
                                                                    argh==0.26.2
                                                                    click==6.7
                                                                    coloredlogs==10.0
                                                                    humanfriendly==4.15.1
                                                                    MarkupSafe==1.1
                                                                    path.py==11.0.1
                                                                    pathtools==0.1.2
                                                                    PyYAML==5.1
                                                                    six==1.11.0
                                                                    watchdog==0.8.3
                                                                    pytest==6.2.5
                                                                    pytest-cov==2.8.1
                                                                    qface==2.0.7)
file(COPY "${CURRENT_PORT_DIR}/requirements_minimal.txt" DESTINATION "${SOURCE_PATH}/src/3rdparty/qface")
if(VCPKG_CROSSCOMPILING)
    list(APPEND FEATURE_OPTIONS "-DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}")
endif()

set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)
qt_cmake_configure(${_opt} 
                   OPTIONS ${FEATURE_OPTIONS}
                        "-DPython3_EXECUTABLE=${PYTHON3}" # Otherwise a VS installation might be found. 
                        "-DQT_USE_MINIMAL_QFACE_PACKAGES=TRUE"
                   OPTIONS_DEBUG ${_qis_CONFIGURE_OPTIONS_DEBUG}
                   OPTIONS_RELEASE ${_qis_CONFIGURE_OPTIONS_RELEASE})

vcpkg_cmake_install(ADD_BIN_TO_PATH)

qt_fixup_and_cleanup(TOOL_NAMES ${TOOL_NAMES})

qt_install_copyright("${SOURCE_PATH}")

if(NOT VCPKG_CROSSCOMPILING)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/ifcodegen")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/ifcodegen" "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/ifcodegen")
endif()
