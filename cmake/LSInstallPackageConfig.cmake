if(__ls_install_package_config)
  return()
endif()
set(__ls_install_package_config INCLUDED)


set(ls_install_pkg_config_SYNOPSIS "
  ls_install_package_config( <export_set>
    [REQUIRED_PACKAGES \"<package specifier>\" ...]   # package specifiers sim. to find_package() (quotes required if containing spaces)
  )
")

# TODO: fuse with ls_install_export_set() into ls_install_package()

function(ls_install_package_config)

  cmake_parse_arguments(args "" "" "REQUIRED_PACKAGES" ${ARGN})

  set(export_set ${args_UNPARSED_ARGUMENTS})

  if (args_REQUIRED_PACKAGES)
    set(required_pkgs ${args_REQUIRED_PACKAGES})
  endif()
  #message("required_pkgs: ${required_pkgs}")
  foreach(pkg ${required_pkgs})
    set(FIND_DEPENDENCIES "${FIND_DEPENDENCIES}\nfind_dependency(${pkg})")
  endforeach()
  set(EXPORT_SET ${export_set})
  # TODO: use
  configure_file("${LSCMAKE_MODULE_DIR}/config.in.cmake" "${CMAKE_CURRENT_BINARY_DIR}/${export_set}-config.cmake" @ONLY)

  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${export_set}-config.cmake" DESTINATION "cmake/")

endfunction()