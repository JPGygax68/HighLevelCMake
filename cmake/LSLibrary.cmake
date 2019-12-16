if (__ls_library)
  return()
endif()
set(__ls_library INCLUDED)

set(__ls_library_syntax "\
Defines a Locsim (static) library target
ls_library([<target>]
  SRCS <src1>..<srcN>)              # source files
  [HDRS <hdr1>..<hdrN>]             # internal header files
  PUB_HDRS <hdr1>..<hdrN>           # public header files
  [EXTRA_HDRS <hdr1>..<hdrN>]       # extra (public) headers, relative to ../include/ (without the namespace)
  [NAMESPACE <namespace>]           # default is 'locsim'
  [EXPORT_SET <export_set>]         # name of the export set, = target if omitted
")


function(ls_library)
  # Simply pass the list of source (and header) files.

  cmake_parse_arguments(args "" "" "SRCS;HDRS;PUB_HDRS;EXTRA_HDRS" ${ARGN})
  list(LENGTH args_UNPARSED_ARGUMENTS unparsed_count)
  if (unparsed_count EQUAL "1")
    list(GET args_UNPARSED_ARGUMENTS 0 target_name)
    #message("target_name: ${target_name}")
  elseif (unparsed_count GREATER "1")
    message("ls_library(${ARGN}): second non-option parameter unexpected")
    message(FATAL_ERROR ${__ls_library_syntax})
  else()
    set(target_name ${PROJECT_NAME})
  endif()

  if (args_EXPORT_SET)
    set(export_set ${args_EXPORT_SET})
  else()
    set(export_set ${target_name})
  endif()

  if (args_NAMESPACE)
    set(namespace ${args_NAMESPACE})
  else()
    set(namespace "locsim")
  endif()
  #string(TOLOWER "${namespace}" ns_dir)
  set(ns_dir ${namespace})

  message(STATUS "Creating Locsim library ${target_name}")

  foreach(src ${args_SRCS})
    set(path "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
    if (NOT EXISTS "${path}")
      message(STATUS "Creating new source file \"${src}\"")
      file(WRITE "${path}" "// Source file ${src} for library ${target_name}")
    endif()
  endforeach()

  foreach(hdr ${args_HDRS})
    set(path "${CMAKE_CURRENT_SOURCE_DIR}/${hdr}")
    if (NOT EXISTS "${path}")
      message(STATUS "Creating new internal header file \"${hdr}\"")
      file(WRITE "${path}" "// Internal header file ${hdr} for library ${target_name}\n\n#pragma once")
    endif()
  endforeach()

  if (NOT args_PUB_HDRS)
    message(FATAL_ERROR "No PUB_HDRS (public headers) specified. You must specify at least one (only specify the path segments after ../include/locsim/ !)")
  endif()
  foreach (hdr ${args_PUB_HDRS})
    set(hdr_fp "${CMAKE_CURRENT_SOURCE_DIR}/../include/locsim/${hdr}")
    if (NOT EXISTS "${hdr_fp}")
      #message(FATAL_ERROR "Public header file \"${hdr_fp}\" does not exist!")
      message(STATUS "Creating public header file \"${hdr}\"")
      file(WRITE "${hdr_fp}" "// Public header file ${hdr} for library ${target_name}\n\n#pragma once")
    endif()
    list(APPEND pub_hdrs_fp "${hdr_fp}")
  endforeach()
  # message(STATUS "pub_hdrs_fp: ${pub_hdrs_fp}")

  # TODO: support shared libraries (not the same as Locsim DLL modules)
  add_library(${target_name} STATIC ${args_SRCS} ${args_HDRS} ${pub_hdrs_fp})
  target_include_directories(${target_name}
    PRIVATE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include/${ns_dir}/>"
    PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include/>"
    PUBLIC "$<INSTALL_INTERFACE:include/>"
  )
  set_target_properties(${target_name} PROPERTIES PUBLIC_HEADER "${pub_hdrs_fp}")
  set_target_properties(${PROJECT_NAME} PROPERTIES DEBUG_POSTFIX D)

  install(TARGETS ${target_name} EXPORT ${export_set}
    PUBLIC_HEADER DESTINATION "include/${ns_dir}"
  )
  if (args_EXTRA_HDRS)
    foreach (hdr ${args_EXTRA_HDRS})
      get_filename_component(dir "${hdr}" DIRECTORY)
      install(FILES "../include/${hdr}" DESTINATION "include/${dir}")
    endforeach()
  endif()

endfunction()
