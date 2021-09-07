#[===[.md:
# vcpkg_make_configure

Configure a Makefile buildsystem.

```cmake
vcpkg_make_configure(
    SOURCE_PATH <${source_path}>
    [AUTOCONFIG]
    [USE_WRAPPERS]
    [DETERMINE_BUILD_TRIPLET]
    [BUILD_TRIPLET "--host=x64 --build=i686-unknown-pc"]
    [NO_ADDITIONAL_PATHS]
    [CONFIG_DEPENDENT_ENVIRONMENT <some_var>...]
    [CONFIGURE_ENVIRONMENT_VARIABLES <some_envvar>...]
    [ADD_BIN_TO_PATH]
    [NO_DEBUG]
    [SKIP_CONFIGURE]
    [PROJECT_SUBPATH <${proj_subpath}>]
    [PRERUN_SHELL <${shell_path}>]
    [OPTIONS <--use_this_in_all_builds=1>...]
    [OPTIONS_RELEASE <--optimize=1>...]
    [OPTIONS_DEBUG <--debuggable=1>...]
)
```

`vcpkg_make_configure` configures a Makefile build system for use with
`vcpkg_make_buildsystem_build` and `vcpkg_make_buildsystem_install`.
`source-path` is where the source is located; by convention,
this is usually `${SOURCE_PATH}`, which is set by one of the `vcpkg_from_*` functions.
Use `PROJECT_SUBPATH` if `configure`/`configure.ac` is elsewhere in the source directory.
This function configures the build system for both Debug and Release builds by default,
assuming that `VCPKG_BUILD_TYPE` is not set; if it is, then it will only configure for
that build type. All default build configurations will be obtained from cmake
configuration through `z_vcpkg_get_cmake_vars`.

Use the `OPTIONS` argument to set the configure settings for both release and debug,
and use `OPTIONS_RELEASE` and `OPTIONS_DEBUG` to set the configure settings for
release only and debug only respectively.

`vcpkg_make_configure` uses [mingw] as its build system on Windows and uses [GNU Make]
on non-Windows.
Do not use for batch files which simply call autoconf or configure.

[mingw]: https://www.mingw-w64.org/
[GNU Make]: https://www.gnu.org/software/make/

By default, `vcpkg_make_configure` uses the current architecture as the --build/--target/--host.
For cross-platform construction, use `DETERMINE_BUILD_TRIPLET` to adapt to the host platform.
You can also use `BUILD_TRIPLET` to specify --build/--target/--host, this option will overwrite
`VCPKG_MAKE_BUILD_TRIPLET` globally.

For some libraries, additional scripts need to be called before configure, pass `PRERUN_SHELL`
and set the script relative path.

