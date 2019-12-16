if (__ls_interface_lib)
  return()
endif()
set(__ls_interface_lib INCLUDED)

include(LSInternal)

set(__ls_interface_lib_syntax "\
Defines a Locsim (static) library target
ls_interface_lib([<target>]
  SRCS <src1>..<srcN>)              # source files
  [HDRS <hdr1>..<hdrN>]             # ""pseudo-internal"" header files
  PUB_HDRS <hdr1>..<hdrN>           # public header files
  [EXTRA_HDRS <hdr1>..<hdrN>]       # extra (public) headers, relative to ../include/ (without the namespace)
  [NAMESPACE <namespace>]           # default is 'locsim'
  [EXPORT_SET <export_set>]         # name of the export set, = target if omitted
")


function(ls_interface_lib)
  # Simply pass the list of source (and header) files.

  cmake_parse_arguments(args "" "" "SRCS;HDRS;PUB_HDRS;EXTRA_HDRS" ${ARGN})
  list(LENGTH args_UNPARSED_ARGUMENTS unparsed_count)
  if (unparsed_count EQUAL "1")
    list(GET args_UNPARSED_ARGUMENTS 0 target_name)
    #message("target_name: ${target_name}")
  elseif (unparsed_count GREATER "1")
    message("ls_interface_lib(${ARGN}): second non-option parameter unexpected")
    message(FATAL_ERROR ${__ls_interface_lib_syntax})
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

  message(STATUS "Creating Locsim interface library ${target_name}")

  if (NOT args_PUB_HDRS)
    message(FATAL_ERROR "No PUB_HDRS (public headers) specified. You must specify at least one (only specify the path segments after ../include/locsim/ !)")
  endif()

  ls_autocreate_sources(SOURCES ${args_SRCS} HEADERS ${args_HDRS} PUBLIC_HEADERS ${args_PUB_HDRS})

  foreach(src ${args_SRCS})
      set(src_fp "${PROJECT_SOURCE_DIR}/${src}")
      list(APPEND hdrs_fp "${src_fp}")
      target_sources(${target_name} INTERFACE
          $<BUILD_INTERFACE:${src_fp}>
          $<INSTALL_INTERFACE:src/${target_name}/${src}>
      )
  endforeach()

  foreach(hdr ${args_HDRS})
      set(hdr_fp "${PROJECT_SOURCE_DIR}/${hdr}")
      list(APPEND hdrs_fp "${hdr_fp}")
      target_sources(${target_name} INTERFACE
          $<BUILD_INTERFACE:${hdr_fp}>
          $<INSTALL_INTERFACE:src/${target_name}/${hdr}>
      )
  endforeach()

  foreach(pub_hdr ${args_PUB_HDRS})
      set(pubhdr_fp "${PROJECT_SOURCE_DIR}/../include/${target_name}/${pub_hdr}")
      list(APPEND pubhdrs_fp "${hdr_fp}")
      target_sources(${target_name} INTERFACE
          $<BUILD_INTERFACE:${pubhdr_fp}>
          $<INSTALL_INTERFACE:include/${target_name}/${pub_hdr}>
      )
      set_target_properties(${target_name} PROPERTIES PUBLIC_HEADER "include/${target_name}/${pub_hdr}")
  endforeach()

  add_library(${target_name} INTERFACE)

  target_include_directories(${target_name}
      INTERFACE "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>"
      INTERFACE "$<INSTALL_INTERFACE:include/>"
  )

  install(TARGETS ${target_name} EXPORT ${export_set}
      PUBLIC_HEADER DESTINATION "include/${target_name}/"
  )
  install(FILES ${srcs_fp} ${hdrs_fp} DESTINATION "src/${target_name}/")
  if (args_EXTRA_HDRS)
    foreach (hdr ${args_EXTRA_HDRS})
      get_filename_component(dir "${hdr}" DIRECTORY)
      install(FILES "../include/${hdr}" DESTINATION "include/${dir}")
    endforeach()
  endif()

endfunction()
