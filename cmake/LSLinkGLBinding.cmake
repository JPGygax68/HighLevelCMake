if(__ls_link_glbinding)
  return()
endif()
set(__ls_link_glbinding INCLUDED)


function(ls_link_glbinding)

  cmake_parse_arguments(args "PUBLIC;PRIVATE" "" "" ${ARGN})
  if (args_UNPARSED_ARGUMENTS)
    list(GET args_UNPARSED_ARGUMENTS 0 target_name)
    list(REMOVE_AT args_UNPARSED_ARGUMENTS 0)
  else()
    set(target_name ${PROJECT_NAME})
  endif()
  if (args_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Cannot parse argument(s): ${args_UNPARSED_ARGUMENTS}")
  endif()
  if (args_PUBLIC)
    set(visibility "PUBLIC")
  elseif (args_PRIVATE)
    set(visibility "PRIVATE")
  else()
    set(visibility PUBLIC)
  endif()

  find_package(glbinding REQUIRED)
  # 2019-05-31 gygax:
  # The following should work according the GLBinding docs, but doesn't.
  # It's possible that my installed version of GLBinding is too old.
  target_link_libraries(${target_name} ${visibility} glbinding::glbinding)

endfunction()
