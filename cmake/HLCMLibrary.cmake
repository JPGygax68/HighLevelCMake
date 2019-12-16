if(_hlcm_library)
  return()
endif()
set(_hlcm_library INCLUDED)

include(_HLCMGetAllLinkLibraries)


set(_hlcm_library_syntax
  "Defines a library target\n"
  "Usage: hlcm_library([<target>] "
  "  [SHARED|STATIC]                                # selects library type (default is STATIC)"
  "  SOURCES <src1>..<srcN>)                        # source files (paths relative to caller directory)"
  "  HEADERS <hdr1>..<hdrN>                         # header files (paths ditto)"
  "  PUBLIC_HEADERS <hdr1>..<hdrN>                  # public headers (paths relative to ../include/<namespace> - lower case form!)"
  "  EXTRA_HEADERS <hdr1>..<hdrN>                   # extra (public) headers, relative to ../include/ (without the namespace)"
  "  [EXPORT_SET <export_set>]                      # export set; if omitted, same as target"
  "  [NAMESPACE <Namespace>]                        # override default namespace name (otherwise same as target name)"
  "  [EXPORT_TRIGGER <trigger_name>]                # override for export trigger symbol (defaults to EXPORT_<TARGET_NAME>)"
  "  [REQUIRES {[PUBLIC|PRIVATE] <target> [FROM (<package>)]}"
  ")"
)

