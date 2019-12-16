if(__ls_install_export_set)
  return()
endif()
set(__ls_install_export_set INCLUDED)


function(ls_install_export_set)

  cmake_parse_arguments(args "" "" "" ${ARGN})
  list(LENGTH args_UNPARSED_ARGUMENTS n)
  if (NOT n EQUAL 1)
    message(FATAL_ERROR "ls_install_export_set(): you must specify an export set.")
  endif()
  list(GET args_UNPARSED_ARGUMENTS 0 export_set)
  #message("export_set: ${export_set}")

  cmake_policy(SET CMP0022 NEW)
  install(EXPORT ${export_set}
    DESTINATION "cmake"
    FILE "${export_set}.cmake"
    EXPORT_LINK_INTERFACE_LIBRARIES
  )

endfunction()
