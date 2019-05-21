option(VCPKG_ENABLE_SET_TARGET_PROPERTIES "Enables override of the cmake function set_target_properties." ON)
mark_as_advanced(VCPKG_ENABLE_SET_TARGET_PROPERTIES)
CMAKE_DEPENDENT_OPTION(VCPKG_ENABLE_SET_TARGET_PROPERTIES_EXTERNAL_OVERRIDE "Tells VCPKG to use _set_target_properties instead of set_target_properties." OFF "NOT VCPKG_ENABLE_SET_TARGET_PROPERTIES" OFF)
mark_as_advanced(VCPKG_ENABLE_SET_TARGET_PROPERTIES_EXTERNAL_OVERRIDE)

function(vcpkg_set_target_properties)
    list(FIND ARGV PROPERTIES _vcpkg_properties_pos)
    list(SUBLIST ARGV 0 ${_vcpkg_properties_pos} _vcpkg_target_sublist)
    math(EXPR _vcpkg_target_index_key "${_vcpkg_properties_pos}+1")
    vcpkg_msg(STATUS "set_target_properties" "ARGS: ${ARGV}")
    vcpkg_msg(STATUS "set_target_properties" "PROPERTIES Index: ${_vcpkg_properties_pos}")
    vcpkg_msg(STATUS "set_target_properties" "TARGETS: ${_vcpkg_target_sublist}")
    #Properties are key-value pairs and must be passed one by one since they are allowed to contain empty elements!
    while("${_vcpkg_target_index_key}" LESS "${ARGC}")
        math(EXPR _vcpkg_target_args_index_val "${_vcpkg_target_index_key}+1")
        vcpkg_msg(STATUS "set_target_properties" "Property: ARGV${_vcpkg_target_index_key}: ${ARGV${_vcpkg_target_index_key}}")
        vcpkg_msg(STATUS "set_target_properties" "Value: ARGV${_vcpkg_target_args_index_val}: ${ARGV${_vcpkg_target_args_index_val}}")
        if(VCPKG_ENABLE_SET_TARGET_PROPERTIES OR VCPKG_ENABLE_SET_TARGET_PROPERTIES_EXTERNAL_OVERRIDE)
            _set_target_properties(${_vcpkg_target_sublist} PROPERTIES "${ARGV${_vcpkg_target_index_key}}" "${ARGV${_vcpkg_target_args_index_val}}")
        else()
            set_target_properties(${_vcpkg_target_sublist} PROPERTIES "${ARGV${_vcpkg_target_args_index}}" "${ARGV${_vcpkg_target_args_index_val}}")
        endif()
        math(EXPR _vcpkg_target_index_key "${_vcpkg_target_args_index_val}+1")
    endwhile()

    if(NOT "${ARGV}" MATCHES "IMPORTED_LOCATION|IMPORTED_LOCATION_RELEASE|IMPORTED_LOCATION_DEBUG")
        return() # early abort to not generate too much noise. We are only interested in the above cases
    endif()

    get_target_property(_vcpkg_target_imported ${_vcpkg_target_name} IMPORTED)
    if(_vcpkg_target_imported)
        vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} is an IMPORTED target. Checking import location (if available)!")
        get_target_property(_vcpkg_target_imp_loc ${_vcpkg_target_name} IMPORTED_LOCATION)
        get_target_property(_vcpkg_target_imp_loc_rel ${_vcpkg_target_name} IMPORTED_LOCATION_RELEASE)
        get_target_property(_vcpkg_target_imp_loc_dbg ${_vcpkg_target_name} IMPORTED_LOCATION_DEBUG)
        # Release location
        if(_vcpkg_target_imp_loc_rel AND "${_vcpkg_target_imp_loc_rel}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
            vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} has property IMPORTED_LOCATION_RELEASE: ${_vcpkg_target_imp_loc_rel}. Checking for correct vcpkg path!")
            if("${_vcpkg_target_imp_loc_rel}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug")
                #This is the death case. If we reach this line the linkage of the target will be wrong!
                vcpkg_msg(FATAL_ERROR "set_target_properties" "Property IMPORTED_LOCATION_DEBUG: ${_vcpkg_target_imp_loc_rel}. Not set to vcpkg release library dir!" ALWAYS)
            else()
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION_RELEASE is correct: ${_vcpkg_target_imp_loc_rel}.")
            endif()
        endif()
        # Debug location
        if(_vcpkg_target_imp_loc_dbg AND "${_vcpkg_target_imp_loc_dbg}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
            vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} has property IMPORTED_LOCATION_DEBUG: ${_vcpkg_target_imp_loc_dbg}. Checking for correct vcpkg path!")
            if(NOT "${_vcpkg_target_imp_loc_dbg}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug")
                #This is the death case. If we reach this line the linkage of the target will be wrong!
                vcpkg_msg(FATAL_ERROR "set_target_properties" "Property IMPORTED_LOCATION_DEBUG: ${_vcpkg_target_imp_loc_dbg}. Not set to vcpkg debug library dir!" ALWAYS)
            else()
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION_DEBUG is correct: ${_vcpkg_target_imp_loc_dbg}.")
            endif()
        endif()
        # General import location. Here we assume changes made by find_library to the library name 
        if(_vcpkg_target_imp_loc AND "${_vcpkg_target_imp_loc}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
             vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} has property IMPORTED_LOCATION: ${_vcpkg_target_imp_loc}. Checking for generator expression!")
            if("${_vcpkg_target_imp_loc}" MATCHES "\\$<\\$<CONFIG:DEBUG>:debug/>") # This generator expressions was added by vcpkgs find_library call
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION Contains generator expression inserted by vcpkg. Fixing locations.")
                string(REPLACE "$<$<CONFIG:DEBUG>:debug/>lib/" "lib/"       _vcpkg_target_imp_loc_rel_tmp "${_vcpkg_target_imp_loc}")
                string(REPLACE "$<$<CONFIG:DEBUG>:debug/>lib/" "debug/lib/" _vcpkg_target_imp_loc_dbg_tmp "${_vcpkg_target_imp_loc}")
                foreach(_vcpkg_debug_suffix ${VCPKG_ADDITIONAL_DEBUG_LIBNAME_SEARCH_SUFFIXES})
                    string(REPLACE "$<$<CONFIG:DEBUG>:${_vcpkg_debug_suffix}>" "" _vcpkg_target_imp_loc_rel_tmp "${_vcpkg_target_imp_loc_rel_tmp}")
                    string(REPLACE "$<$<CONFIG:DEBUG>:${_vcpkg_debug_suffix}>" "${_vcpkg_debug_suffix}" _vcpkg_target_imp_loc_dbg_tmp "${_vcpkg_target_imp_loc_dbg_tmp}")
                endforeach()
                if(VCPKG_ENABLE_SET_TARGET_PROPERTIES OR VCPKG_ENABLE_SET_TARGET_PROPERTIES_EXTERNAL_OVERRIDE)
                    _set_target_properties(${_vcpkg_target_name} 
                                        PROPERTIES 
                                            IMPORTED_LOCATION_RELEASE "${_vcpkg_target_imp_loc_rel_tmp}"
                                            IMPORTED_LOCATION_DEBUG "${_vcpkg_target_imp_loc_dbg_tmp}"
                                            IMPORTED_LOCATION "${_vcpkg_target_imp_loc_rel_tmp}")
                else()
                    set_target_properties(${_vcpkg_target_name} 
                                        PROPERTIES 
                                            IMPORTED_LOCATION_RELEASE "${_vcpkg_target_imp_loc_rel_tmp}"
                                            IMPORTED_LOCATION_DEBUG "${_vcpkg_target_imp_loc_dbg_tmp}"
                                            IMPORTED_LOCATION "${_vcpkg_target_imp_loc_rel_tmp}")
                endif()
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION_RELEASE set to: ${_vcpkg_target_imp_loc_rel_tmp}")
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION_DEBUG set to: ${_vcpkg_target_imp_loc_dbg_tmp}")
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION set to: ${_vcpkg_target_imp_loc_rel_tmp}")
            else()
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION does not contain generator expression generated by vcpkg-find_library!")
            endif()
        endif()
    endif()
