if(NOT WIN32)
    # Backup
    if(DEFINED CMAKE_FIND_USE_CMAKE_PATH)
        set(VCPKG_BACKUP_CMAKE_FIND_USE_CMAKE_PATH "${CMAKE_FIND_USE_CMAKE_PATH}")
    endif()
    if(DEFINED CMAKE_FIND_USE_CMAKE_SYSTEM_PATH)
        set(VCPKG_BACKUP_CMAKE_FIND_USE_CMAKE_SYSTEM_PATH "${CMAKE_FIND_USE_CMAKE_SYSTEM_PATH}")
    endif()
    # Overwrite
    set(CMAKE_FIND_USE_CMAKE_PATH FALSE)
    set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH FALSE)
    _find_package(${ARGS})
    # Restore
    if(DEFINED VCPKG_BACKUP_CMAKE_FIND_USE_CMAKE_SYSTEM_PATH)
        set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH "${VCPKG_BACKUP_CMAKE_FIND_USE_CMAKE_SYSTEM_PATH}")
    else()
        unset(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH)
    endif()
    if(DEFINED VCPKG_BACKUP_CMAKE_FIND_USE_CMAKE_PATH)
        set(CMAKE_FIND_USE_CMAKE_PATH "${VCPKG_BACKUP_CMAKE_FIND_USE_CMAKE_PATH}")
    else()
        unset(CMAKE_FIND_USE_CMAKE_PATH)
    endif()
else()
    _find_package(${ARGS})
endif()

