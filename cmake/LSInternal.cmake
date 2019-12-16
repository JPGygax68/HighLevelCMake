if (__ls_internal)
  return()
endif()
set(__ls_internal)


function(ls_autocreate_sources)

  cmake_parse_arguments(args "" "" "SOURCES;HEADERS;PUBLIC_HEADERS;EXTRA_HEADERS" ${ARGN})

  foreach(src ${args_SOURCES})
    set(path "${PROJECT_SOURCE_DIR}/${src}")
    if (NOT EXISTS "${path}")
      message(STATUS "Creating new source file \"${src}\"")
      file(WRITE "${path}" "// Source file ${src} for (interface) library ${target_name}")
    endif()
  endforeach()

  foreach(hdr ${args_HEADERS})
    set(path "${PROJECT_SOURCE_DIR}/${hdr}")
    if (NOT EXISTS "${path}")
      message(STATUS "Creating new internal header file \"${hdr}\"")
      file(WRITE "${path}" "// Internal header file ${hdr} for library ${target_name}\n\n#pragma once")
    endif()
  endforeach()

  foreach (hdr ${args_PUBLIC_HEADERS})
    set(hdr_fp "${PROJECT_SOURCE_DIR}/../include/locsim/${hdr}")
    if (NOT EXISTS "${hdr_fp}")
      #message(FATAL_ERROR "Public header file \"${hdr_fp}\" does not exist!")
      message(STATUS "Creating public header file \"${hdr}\"")
      file(WRITE "${hdr_fp}" "// Public header file ${hdr} for library ${target_name}\n\n#pragma once")
    endif()
    list(APPEND pub_hdrs_fp "${hdr_fp}")
  endforeach()
  # message(STATUS "pub_hdrs_fp: ${pub_hdrs_fp}")

endfunction()
