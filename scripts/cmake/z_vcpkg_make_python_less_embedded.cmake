include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_replace_string.cmake")

if("${PYTHON_DIR}" STREQUAL "")
    message(FATAL_ERROR "PYTHON_DIR is required.")
endif()

if("${VERSION}" STREQUAL "")
    message(FATAL_ERROR "VERSION is required.")
endif()

string(REGEX MATCH "^3\\.[0-9]+" _python_version_plain "${VERSION}")
string(REPLACE "." "" _python_version_plain "${_python_version_plain}")

vcpkg_replace_string("${PYTHON_DIR}/python${_python_version_plain}._pth" "#import site" "import site")
file(WRITE "${PYTHON_DIR}/sitecustomize.py"
"import sys

sys.path.insert(0, '')
"
)
