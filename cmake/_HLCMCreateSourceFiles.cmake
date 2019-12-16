if(__hlcm_create_source_files)
  return()
endif()
set(__hlcm_create_source_files INCLUDED)


# TODO
# NOT DONE YET (may be removed), DO NOT USE!

macro _hlcm_add_sources_files()

  if (NOT DEFINED target)
    message(FATAL_ERROR "_hlcm_add_source_files(): variable ""target"" is not defined")
  endif()

  set(ns_dir "${args_NAMESPACE}")

  # Source files
  foreach(src ${args_SOURCES})
    set(path "${PROJECT_SOURCE_DIR}/${src}")
    if (NOT EXISTS "${path}")
      message(STATUS "Creating new source file \"${src}\"")
      file(WRITE "${path}" "// Source file ${src} for library ${target_name}")
    endif()
  endforeach()

  # Private header files
  foreach(hdr ${args_HEADERS})
    set(path "${PROJECT_SOURCE_DIR}/${hdr}")
    if (NOT EXISTS "${path}")
      message(STATUS "Creating new internal header file \"${hdr}\"")
      file(WRITE "${path}" "// Internal header file ${hdr} for library ${target_name}\n\n#pragma once")
    endif()
  endforeach()

  # Public header files
  foreach (hdr ${args_PUBLIC_HEADERS})
    set(hdr_fp "${PROJECT_SOURCE_DIR}/../include/${ns_dir}/${hdr}")
    if (NOT EXISTS "${hdr_fp}")
      # message(FATAL_ERROR "Public header file \"${hdr_fp}\" does not exist!")
      message(STATUS "Creating public header file \"${hdr}\"")
      file(WRITE "${hdr_fp}" "// Public header file ${hdr} for library ${target_name}\n\n#pragma once")
    endif()
    list(APPEND pub_hdrs_fp "${hdr_fp}")
  endforeach()

endmacro()