function(hlcm_library)
  # Simply pass the list of source (and header) files.

  cmake_parse_arguments(args "SHARED;STATIC" "NAMESPACE;EXPORT_SET;EXPORT_TRIGGER" "SOURCES;HEADERS;PUBLIC_HEADERS;EXTRA_HEADERS" ${ARGN})
  list(LENGTH args_UNPARSED_ARGUMENTS unparsed_count)
  if (unparsed_count EQUAL "1")
    list(GET args_UNPARSED_ARGUMENTS 0 target_name)
  elseif (unparsed_count GREATER "1")
    message(FATAL_ERROR "hlcm_module(${ARGN}): second non-option parameter unexpected\n${_hlcm_library_syntax}")
  else()
    set(target_name ${PROJECT_NAME})
  endif()
  if (args_NAMESPACE)
    set(namespace ${args_NAMESPACE})
  else()
    set(namespace "${target_name}")
  endif()
  set(library_type "STATIC")
  if (args_SHARED)
    set(library_type "${args_SHARED}")
  endif()
  # TODO: ensure ns_dir is filesystem compatible and all lowercase
  #string(TOLOWER "${namespace}" ns_dir)
  set(ns_dir ${namespace})

  string(MAKE_C_IDENTIFIER "${target_name}" id)
  string(TOUPPER ${id} target_uc)
  if (args_EXPORT_TRIGGER)
    set(export_trigger "${args_EXPORT_TRIGGER}")
  else()
    set(export_trigger "EXPORT_${target_uc}")
  endif()
  message(STATUS "Export trigger macro is ${export_trigger}")

  if (args_EXPORT_SET)
    set(export_set ${args_EXPORT_SET})
  else()
    set(export_set ${target_name})
  endif()

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
  if (NOT args_PUBLIC_HEADERS)
    message(FATAL_ERROR "No PUBLIC_HEADERS (public headers) specified. You must specify at least one (only specify the path segments after ../include/locsim/ !)")
  endif()
  foreach (hdr ${args_PUBLIC_HEADERS})
    set(hdr_rp) "../include/${ns_dir}/${hdr}" # relative path
    set(hdr_fp "${PROJECT_SOURCE_DIR}/${hdr_rp}") # full path
    if (NOT EXISTS "${hdr_fp}")
      message(STATUS "Creating public header file \"${hdr}\"")
      file(WRITE "${hdr_fp}" "// Public header file ${hdr} for library ${target_name}\n\n#pragma once")
    endif()
    list(APPEND pub_hdrs_rp) "${hdr_rp}"
    list(APPEND pub_hdrs_fp "${hdr_fp}")
  endforeach()

  message(STATUS "Defining ${library_type} ""${target_name}""")

  add_library(${target_name} ${library_type} ${args_SOURCES} ${args_HEADERS} ${pub_hdrs_rp})
  target_include_directories(${target_name}
    PRIVATE
      "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/../include/${ns_dir}/>"
    PUBLIC
      "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/../include/>"
      "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/../include/>"
      "$<INSTALL_INTERFACE:include>"
  )
  set_target_properties(${target_name} PROPERTIES PUBLIC_HEADER "${pub_hdrs_fp}") # TODO: use the relative paths here?

  # Dependencies
  set(cur_dep)
  set(requires)
  while (requires)

    set(dep_privacy "PRIVATE")

    list(POP_FRONT requires dep_target)
    if (NOT requires)
      break()
    endif()
    list(GET requires 0 param)
    if (("${param}" STREQUAL "PUBLIC") OR ("${param}" STREQUAL "PRIVATE"))
      list(POP_FRONT requires dep_privacy)
      list(GET requires 0 param)
    endif()
    if ("${param}" STREQUAL "FROM")
      list(POP_FRONT requires dummy)
      list(POP_FRONT requires dep_package)
    endif()
    message(DEBUG "Processing dependency target ""${dep_target}""")


    if (NOT TARGET ${dep_tgt})
      message(STATUS "Dependency \"${dep_tgt}\" not a target yet, looking for it in package \"${dep_pkg}\"")
      find_package(${dep_pkg})
      if (NOT TARGET ${dep})
        message(FATAL_ERROR "Package specifier \"${dep_pkg}\" does not provide the dependency target \"${dep_tgt}\"")
      endif()
      #set_target_properties(${dep_tgt} PROPERTIES IMPORTED_GLOBAL TRUE)
      #get_target_property(ig ${dep_tgt} IMPORTED_GLOBAL)
      get_all_link_libraries(${dep_tgt} link_libs)
      message(STATUS "Dependency ${dep_tgt} imported from package \"${dep_pkg}\")") # and made globally visible
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


  endwhile()

  if (0) # From project "Locsim": to use as reference when implementing future extensions
    set_target_properties(${target_name} PROPERTIES DEBUG_POSTFIX "d")
    set_target_properties(${target_name} PROPERTIES LOCSIMDEBUG_POSTFIX "") # better set CMAKE_DEBUGLOCSIM_POSTFIX at initialization

    target_compile_definitions(${target_name} PRIVATE "${export_trigger}")

    # TODO: provide option to suppress this
    #set_target_properties(${target_name} PROPERTIES MAP_IMPORTED_CONFIG_DEBUGLOCSIM "Debug")
    set_property(TARGET ${target_name} PROPERTY VS_DEBUGGER_COMMAND $<$<CONFIG:DebugLocsim>:C:\\Locsim\\locsim.exe>)
    set_property(TARGET ${target_name} PROPERTY VS_DEBUGGER_WORKING_DIRECTORY $<$<CONFIG:DebugLocsim>:C:\\Locsim\\>)
  endif()

  install(TARGETS ${target_name} EXPORT ${export_set}
    PUBLIC_HEADER DESTINATION "include/${ns_dir}"
    # TODO: set global variables to make this unnecessary (no CMAKE variables are available, HLCM must define its own, e.g. HLCM_ARCHIVE_INSTALL_<CONFIG>_DESTINATION)
    # CONFIGURATIONS DebugLocsim
    #   ARCHIVE DESTINATION "lib$<$<CONFIG:DebugLocsim>:/debuglocsim>"
    #   RUNTIME DESTINATION "bin$<$<CONFIG:DebugLocsim>:/debuglocsim>"
  )
  if (args_EXTRA_HEADERS)
    foreach (hdr ${args_EXTRA_HEADERS})
      get_filename_component(dir "${hdr}" DIRECTORY)
      install(FILES "../include/${hdr}" DESTINATION "include/${dir}")
    endforeach()
  endif()

endfunction()
