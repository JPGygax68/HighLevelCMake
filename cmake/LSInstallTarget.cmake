if(__ls_install_target)
  return()
endif()
set(__ls_install_target INCLUDED)

# DEPRECATED, do not use. Left in the project for documentation purposes.

# TODO: use GNUInstallDirs()


function(ls_install_target)

  message(FATAL_ERROR "ls_install_target(): REMOVED from Locsim CMake concept, do not use anymore")

  # Generate installation rules for the currently active project, which must be a Locsim DLL.

  # TODO: this could be probably be made into non Locsim specific routine.

  cmake_parse_arguments(args "" "EXPORT_SET;SUBDIR" "EXTRA_HDRS" ${ARGN})
  list(LENGTH args_UNPARSED_ARGUMENTS unparsed_count)
  if (unparsed_count EQUAL "1")
    list(GET args_UNPARSED_ARGUMENTS 0 target)
  elseif (unparsed_count GREATER "1")
    message(FATAL_ERROR "ls_install_target(${ARGN}): second non-option parameter unexpected")
  else()
    message(WARNING "DEPRECATED: ls_install_target() called without specifying target; PROJECT_NAME variable (=${PROJECT_NAME}) will be used, but please correct.")
    set(target ${PROJECT_NAME})
  endif()
  if (args_EXPORT_SET)
    set(export_set ${args_EXPORT_SET})
  else()
    set(export_set ${target})
  endif()
  if (args_SUBDIR)
    set(subdir "${args_SUBDIR}")
  else()
    set(subdir "locsim")
  endif()

  install(TARGETS ${target} EXPORT ${export_set}
    PUBLIC_HEADER DESTINATION "include/${subdir}"
  )

endfunction()
