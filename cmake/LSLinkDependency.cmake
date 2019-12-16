if(__ls_link_dependency)
  return()
endif()
set(__ls_link_dependency INCLUDED)

# TODO: rename to ls_link_external_lib()?

set(ls_link_dependency_SYNOPSIS "\
ls_link_dependency( <TargetName> <dependencies>...
  PACKAGE <PackageName> [[<version> [EXACT]] [COMPONENTS <components>...]
  [PUBLIC][PRIVATE]
)
Combines find_package(...) and target_link_libraries(...), and records the
find_package() parameters so that ls_install_target() can inject find_dependency()
calls into the installable config file (generated post-build).
")

function(ls_link_dependency)

  # Check and parse arguments

  cmake_parse_arguments(args "PUBLIC;PRIVATE" "" "PACKAGE" ${ARGN})
  if (NOT args_PACKAGE)
    message(FATAL_ERROR "You must specify a package.\n${ls_link_dependency_SYNOPSIS}")
  endif()
  list(LENGTH args_UNPARSED_ARGUMENTS n)
  if (n LESS 2)
    message(FATAL_ERROR "You must specify the target and the dependency target.\n${ls_link_dependency_SYNOPSIS}")
  endif()
  list(GET args_UNPARSED_ARGUMENTS 0 target)
  list(SUBLIST args_UNPARSED_ARGUMENTS 1 -1 dep)
  if (NOT args_PACKAGE)
    message(FATAL_ERROR "You must specify the package to obtain the dependencies from.\n${ls_link_dependency_SYNOPSIS}")
  endif()
  string(REPLACE ";" " " pkg_spec "${args_PACKAGE}")
  set(privacy "PRIVATE")
  if (args_PUBLIC)
    set(privacy "PUBLIC")
  endif()

  # Find the package and link to its target(s)
  if (NOT TARGET ${dep})
    message(STATUS "Dependency \"${dep}\" not a target yet, looking for it in package \"${pkg_spec}\"")
    find_package(${pkg_spec})
    if (NOT TARGET ${dep})
      message(FATAL_ERROR "Package specifier \"${pkg_spec}\" does not provide the dependency target \"${dep}\"")
    endif()
    set_target_properties(${dep} PROPERTIES IMPORTED_GLOBAL TRUE)
    get_target_property(ig ${dep} IMPORTED_GLOBAL)
    get_all_link_libraries(${dep} link_libs)
    message(STATUS "Dependency ${dep} imported from package \"${pkg_spec}\" and made globally visible")
    foreach(ndep ${link_libs})
      if (TARGET ${ndep})
        get_target_property(imported ${ndep} "IMPORTED_GLOBAL")
        if (NOT imported)
            set_target_properties(${ndep} PROPERTIES IMPORTED_GLOBAL TRUE)
            message(STATUS "  Nested dep also made global: ${ndep}")
        endif()
      endif()
    endforeach()
  else()
    message(STATUS "Dependency \"${dep}\" already defined as a target, linking as-is")
  endif()
  target_link_libraries(${target} ${privacy} ${dep})

  #get_all_link_libraries(${target} ilibs)
  #message("Link interface libraries of target ${target}: ${ilibs}")

endfunction()