
set(VCPKG_FIRST_EGL_CALL OFF)
if(NOT TARGET EGL::EGL)
    set(VCPKG_FIRST_EGL_CALL ON)
endif()

set(HAVE_EGL ON CACHE INTERNAL "")
_find_package(${ARGS})

# TODO: FindEGL.cmake will need more love to find release/debug correctly.
#       For now only fix single config linkage

if(VCPKG_FIRST_EGL_CALL AND "${EGL_LIBRARY}" MATCHES "libEGL\\\.a$")
    find_library(VCPKG_GLESV2_LIBRARY NAMES GLESv2)
    set_property(TARGET EGL::EGL APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${VCPKG_GLESV2_LIBRARY}")
    #find_library(VCPKG_GL_LIBRARY NAMES GL) # FindOpenGL?
    #set_property(TARGET EGL::EGL APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${VCPKG_GL_LIBRARY}")
    find_library(VCPKG_ANGLE_LIBRARY NAMES ANGLE) 
    set_property(TARGET EGL::EGL APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${VCPKG_ANGLE_LIBRARY}")
    find_package(X11 COMPONENTS Xi Xext REQUIRED)
    set_property(TARGET EGL::EGL APPEND PROPERTY INTERFACE_LINK_LIBRARIES "X11::X11;X11::Xext;X11::Xi")
endif()
if(VCPKG_FIRST_EGL_CALL AND TARGET EGL::EGL AND UNIX)
    find_library(VCPKG_XNVCNTRL NAMES XNVCtrl)
    set_property(TARGET EGL::EGL APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${VCPKG_XNVCNTRL}")
endif()

unset(VCPKG_FIRST_EGL_CALL)
