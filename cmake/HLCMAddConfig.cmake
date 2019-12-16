if(__hlcm_add_config)
  return()
endif()
set(__hlcm_add_config INCLUDED)


set(__hlcm_add_config_syntax
  "Add an extra configuration to the CMake default ones (Debug, Release, RelWithDebInfo, MinSizeRel)\n"
  "Usage: hlcm_add_config("
  "  <config_name>                      # name of this new configuration (CamelCase)"
  "  [BASED_ON <source_config>]         # existing configuration this new one is based on"
  "  [OUTPUT_DIRECTORY <dir_path>       # toolchain (linker) output directory"
  ")"
)

function(hlcm_add_config)

  cmake_parse_arguments(args "" "BASED_ON;OUTPUT_DIRECTORY" "" ${ARGN})
  list(LENGTH args_UNPARSED_ARGUMENTS unparsed_count)
  if (unparsed_count EQUAL "0")
      message(FATAL_ERROR "hlcm_add_config(${ARGN}): must specify name of new configuration\n${__hlcm_add_config_syntax}")
  elseif (unparsed_count EQUAL "1")
      list(GET args_UNPARSED_ARGUMENTS 0 config_name)
  else()
      message(FATAL_ERROR "hlcm_add_config(${ARGN}): second non-option parameter unexpected\n${__hlcm_add_config_syntax}")
  endif()
  if (args_BASED_ON)
      set(based_on "${args_BASED_ON}")
  else()
      set(based_on "Debug")
  endif()

  if (CMAKE_CONFIGURATION_TYPES)  # TODO: can't remember why I made this conditional

    string(TOUPPER "${config_name}" config_name_uc)
    string(TOUPPER "${based_on}" based_on_uc)

    if (NOT "${config_name}" IN_LIST CMAKE_CONFIGURATION_TYPES)
      # TODO: modifying the cache variable here, but using a normal variable might be better after all
      set(CMAKE_CONFIGURATION_TYPES ${CMAKE_CONFIGURATION_TYPES} ${config_name} CACHE STRING "" FORCE)
      #set(CMAKE_MAP_IMPORTED_CONFIG_DEBUGLOCSIM Debug)
      set(CMAKE_CXX_FLAGS_${config_name_uc} "${CMAKE_CXX_FLAGS_${based_on_uc}}")
      set(CMAKE_C_FLAGS_${config_name_uc} "${CMAKE_C_FLAGS_${based_on_uc}}")
      set(CMAKE_EXE_LINKER_FLAGS_${config_name_uc} "${CMAKE_EXE_LINKER_FLAGS_${based_on_uc}}")
      set(CMAKE_SHARED_LINKER_FLAGS_${config_name_uc} "${CMAKE_SHARED_LINKER_FLAGS_${based_on_uc}}")
    endif()

    if (args_OUTPUT_DIRECTORY)
      set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${config_name_uc} "${args_OUTPUT_DIRECTORY}")
    endif()
  endif()

endfunction()