endfunction()

if(VCPKG_ENABLE_SET_TARGET_PROPERTIES)
    function(set_target_properties)
        if(DEFINED _vcpkg_set_target_properties_guard)
            vcpkg_msg(FATAL_ERROR "set_target_properties" "INFINIT LOOP DETECT. Did you supply your own set_target_properties override? \n \
                                    If yes: please set VCPKG_ENABLE_SET_TARGET_PROPERTIES off and call vcpkg_set_target_properties if you want to have vcpkg corrected behavior. \n \
                                    If no: please open an issue on GITHUB describe the fail case!" ALWAYS)
        else()
            set(_vcpkg_set_target_properties_guard ON)
        endif()

        list(FIND ARGV PROPERTIES _vcpkg_set_target_properties_index)
        list(SUBLIST ARGV 0 ${_vcpkg_set_target_properties_index} _vcpkg_set_target_properties_sublist)
        math(EXPR _vcpkg_set_target_properties_index_key "${_vcpkg_set_target_properties_index}+1")
        #vcpkg_msg(STATUS "set_target_properties" "ARGC: ${ARGC} ARGS: ${ARGV}")
        #vcpkg_msg(STATUS "set_target_properties" "PROPERTIES Index: ${_vcpkg_set_target_properties_index}")
        #vcpkg_msg(STATUS "set_target_properties" "TARGETS: ${vcpkg_set_target_properties_sublist}")
        #Properties are key-value pairs and must be passed one by one since they are allowed to contain empty elements!
        while("${_vcpkg_set_target_properties_index_key}" LESS "${ARGC}")
            math(EXPR _vcpkg_set_target_properties_index_val "${_vcpkg_set_target_properties_index_key}+1")
            #vcpkg_msg(STATUS "set_target_properties" "Key: ARGV${_vcpkg_set_target_properties_index_key}: ${ARGV${_vcpkg_set_target_properties_index_key}}")
            #vcpkg_msg(STATUS "set_target_properties" "Value: ARGV${_vcpkg_set_target_properties_index_val}: ${ARGV${_vcpkg_set_target_properties_index_val}}")
            vcpkg_set_target_properties(${_vcpkg_set_target_properties_sublist} PROPERTIES "${ARGV${_vcpkg_set_target_properties_index_key}}" "${ARGV${_vcpkg_set_target_properties_index_val}}")
            math(EXPR _vcpkg_set_target_properties_index_key "${_vcpkg_set_target_properties_index_val}+1")
        endwhile()

        unset(_vcpkg_set_target_properties_guard)
    endfunction()
endif()