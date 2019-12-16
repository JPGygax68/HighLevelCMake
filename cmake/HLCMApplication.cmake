if(__hlcm_application)
  return()
endif()
set(__hlcm_application INCLUDED)

set(__hlcm_application_syntax
  "Usage: hlcm_application([<target_name>] SOURCES <src1>..<srcN>)")


function(ls_application)
  # Simply pass the list of source (and header) files.

  cmake_parse_arguments(args "DONT_INSTALL" "" "SOURCES" ${ARGN})
  list(LENGTH args_UNPARSED_ARGUMENTS unparsed_count)
  if (unparsed_count EQUAL "1")
    list(GET args_UNPARSED_ARGUMENTS 0 target_name)
  elseif (unparsed_count GREATER "1")
    message(FATAL_ERROR "hlcm_application(${ARGN}): second non-option parameter unexpected\n${PROJECT_NAME}")
  else()
    set(target_name ${PROJECT_NAME})
  endif()

  message(STATUS "Creating Application ${target_name}")

  foreach(src ${args_SRCS})
    if (NOT EXISTS "${PROJECT_SOURCE_DIR}/${src}")
      file(WRITE "${PROJECT_SOURCE_DIR}/${src}" "// TODO: created by hlcm_application(), write code here")
    endif()
  endforeach()

  add_executable(${target_name} ${args_SOURCES} ${args_HEADERS} ${pub_hdrs_fp})

  #set_target_properties(${target_name} PROPERTIES MAP_IMPORTED_CONFIG_DEBUGLOCSIM "Debug")

  if (NOT args_DONT_INSTALL)
    install(TARGETS ${target_name} EXPORT ${target_name})
    configure_file("${LSCMAKE_MODULE_DIR}/config.in.cmake" "${CMAKE_CURRENT_BINARY_DIR}/${target_name}-config.cmake" @ONLY)
    install(EXPORT ${target_name} DESTINATION "cmake" FILE "${target_name}.cmake")
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${target_name}-config.cmake" DESTINATION "cmake/")
  endif()

endfunction()
