if(__hlcm_use_module)
  return()
endif()
set(__hlcm_use_module INCLUDED)

cmake_minimum_required(VERSION 3.14)



function(hlcm_use_module)

  cmake_parse_arguments(args "AS_SUBMODULE" "" ${ARGN})

  if (unparsed_count EQUAL "1")
    list(GET args_UNPARSED_ARGUMENTS 0 module)
    #message("target_name: ${target_name}")
  elseif (unparsed_count GREATER "1")
    message(FATAL_ERROR "hlcm_use_module(${ARGN}): second non-option parameter unexpected\n${__ls_use_ls_module_syntax}")
  else()

    if (NOT args_AS_SUBMODULE)

      if (NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
        message(FATAL_ERROR "hlcm_use_module() may only be called from the root directory of a project")
      endif()
      find_package(Git QUIET REQUIRED)
      if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/submodules/${module}")
        file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/submodules")
        execute_process(COMMAND ${GIT_EXECUTABLE} submodule add --init --recursive
          WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/submodules"
          RESULT_VARIABLE git_submod_result)
        # TODO: check result
        add_subdirectory("submodules/${module}" EXCLUDE_FROM_ALL)
      endif()

    else()

      # TODO: this should probably be replaced with hlcm_link_dependency()
      find_package(${module} CONFIG REQUIRED)
      if (NOT TARGET ${module})
        message(FATAL_ERROR "Cannot find submodule \"${module}\" (or the package config file does not define a target)")
      endif()

    endif()
  endif()

endfunction()