Use `ADD_BIN_TO_PATH` during configuration to add the appropriate Release and Debug `bin\`
directories to the path so that the executable file can run against the in-tree DLL.
Use `NO_ADDITIONAL_PATHS `to not add additional paths except `--prefix` to configure.

Use `USE_WRAPPERS` to use autotools ar-lib and compile wrappers when building Windows.

Use `DISABLE_VERBOSE_FLAGS` to not pass '--disable-silent-rules --verbose' to configure.

## Notes
This command supplies many common arguments to configure. To see the full list, examine the source.

## Examples

* [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
* [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)
#]===]

if(Z_VCPKG_MAKE_CONFIGURE_GUARD)
    return()
endif()
set(Z_VCPKG_CAKE_CONFIGURE_GUARD ON CACHE INTERNAL "guard variable")

macro(z_vcpkg_determine_host_mingw out_var)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(host_arch $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(host_arch $ENV{PROCESSOR_ARCHITECTURE})
    endif()
    if(host_arch MATCHES "(amd|AMD)64")
        set(${out_var} mingw64)
    elseif(host_arch MATCHES "(x|X)86")
        set(${out_var} mingw32)
    else()
        message(FATAL_ERROR "Unsupported mingw architecture ${host_arch} in z_vcpkg_determine_autotools_host_cpu!" )
    endif()
    unset(host_arch)
endmacro()

macro(z_vcpkg_determine_autotools_host_cpu out_var)
    # TODO: the host system processor architecture can differ from the host triplet target architecture
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(host_arch $ENV{PROCESSOR_ARCHITEW6432})
    elseif(DEFINED ENV{PROCESSOR_ARCHITECTURE})
        set(host_arch $ENV{PROCESSOR_ARCHITECTURE})
    else()
        set(host_arch "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
    endif()
    if(host_arch MATCHES "(amd|AMD)64")
        set(${out_var} x86_64)
    elseif(host_arch MATCHES "(x|X)86")
        set(${out_var} i686)
    elseif(host_arch MATCHES "^(ARM|arm)64$")
        set(${out_var} aarch64)
    elseif(host_arch MATCHES "^(ARM|arm)$")
        set(${out_var} arm)
    else()
        message(FATAL_ERROR "Unsupported host architecture ${host_arch} in z_vcpkg_determine_autotools_host_cpu!" )
    endif()
    unset(host_arch)
endmacro()

macro(z_vcpkg_determine_autotools_target_cpu out_var)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)64")
        set(${out_var} x86_64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)86")
        set(${out_var} i686)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)64$")
        set(${out_var} aarch64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)$")
        set(${out_var} arm)
    else()
        message(FATAL_ERROR "Unsupported VCPKG_TARGET_ARCHITECTURE architecture ${VCPKG_TARGET_ARCHITECTURE} in z_vcpkg_determine_autotools_target_cpu!" )
    endif()
endmacro()

macro(z_vcpkg_determine_autotools_host_arch_mac out_var)
    set(${out_var} "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
endmacro()

macro(z_vcpkg_determine_autotools_target_arch_mac out_var)
    list(LENGTH VCPKG_OSX_ARCHITECTURES osx_archs_num)
    if(osx_archs_num EQUAL 0)
        set(${out_var} "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
    elseif(osx_archs_num GREATER_EQUAL 2)
        set(${out_var} "universal")
    else()
        # Better match the arch behavior of config.guess
        # See: https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD
        if(VCPKG_OSX_ARCHITECTURES MATCHES "^(ARM|arm)64$")
            set(${out_var} "aarch64")
        else()
            set(${out_var} "${VCPKG_OSX_ARCHITECTURES}")
        endif()
    endif()
    unset(osx_archs_num)
endmacro()

macro(z_vcpkg_backup_env_variable envvar)
    if(DEFINED ENV{${envvar}})
        set(${envvar}_backup "$ENV{${envvar}}")
        set(${envvar}_pathlike_concat "${VCPKG_HOST_PATH_SEPARATOR}$ENV{${envvar}}")
    else()
        set(${envvar}_backup)
        set(${envvar}_pathlike_concat)
    endif()
endmacro()

macro(z_vcpkg_backup_env_variables)
    foreach(_var ${ARGV})
        z_vcpkg_backup_env_variable(${_var})
    endforeach()
endmacro()

macro(z_vcpkg_restore_env_variable envvar)
    if(${envvar}_backup)
        set(ENV{${envvar}} "${${envvar}_backup}")
    else()
        unset(ENV{${envvar}})
    endif()
endmacro()

macro(z_vcpkg_restore_env_variables)
    foreach(_var ${ARGV})
        z_vcpkg_restore_env_variable(${_var})
    endforeach()
endmacro()

macro(z_vcpkg_extract_cpp_flags_and_set_cflags_and_cxxflags flag_suffix)
    string(REGEX MATCHALL "( |^)-D[^ ]+" CPPFLAGS_${flag_suffix} "${VCPKG_DETECTED_CMAKE_C_FLAGS_${flag_suffix}}")
    string(REGEX MATCHALL "( |^)-D[^ ]+" CXXPPFLAGS_${flag_suffix} "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${flag_suffix}}")
    list(JOIN CXXPPFLAGS_${flag_suffix} "|" CXXREGEX)
    if(CXXREGEX)
        list(FILTER CPPFLAGS_${flag_suffix} INCLUDE REGEX "(${CXXREGEX})")
    else()
        set(CPPFLAGS_${flag_suffix})
    endif()
    list(JOIN CPPFLAGS_${flag_suffix} "|" CPPREGEX)
    list(JOIN CPPFLAGS_${flag_suffix} " " CPPFLAGS_${flag_suffix})
    set(CPPFLAGS_${flag_suffix} "${CPPFLAGS_${flag_suffix}}")
    if(CPPREGEX)
        string(REGEX REPLACE "(${CPPREGEX})" "" CFLAGS_${flag_suffix} "${VCPKG_DETECTED_CMAKE_C_FLAGS_${flag_suffix}}")
        string(REGEX REPLACE "(${CPPREGEX})" "" CXXFLAGS_${flag_suffix} "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${flag_suffix}}")
    else()
        set(CFLAGS_${flag_suffix} "${VCPKG_DETECTED_CMAKE_C_FLAGS_${flag_suffix}}")
        set(CXXFLAGS_${flag_suffix} "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${flag_suffix}}")
    endif()
    string(REGEX REPLACE " +" " " CPPFLAGS_${flag_suffix} "${CPPFLAGS_${flag_suffix}}")
    string(REGEX REPLACE " +" " " CFLAGS_${flag_suffix} "${CFLAGS_${flag_suffix}}")
    string(REGEX REPLACE " +" " " CXXFLAGS_${flag_suffix} "${CXXFLAGS_${flag_suffix}}")
    # libtool has and -R option so we need to guard against -RTC by using -Xcompiler
    # while configuring there might be a lot of unknown compiler option warnings due to that
    # just ignore them. 
    string(REGEX REPLACE "((-|/)RTC[^ ]+)" "-Xcompiler \\1" CFLAGS_${flag_suffix} "${CFLAGS_${flag_suffix}}")
    string(REGEX REPLACE "((-|/)RTC[^ ]+)" "-Xcompiler \\1" CXXFLAGS_${flag_suffix} "${CXXFLAGS_${flag_suffix}}")
    string(STRIP "${CPPFLAGS_${flag_suffix}}" CPPFLAGS_${flag_suffix})
    string(STRIP "${CFLAGS_${flag_suffix}}" CFLAGS_${flag_suffix})
    string(STRIP "${CXXFLAGS_${flag_suffix}}" CXXFLAGS_${flag_suffix})
    debug_message("CPPFLAGS_${flag_suffix}: ${CPPFLAGS_${flag_suffix}}")
    debug_message("CFLAGS_${flag_suffix}: ${CFLAGS_${flag_suffix}}")
    debug_message("CXXFLAGS_${flag_suffix}: ${CXXFLAGS_${flag_suffix}}")
endmacro()

macro(z_vcpkg_convert_path_to_unix pathvar)
    if (NOT cygpath)
        find_program(cygpath NAMES cygpath PATHS "${MSYS_ROOT}/usr/bin" REQUIRED)
    endif()
    foreach (curr_option IN LISTS ${pathvar})
        debug_message("curr_option: ${curr_option}")
        string(REGEX REPLACE ".*=(.+)" "\\1" matched_path "${curr_option}")
        debug_message("matched_path: ${matched_path}")
        if (matched_path AND NOT (matched_path STREQUAL curr_option))
            execute_process(
                COMMAND "${cygpath}" "${matched_path}"
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                OUTPUT_VARIABLE out_vars
            )
            string(REGEX MATCH "[^\n]+" out_vars "${out_vars}")
            debug_message("Converted path: ${out_vars}")
            debug_message("replace \"${matched_path}\" with \"${out_vars}\" in \"${${pathvar}}\"")
            list(TRANSFORM ${pathvar} REPLACE "${matched_path}" "${out_vars}")
            debug_message("fixed_values: ${fixed_values}")
        endif()
    endforeach()
endmacro()

function(vcpkg_make_configure)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "AUTOCONFIG;SKIP_CONFIGURE;COPY_SOURCE;DISABLE_VERBOSE_FLAGS;NO_ADDITIONAL_PATHS;ADD_BIN_TO_PATH;USE_WRAPPERS;DETERMINE_BUILD_TRIPLET"
        "SOURCE_PATH;PROJECT_SUBPATH;PRERUN_SHELL;BUILD_TRIPLET"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;CONFIGURE_ENVIRONMENT_VARIABLES;CONFIG_DEPENDENT_ENVIRONMENT;ADDITIONAL_MSYS_PACKAGES"
    )
    
    z_vcpkg_get_cmake_vars(cmake_vars_file)
    debug_message("Including cmake vars from: ${cmake_vars_file}")
    include("${cmake_vars_file}")
    if(DEFINED VCPKG_MAKE_BUILD_TRIPLET)
        set(arg_BUILD_TRIPLET ${VCPKG_MAKE_BUILD_TRIPLET}) # Triplet overwrite for crosscompiling
    endif()

    set(src_dir "${arg_SOURCE_PATH}/${arg_PROJECT_SUBPATH}")

    set(requires_autogen FALSE) # use autogen.sh
    set(requires_autoconfig FALSE) # use autotools and configure.ac
    if(EXISTS "${src_dir}/configure" AND EXISTS "${src_dir}/configure.ac") # remove configure; rerun autoconf
        if(NOT VCPKG_MAINTAINER_SKIP_AUTOCONFIG) # If fixing bugs skipping autoconfig saves a lot of time
            set(requires_autoconfig TRUE)
            file(REMOVE "${src_dir}/configure") # remove possible autodated configure scripts
            set(arg_AUTOCONFIG ON)
        endif()
    elseif(EXISTS "${src_dir}/configure" AND NOT arg_SKIP_CONFIGURE) # run normally; no autoconf or autgen required
    elseif(EXISTS "${src_dir}/configure.ac") # Run autoconfig
        set(requires_autoconfig TRUE)
        set(arg_AUTOCONFIG ON)
    elseif(EXISTS "${src_dir}/autogen.sh") # Run autogen
        set(requires_autogen TRUE)
    else()
        message(FATAL_ERROR "Could not determine method to configure make")
    endif()

    debug_message("requires_autogen:${requires_autogen}")
    debug_message("requires_autoconfig:${requires_autoconfig}")

    if(CMAKE_HOST_WIN32 AND VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "cl.exe") #only applies to windows (clang-)cl and lib
        if(arg_AUTOCONFIG)
            set(arg_USE_WRAPPERS TRUE)
        else()
            # Keep the setting from portfiles.
            # Without autotools we assume a custom configure script which correctly handles cl and lib.
            # Otherwise the port needs to set CC|CXX|AR and probably CPP.
        endif()
    else()
        set(arg_USE_WRAPPERS FALSE)
    endif()

    # Backup environment variables
    # CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJCXX R UPC Y 
    set(cm_FLAGS AS CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJXX R UPC Y RC)
    list(TRANSFORM cm_FLAGS APPEND "FLAGS")
    z_vcpkg_backup_env_variables(${cm_FLAGS})


    # FC fotran compiler | FF Fortran 77 compiler 
    # LDFLAGS -> pass -L flags
    # LIBS -> pass -l flags

    #Used by gcc/linux
    z_vcpkg_backup_env_variables(C_INCLUDE_PATH CPLUS_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH)

    #Used by cl
    z_vcpkg_backup_env_variables(INCLUDE LIB LIBPATH)

    set(vcm_paths_with_spaces FALSE)
    if(CURRENT_PACKAGES_DIR MATCHES " " OR CURRENT_INSTALLED_DIR MATCHES " ")
        # Don't bother with whitespace. The tools will probably fail and I tried very hard trying to make it work (no success so far)!
        message(WARNING "Detected whitespace in root directory. Please move the path to one without whitespaces! The required tools do not handle whitespaces correctly and the build will most likely fail")
        set(vcm_paths_with_spaces TRUE)
    endif()

    # Pre-processing windows configure requirements
    if (VCPKG_TARGET_IS_WINDOWS)
        if(CMAKE_HOST_WIN32)
            list(APPEND msys_require_packages binutils libtool autoconf automake-wrapper automake1.16 m4)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES ${msys_require_packages} ${arg_ADDITIONAL_MSYS_PACKAGES})
            message(STATUS "Checking and converting options...")
            z_vcpkg_convert_path_to_unix(arg_OPTIONS)
            z_vcpkg_convert_path_to_unix(arg_OPTIONS_DEBUG)
            z_vcpkg_convert_path_to_unix(arg_OPTIONS_RELEASE)
            message(STATUS "Checking and converting done...")
        endif()
        if (arg_AUTOCONFIG AND NOT arg_BUILD_TRIPLET OR arg_DETERMINE_BUILD_TRIPLET OR VCPKG_CROSSCOMPILING AND NOT arg_BUILD_TRIPLET)
            z_vcpkg_determine_autotools_host_cpu(BUILD_ARCH) # VCPKG_HOST => machine you are building on => --build=
            z_vcpkg_determine_autotools_target_cpu(TARGET_ARCH)
            # --build: the machine you are building on
            # --host: the machine you are building for
            # --target: the machine that CC will produce binaries for
            # https://stackoverflow.com/questions/21990021/how-to-determine-host-value-for-configure-when-using-cross-compiler
            # Only for ports using autotools so we can assume that they follow the common conventions for build/target/host
            if(CMAKE_HOST_WIN32)
                set(arg_BUILD_TRIPLET "--build=${BUILD_ARCH}-pc-mingw32")  # This is required since we are running in a msys
                                                                            # shell which will be otherwise identified as ${BUILD_ARCH}-pc-msys
            endif()
            if(NOT TARGET_ARCH MATCHES "${BUILD_ARCH}" OR NOT CMAKE_HOST_WIN32) # we don't need to specify the additional flags if we build nativly, this does not hold when we are not on windows
                string(APPEND arg_BUILD_TRIPLET " --host=${TARGET_ARCH}-pc-mingw32") # (Host activates crosscompilation; The name given here is just the prefix of the host tools for the target)
            endif()
            if(VCPKG_TARGET_IS_UWP AND NOT arg_BUILD_TRIPLET MATCHES "--host")
                # Needs to be different from --build to enable cross builds.
                string(APPEND arg_BUILD_TRIPLET " --host=${TARGET_ARCH}-unknown-mingw32")
            endif()
            debug_message("Using make triplet: ${arg_BUILD_TRIPLET}")
        endif()
        if(CMAKE_HOST_WIN32)
            set(append_env)
            if(arg_USE_WRAPPERS)
                set(append_env ";${MSYS_ROOT}/usr/share/automake-1.16")
                string(APPEND append_env ";${SCRIPTS}/buildsystems/make_wrapper") # Other required wrappers are also located there
            endif()
            # This inserts msys before system32 (which masks sort.exe and find.exe) but after MSVC (which avoids masking link.exe)
            string(REPLACE ";$ENV{SystemRoot}\\System32;" "${append_env};${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\System32;" NEWPATH "$ENV{PATH}")
            string(REPLACE ";$ENV{SystemRoot}\\system32;" "${append_env};${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\system32;" NEWPATH "$ENV{PATH}")
            set(ENV{PATH} "${NEWPATH}")
            set(bash_executable "${MSYS_ROOT}/usr/bin/bash.exe")
        endif()

        macro(z_vcpkg_append_to_configure_environment inoutstring var defaultval)
            # Allows to overwrite settings in custom triplets via the environment on windows
            if(CMAKE_HOST_WIN32 AND DEFINED ENV{${var}})
                string(APPEND ${inoutstring} " ${var}='$ENV{${var}}'")
            else()
                string(APPEND ${inoutstring} " ${var}='${defaultval}'")
            endif()
        endmacro()

        set(configure_env "V=1")
        # Remove full filepaths due to spaces and prepend filepaths to PATH (cross-compiling tools are unlikely on path by default)
        set(progs VCPKG_DETECTED_CMAKE_C_COMPILER VCPKG_DETECTED_CMAKE_CXX_COMPILER VCPKG_DETECTED_CMAKE_AR
                  VCPKG_DETECTED_CMAKE_LINKER VCPKG_DETECTED_CMAKE_RANLIB VCPKG_DETECTED_CMAKE_OBJDUMP
                  VCPKG_DETECTED_CMAKE_STRIP VCPKG_DETECTED_CMAKE_NM VCPKG_DETECTED_CMAKE_DLLTOOL VCPKG_DETECTED_CMAKE_RC_COMPILER)
        foreach(prog IN LISTS progs)
            if(${prog})
                set(path "${${prog}}")
                unset(prog_found CACHE)
                get_filename_component(${prog} "${${prog}}" NAME)
                find_program(prog_found ${${prog}} PATHS ENV PATH NO_DEFAULT_PATH)
                if(NOT path STREQUAL prog_found)
                    get_filename_component(path "${path}" DIRECTORY)
                    vcpkg_add_to_path(PREPEND ${path})
                endif()
            endif()
        endforeach()
        if (arg_USE_WRAPPERS)
            z_vcpkg_append_to_configure_environment(configure_env CPP "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")

            z_vcpkg_append_to_configure_environment(configure_env CC "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env CXX "compile ${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env RC "windres-rc ${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env WINDRES "windres-rc ${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            if(VCPKG_DETECTED_CMAKE_AR)
                z_vcpkg_append_to_configure_environment(configure_env AR "ar-lib ${VCPKG_DETECTED_CMAKE_AR}")
            else()
                z_vcpkg_append_to_configure_environment(configure_env AR "ar-lib lib.exe -verbose")
            endif()
        else()
            z_vcpkg_append_to_configure_environment(configure_env CPP "${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")
            z_vcpkg_append_to_configure_environment(configure_env CC "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env CXX "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env RC "${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env WINDRES "${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            if(VCPKG_DETECTED_CMAKE_AR)
                z_vcpkg_append_to_configure_environment(configure_env AR "${VCPKG_DETECTED_CMAKE_AR}")
            else()
                z_vcpkg_append_to_configure_environment(configure_env AR "lib.exe -verbose")
            endif()
        endif()
        z_vcpkg_append_to_configure_environment(configure_env LD "${VCPKG_DETECTED_CMAKE_LINKER} -verbose")
        if(VCPKG_DETECTED_CMAKE_RANLIB)
            z_vcpkg_append_to_configure_environment(configure_env RANLIB "${VCPKG_DETECTED_CMAKE_RANLIB}") # Trick to ignore the RANLIB call
        else()
            z_vcpkg_append_to_configure_environment(configure_env RANLIB ":")
        endif()
        if(VCPKG_DETECTED_CMAKE_OBJDUMP) #Objdump is required to make shared libraries. Otherwise define lt_cv_deplibs_check_method=pass_all
            z_vcpkg_append_to_configure_environment(configure_env OBJDUMP "${VCPKG_DETECTED_CMAKE_OBJDUMP}") # Trick to ignore the RANLIB call
        endif()
        if(VCPKG_DETECTED_CMAKE_STRIP) # If required set the ENV variable STRIP in the portfile correctly
            z_vcpkg_append_to_configure_environment(configure_env STRIP "${VCPKG_DETECTED_CMAKE_STRIP}") 
        else()
            z_vcpkg_append_to_configure_environment(configure_env STRIP ":")
            list(APPEND arg_OPTIONS ac_cv_prog_ac_ct_STRIP=:)
        endif()
        if(VCPKG_DETECTED_CMAKE_NM) # If required set the ENV variable NM in the portfile correctly
            z_vcpkg_append_to_configure_environment(configure_env NM "${VCPKG_DETECTED_CMAKE_NM}") 
        else()
            # Would be better to have a true nm here! Some symbols (mainly exported variables) get not properly imported with dumpbin as nm 
            # and require __declspec(dllimport) for some reason (same problem CMake has with WINDOWS_EXPORT_ALL_SYMBOLS)
            z_vcpkg_append_to_configure_environment(configure_env NM "dumpbin.exe -symbols -headers")
        endif()
        if(VCPKG_DETECTED_CMAKE_DLLTOOL) # If required set the ENV variable DLLTOOL in the portfile correctly
            z_vcpkg_append_to_configure_environment(configure_env DLLTOOL "${VCPKG_DETECTED_CMAKE_DLLTOOL}") 
        else()
            z_vcpkg_append_to_configure_environment(configure_env DLLTOOL "link.exe -verbose -dll")
        endif()
        z_vcpkg_append_to_configure_environment(configure_env CCAS ":")   # If required set the ENV variable CCAS in the portfile correctly
        z_vcpkg_append_to_configure_environment(configure_env AS ":")   # If required set the ENV variable AS in the portfile correctly

        foreach(_env IN LISTS arg_CONFIGURE_ENVIRONMENT_VARIABLES)
            z_vcpkg_append_to_configure_environment(configure_env ${_env} "${${_env}}")
        endforeach()
        debug_message("configure_env: '${configure_env}'")
        # Other maybe interesting variables to control
        # COMPILE This is the command used to actually compile a C source file. The file name is appended to form the complete command line. 
        # LINK This is the command used to actually link a C program.
        # CXXCOMPILE The command used to actually compile a C++ source file. The file name is appended to form the complete command line. 
        # CXXLINK  The command used to actually link a C++ program. 

        # Variables not correctly detected by configure. In release builds.
        list(APPEND arg_OPTIONS gl_cv_double_slash_root=yes
                                 ac_cv_func_memmove=yes)
        #list(APPEND arg_OPTIONS lt_cv_deplibs_check_method=pass_all) # Just ignore libtool checks 
        if(VCPKG_TARGET_ARCHITECTURE MATCHES "^[Aa][Rr][Mm]64$")
            list(APPEND arg_OPTIONS gl_cv_host_cpu_c_abi=no)
            # Currently needed for arm64 because objdump yields: "unrecognised machine type (0xaa64) in Import Library Format archive"
            list(APPEND arg_OPTIONS lt_cv_deplibs_check_method=pass_all)
        elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^[Aa][Rr][Mm]$")
            # Currently needed for arm because objdump yields: "unrecognised machine type (0x1c4) in Import Library Format archive"
            list(APPEND arg_OPTIONS lt_cv_deplibs_check_method=pass_all)
        endif()
    endif()

    if(CMAKE_HOST_WIN32)
        #Some PATH handling for dealing with spaces....some tools will still fail with that!
        string(REPLACE " " "\\\ " z_vcpkg_prefix_path ${CURRENT_INSTALLED_DIR})
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" z_vcpkg_prefix_path "${z_vcpkg_prefix_path}")
        set(z_vcpkg_installed_path ${CURRENT_INSTALLED_DIR})
        set(prefix_var "'\${prefix}'") # Windows needs extra quotes or else the variable gets expanded in the makefile!
    else()
        string(REPLACE " " "\ " z_vcpkg_prefix_path ${CURRENT_INSTALLED_DIR})
        string(REPLACE " " "\ " z_vcpkg_installed_path ${CURRENT_INSTALLED_DIR})
        set(extra_quotes)
        set(prefix_var "\${prefix}")
    endif()

    # macOS - cross-compiling support
    if(VCPKG_TARGET_IS_OSX)
        if (arg_AUTOCONFIG AND NOT arg_BUILD_TRIPLET OR arg_DETERMINE_BUILD_TRIPLET)
            z_vcpkg_determine_autotools_host_arch_mac(BUILD_ARCH) # machine you are building on => --build=
            z_vcpkg_determine_autotools_target_arch_mac(TARGET_ARCH)
            # --build: the machine you are building on
            # --host: the machine you are building for
            # --target: the machine that CC will produce binaries for
            # https://stackoverflow.com/questions/21990021/how-to-determine-host-value-for-configure-when-using-cross-compiler
            # Only for ports using autotools so we can assume that they follow the common conventions for build/target/host
            if(NOT "${TARGET_ARCH}" STREQUAL "${BUILD_ARCH}") # we don't need to specify the additional flags if we build natively.
                set(arg_BUILD_TRIPLET "--host=${TARGET_ARCH}-apple-darwin") # (Host activates crosscompilation; The name given here is just the prefix of the host tools for the target)
            endif()
            debug_message("Using make triplet: ${arg_BUILD_TRIPLET}")
        endif()
    endif()

    # Cleanup previous build dirs
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

    # Set configure paths
    set(arg_OPTIONS_RELEASE ${arg_OPTIONS_RELEASE} "--prefix=${extra_quotes}${z_vcpkg_prefix_path}${extra_quotes}")
    set(arg_OPTIONS_DEBUG ${arg_OPTIONS_DEBUG} "--prefix=${extra_quotes}${z_vcpkg_prefix_path}/debug${extra_quotes}")
    if(NOT arg_NO_ADDITIONAL_PATHS)
        set(arg_OPTIONS_RELEASE ${arg_OPTIONS_RELEASE}
                            # Important: These should all be relative to prefix!
                            "--bindir=${prefix_var}/tools/${PORT}/bin"
                            "--sbindir=${prefix_var}/tools/${PORT}/sbin"
                            #"--libdir='\${prefix}'/lib" # already the default!
                            #"--includedir='\${prefix}'/include" # already the default!
                            "--mandir=${prefix_var}/share/${PORT}"
                            "--docdir=${prefix_var}/share/${PORT}"
                            "--datarootdir=${prefix_var}/share/${PORT}")
        set(arg_OPTIONS_DEBUG ${arg_OPTIONS_DEBUG}
                            # Important: These should all be relative to prefix!
                            "--bindir=${prefix_var}/../tools/${PORT}/debug/bin"
                            "--sbindir=${prefix_var}/../tools/${PORT}/debug/sbin"
                            #"--libdir='\${prefix}'/lib" # already the default!
                            "--includedir=${prefix_var}/../include"
                            "--datarootdir=${prefix_var}/share/${PORT}")
    endif()
    # Setup common options
    if(NOT arg_DISABLE_VERBOSE_FLAGS)
        list(APPEND arg_OPTIONS --disable-silent-rules --verbose)
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        list(APPEND arg_OPTIONS --enable-shared --disable-static)
    else()
        list(APPEND arg_OPTIONS --disable-shared --enable-static)
    endif()

    # Can be set in the triplet to append options for configure
    if(DEFINED VCPKG_MAKE_CONFIGURE_OPTIONS)
        list(APPEND arg_OPTIONS ${VCPKG_MAKE_CONFIGURE_OPTIONS})
    endif()
    if(DEFINED VCPKG_MAKE_CONFIGURE_OPTIONS_RELEASE)
        list(APPEND arg_OPTIONS_RELEASE ${VCPKG_MAKE_CONFIGURE_OPTIONS_RELEASE})
    endif()
    if(DEFINED VCPKG_MAKE_CONFIGURE_OPTIONS_DEBUG)
        list(APPEND arg_OPTIONS_DEBUG ${VCPKG_MAKE_CONFIGURE_OPTIONS_DEBUG})
    endif()

    file(RELATIVE_PATH relative_build_path "${CURRENT_BUILDTREES_DIR}" "${arg_SOURCE_PATH}/${arg_PROJECT_SUBPATH}")

    set(base_cmd)
    if(CMAKE_HOST_WIN32)
        set(base_cmd ${bash_executable} --noprofile --norc --debug)
    else()
        find_program(base_cmd bash REQUIRED)
    endif()
    if(VCPKG_TARGET_IS_WINDOWS)
        list(JOIN arg_OPTIONS " " arg_OPTIONS)
        list(JOIN arg_OPTIONS_RELEASE " " arg_OPTIONS_RELEASE)
        list(JOIN arg_OPTIONS_DEBUG " " arg_OPTIONS_DEBUG)
    endif()
    
    # Setup include environment (since these are buildtype independent restoring them is unnecessary)
    macro(prepend_include_path var)
        if("${${var}_backup}" STREQUAL "")
            set(ENV{${var}} "${z_vcpkg_installed_path}/include")
        else()
            set(ENV{${var}} "${z_vcpkg_installed_path}/include${VCPKG_HOST_PATH_SEPARATOR}${${var}_backup}")
        endif()
    endmacro()
    # Used by CL 
    prepend_include_path(INCLUDE)
    # Used by GCC
    prepend_include_path(C_INCLUDE_PATH)
    prepend_include_path(CPLUS_INCLUDE_PATH)

    # Flags should be set in the toolchain instead (Setting this up correctly requires a function named vcpkg_determined_cmake_compiler_flags which can also be used to setup CC and CXX etc.)
    if(VCPKG_TARGET_IS_WINDOWS)
        z_vcpkg_backup_env_variables(_CL_ _LINK_)
        # TODO: Should be CPP flags instead -> rewrite when vcpkg_determined_cmake_compiler_flags defined
        if(VCPKG_TARGET_IS_UWP)
            # Be aware that configure thinks it is crosscompiling due to: 
            # error while loading shared libraries: VCRUNTIME140D_APP.dll: 
            # cannot open shared object file: No such file or directory
            # IMPORTANT: The only way to pass linker flags through libtool AND the compile wrapper 
            # is to use the CL and LINK environment variables !!!
            # (This is due to libtool and compiler wrapper using the same set of options to pass those variables around)
            string(REPLACE "\\" "/" VCToolsInstallDir "$ENV{VCToolsInstallDir}")
            # Can somebody please check if CMake's compiler flags for UWP are correct?
            set(ENV{_CL_} "$ENV{_CL_} /D_UNICODE /DUNICODE /DWINAPI_FAMILY=WINAPI_FAMILY_APP /D__WRL_NO_DEFAULT_LIB_ -FU\"${VCToolsInstallDir}/lib/x86/store/references/platform.winmd\"")
            string(APPEND VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE " -ZW:nostdlib")
            string(APPEND VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG " -ZW:nostdlib")
            set(ENV{_LINK_} "$ENV{_LINK_} ${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES} ${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES} /MANIFEST /DYNAMICBASE /WINMD:NO /APPCONTAINER") 
        endif()
    endif()

    macro(convert_to_list input output)
        string(REGEX MATCHALL "(( +|^ *)[^ ]+)" ${output} "${${input}}")
    endmacro()
    convert_to_list(VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES c_libs_list)
    convert_to_list(VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES cxx_libs_list)
    set(all_libs_list ${c_libs_list} ${cxx_libs_list})
    list(REMOVE_DUPLICATES all_libs_list)
    list(TRANSFORM all_libs_list STRIP)
    #Do lib list transformation from name.lib to -lname if necessary
    set(x_vcpkg_transform_libs TRUE)
    if(VCPKG_TARGET_IS_UWP)
        set(x_vcpkg_transform_libs FALSE)
        # Avoid libtool choke: "Warning: linker path does not have real file for library -lWindowsApp."
        # The problem with the choke is that libtool always falls back to built a static library even if a dynamic was requested. 
        # Note: Env LIBPATH;LIB are on the search path for libtool by default on windows. 
        # It even does unix/dos-short/unix transformation with the path to get rid of spaces. 
    endif()
    set(l_prefix)
    if(x_vcpkg_transform_libs)
        set(l_prefix "-l")
        list(TRANSFORM all_libs_list REPLACE "(.dll.lib|.lib|.a|.so)$" "")
        if(VCPKG_TARGET_IS_WINDOWS)
            list(REMOVE_ITEM all_libs_list "uuid")
        endif()
        list(TRANSFORM all_libs_list REPLACE "^(${l_prefix})" "")
    endif()
    list(JOIN all_libs_list " ${l_prefix}" all_libs_string)
    if(VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        # libtool must be told explicitly that there is no dynamic linkage for uuid.
        # The "-Wl,..." syntax is understood by libtool and gcc, but no by ld.
        string(REPLACE " -luuid" " -Wl,-Bstatic,-luuid,-Bdynamic" all_libs_string "${all_libs_string}")
    endif()

    if(all_libs_string)
        set(all_libs_string "${l_prefix}${all_libs_string}")
        if(DEFINED ENV{LIBS})
            set(ENV{LIBS} "$ENV{LIBS} ${all_libs_string}")
        else()
            set(ENV{LIBS} "${all_libs_string}")
        endif()
    endif()
    debug_message("ENV{LIBS}:$ENV{LIBS}")
    vcpkg_find_acquire_program(PKGCONFIG)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT PKGCONFIG STREQUAL "--static")
        set(PKGCONFIG "${PKGCONFIG} --static") # Is this still required or was the PR changing the pc files accordingly merged?
    endif()

    # Run autoconf if necessary
    if (arg_AUTOCONFIG OR requires_autoconfig)
        find_program(AUTORECONF autoreconf)
        if(NOT AUTORECONF)
            message(FATAL_ERROR "${PORT} requires autoconf from the system package manager (example: \"sudo apt-get install autoconf\")")
        endif()
        message(STATUS "Generating configure for ${TARGET_TRIPLET}")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND "${base_cmd}" -c "autoreconf -vfi"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "autoconf-${TARGET_TRIPLET}"
            )
        else()
            vcpkg_execute_required_process(
                COMMAND "${AUTORECONF}" -vfi
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "autoconf-${TARGET_TRIPLET}"
            )
        endif()
        message(STATUS "Finished generating configure for ${TARGET_TRIPLET}")
    endif()
    if(requires_autogen)
        message(STATUS "Generating configure for ${TARGET_TRIPLET} via autogen.sh")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND "${base_cmd}" -c "./autogen.sh"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "autoconf-${TARGET_TRIPLET}"
            )
        else()
            vcpkg_execute_required_process(
                COMMAND "./autogen.sh"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "autoconf-${TARGET_TRIPLET}"
            )
        endif()
        message(STATUS "Finished generating configure for ${TARGET_TRIPLET}")
    endif()

    if (arg_PRERUN_SHELL)
        message(STATUS "Prerun shell with ${TARGET_TRIPLET}")
        vcpkg_execute_required_process(
            COMMAND "${base_cmd}" -c "${arg_PRERUN_SHELL}"
            WORKING_DIRECTORY "${src_dir}"
            LOGNAME "prerun-${TARGET_TRIPLET}"
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug" AND NOT arg_NO_DEBUG)
        set(var_suffix DEBUG)
        set(path_suffix_${var_suffix} "/debug")
        set(short_name_${var_suffix} "dbg")
        list(APPEND _buildtypes ${var_suffix})
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            set(LINKER_FLAGS_${var_suffix} "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${var_suffix}}")
        else() # dynamic
            set(LINKER_FLAGS_${var_suffix} "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${var_suffix}}")
        endif()
        z_vcpkg_extract_cpp_flags_and_set_cflags_and_cxxflags(${var_suffix})
        if (CMAKE_HOST_WIN32 AND VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "cl.exe")
            if(NOT vcm_paths_with_spaces)
                set(LDFLAGS_${var_suffix} "-L${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib -L${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib/manual-link")
            endif()
            if(DEFINED ENV{_LINK_})
                set(LINK_ENV_${var_suffix} "$ENV{_LINK_} ${LINKER_FLAGS_${var_suffix}}")
            else()
                set(LINK_ENV_${var_suffix} "${LINKER_FLAGS_${var_suffix}}")
            endif()
        else()
            set(link_required_dirs)
            if(EXISTS "${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib")
                set(link_required_dirs "-L${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib")
            endif()
            if(EXISTS "{z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib/manual-link")
                set(link_required_dirs "${link_required_dirs} -L${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib/manual-link")
            endif()
            string(STRIP "${link_required_dirs}" link_required_dirs)
            set(LDFLAGS_${var_suffix} "${link_required_dirs} ${LINKER_FLAGS_${var_suffix}}")
        endif()
        unset(var_suffix)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(var_suffix RELEASE)
        set(path_suffix_${var_suffix} "")
        set(short_name_${var_suffix} "rel")
        list(APPEND _buildtypes ${var_suffix})
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            set(LINKER_FLAGS_${var_suffix} "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${var_suffix}}")
        else() # dynamic
            set(LINKER_FLAGS_${var_suffix} "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${var_suffix}}")
        endif()
        z_vcpkg_extract_cpp_flags_and_set_cflags_and_cxxflags(${var_suffix})
        if (CMAKE_HOST_WIN32 AND VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "cl.exe")
            if(NOT vcm_paths_with_spaces)
                set(LDFLAGS_${var_suffix} "-L${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib -L${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib/manual-link")
            endif()
            if(DEFINED ENV{_LINK_})
                set(LINK_ENV_${var_suffix} "$ENV{_LINK_} ${LINKER_FLAGS_${var_suffix}}")
            else()
                set(LINK_ENV_${var_suffix} "${LINKER_FLAGS_${var_suffix}}")
            endif()
        else()
            set(link_required_dirs)
            if(EXISTS "${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib")
                set(link_required_dirs "-L${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib")
            endif()
            if(EXISTS "{z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib/manual-link")
                set(link_required_dirs "${link_required_dirs} -L${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib/manual-link")
            endif()
            string(STRIP "${link_required_dirs}" link_required_dirs)
            set(LDFLAGS_${var_suffix} "${link_required_dirs} ${LINKER_FLAGS_${var_suffix}}")
        endif()
        unset(var_suffix)
    endif()

    foreach(_buildtype IN LISTS _buildtypes)
        foreach(ENV_VAR ${arg_CONFIG_DEPENDENT_ENVIRONMENT})
            if(DEFINED ENV{${ENV_VAR}})
                set(backup_config_${ENV_VAR} "$ENV{${ENV_VAR}}")
            endif()
            set(ENV{${ENV_VAR}} "${${ENV_VAR}_${_buildtype}}")
        endforeach()

        set(target_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_name_${_buildtype}}")
        file(MAKE_DIRECTORY "${target_dir}")
        file(RELATIVE_PATH relative_build_path "${target_dir}" "${src_dir}")

        if(arg_COPY_SOURCE)
            file(COPY "${src_dir}/" DESTINATION "${target_dir}")
            set(relative_build_path .)
        endif()

        # Setup PKG_CONFIG_PATH
        set(pkgconfig_installed_dir "${CURRENT_INSTALLED_DIR}${path_suffix_${_buildtype}}/lib/pkgconfig")
        set(pkgconfig_installed_share_dir "${CURRENT_INSTALLED_DIR}/share/pkgconfig")
        if(ENV{PKG_CONFIG_PATH})
            set(backup_env_pkg_config_path_${_buildtype} $ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${pkgconfig_installed_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_installed_share_dir}${VCPKG_HOST_PATH_SEPARATOR}$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${pkgconfig_installed_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_installed_share_dir}")
        endif()

        # Setup environment
        set(ENV{CPPFLAGS} "${CPPFLAGS_${_buildtype}}")
        set(ENV{CFLAGS} "${CFLAGS_${_buildtype}}")
        set(ENV{CXXFLAGS} "${CXXFLAGS_${_buildtype}}")
        set(ENV{RCFLAGS} "${VCPKG_DETECTED_CMAKE_RC_FLAGS_${_buildtype}}")
        set(ENV{LDFLAGS} "${LDFLAGS_${_buildtype}}")

        # https://www.gnu.org/software/libtool/manual/html_node/Link-mode.html
        # -avoid-version is handled specially by libtool link mode, this flag is not forwarded to linker,
        # and libtool tries to avoid versioning for shared libraries and no symbolic links are created.
        if(VCPKG_TARGET_IS_ANDROID)
            set(ENV{LDFLAGS} "-avoid-version $ENV{LDFLAGS}")
        endif()

        if(LINK_ENV_${var_suffix})
            set(link_config_backup "$ENV{_LINK_}")
            set(ENV{_LINK_} "${LINK_ENV_${var_suffix}}")
        endif()
        set(ENV{PKG_CONFIG} "${PKGCONFIG}")

        set(_lib_env_vars LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH)
        foreach(_lib_env_var IN LISTS _lib_env_vars)
            set(_link_path)
            if(EXISTS "${z_vcpkg_installed_path}${path_suffix_${_buildtype}}/lib")
                set(_link_path "${z_vcpkg_installed_path}${path_suffix_${_buildtype}}/lib")
            endif()
            if(EXISTS "${z_vcpkg_installed_path}${path_suffix_${_buildtype}}/lib/manual-link")
                if(_link_path)
                    set(_link_path "${_link_path}${VCPKG_HOST_PATH_SEPARATOR}")
                endif()
                set(_link_path "${_link_path}${z_vcpkg_installed_path}${path_suffix_${_buildtype}}/lib/manual-link")
            endif()
            set(ENV{${_lib_env_var}} "${_link_path}${${_lib_env_var}_pathlike_concat}")
        endforeach()
        unset(_link_path)
        unset(_lib_env_vars)

        if(CMAKE_HOST_WIN32)
            set(command "${base_cmd}" -c "${configure_env} ./${relative_build_path}/configure ${arg_BUILD_TRIPLET} ${arg_OPTIONS} ${arg_OPTIONS_${_buildtype}}")
        elseif(VCPKG_TARGET_IS_WINDOWS)
            set(command "${base_cmd}" -c "${configure_env} $@" -- "./${relative_build_path}/configure" ${arg_BUILD_TRIPLET} ${arg_OPTIONS} ${arg_OPTIONS_${_buildtype}})
        else()
            set(command "${base_cmd}" "./${relative_build_path}/configure" ${arg_BUILD_TRIPLET} ${arg_OPTIONS} ${arg_OPTIONS_${_buildtype}})
        endif()
        
        if(arg_ADD_BIN_TO_PATH)
            set(path_backup $ENV{PATH})
            vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}${path_suffix_${_buildtype}}/bin")
        endif()
        debug_message("Configure command:'${command}'")
        if (NOT arg_SKIP_CONFIGURE)
            message(STATUS "Configuring ${TARGET_TRIPLET}-${short_name_${_buildtype}}")
            vcpkg_execute_required_process(
                COMMAND ${command}
                WORKING_DIRECTORY "${target_dir}"
                LOGNAME "config-${TARGET_TRIPLET}-${short_name_${_buildtype}}"
            )
            if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
                file(GLOB_RECURSE libtool_files "${target_dir}*/libtool")
                foreach(lt_file IN LISTS libtool_files)
                    file(READ "${lt_file}" _contents)
                    string(REPLACE ".dll.lib" ".lib" _contents "${_contents}")
                    file(WRITE "${lt_file}" "${_contents}")
                endforeach()
            endif()
            
            if(EXISTS "${target_dir}/config.log")
                file(RENAME "${target_dir}/config.log" "${CURRENT_BUILDTREES_DIR}/config.log-${TARGET_TRIPLET}-${short_name_${_buildtype}}.log")
            endif()
        endif()

        if(backup_env_pkg_config_path_${_buildtype})
            set(ENV{PKG_CONFIG_PATH} "${backup_env_pkg_config_path_${_buildtype}}")
        else()
            unset(ENV{PKG_CONFIG_PATH})
        endif()
        unset(backup_env_pkg_config_path_${_buildtype})
        
        if(link_config_backup)
            set(ENV{_LINK_} "${link_config_backup}")
            unset(link_config_backup)
        endif()
        
        if(arg_ADD_BIN_TO_PATH)
            set(ENV{PATH} "${path_backup}")
        endif()
        # Restore environment (config dependent)
        foreach(ENV_VAR ${arg_CONFIG_DEPENDENT_ENVIRONMENT})
            if(backup_config_${ENV_VAR})
                set(ENV{${ENV_VAR}} "${backup_config_${ENV_VAR}}")
            else()
                unset(ENV{${ENV_VAR}})
            endif()
        endforeach()
    endforeach()

    # Export matching make program for vcpkg_make_build (cache variable)
    if(CMAKE_HOST_WIN32 AND MSYS_ROOT)
        find_program(Z_VCPKG_MAKE make PATHS "${MSYS_ROOT}/usr/bin" NO_DEFAULT_PATH REQUIRED)
    elseif(VCPKG_HOST_IS_OPENBSD)
        find_program(Z_VCPKG_MAKE gmake REQUIRED)
    else()
        find_program(Z_VCPKG_MAKE make REQUIRED)
    endif()

    # Restore environment
    z_vcpkg_restore_env_variables(${cm_FLAGS} LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH)

    set(_VCPKG_PROJECT_SOURCE_PATH ${arg_SOURCE_PATH} PARENT_SCOPE)
    set(_VCPKG_PROJECT_SUBPATH ${arg_PROJECT_SUBPATH} PARENT_SCOPE)
endfunction()
