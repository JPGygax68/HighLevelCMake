cmake_minimum_required(VERSION 3.14)

if(__ls_link_boost)
  return()
endif()
set(__ls_link_boost INCLUDED)


# TODO: document the importance of the CMAKE_PREFIX_PATH environment variable

#------------------------------------------------------------------------------
# This is a lightweight wrapper around the CMake commands find_package(Boost) +
# target_link_libraries(). It will add the specified Boost modules to the
# target named after the current project.
# Note that the header-only modules (which are the majority of the Boost
# modules) will always be added even if no modules are specified.
#
# Usage:
# ls_link_boost(<target> COMPONENTS [<component1>...<componentN>)
#------------------------------------------------------------------------------

function(ls_link_boost)

  cmake_parse_arguments(args "PUBLIC;PRIVATE" "" "COMPONENTS" ${ARGN})
  list(LENGTH args_UNPARSED_ARGUMENTS unparsed_count)
  if (unparsed_count EQUAL "1")
    list(GET args_UNPARSED_ARGUMENTS 0 target_name)
    set(components ${args_COMPONENTS})
  elseif (unparsed_count GREATER "1")
    message("ls_link_boost(${ARGN}): second non-option parameter unexpected")
  else()
    set(target_name ${PROJECT_NAME})
    set(components ${args_UNPARSED_ARGUMENTS})
  endif()

  if (args_PRIVATE AND args_PUBLIC)
    message(FATAL_ERROR "Boost cannot be both PUBLIC and PRIVATE")
  endif()
  if (args_PUBLIC)
    set(privacy_level "PUBLIC")
  elseif (args_PRIVATE)
    set(privacy_level "PRIVATE")
  else()
    set(privacy_level "PRIVATE")
  endif()

  set(Boost_USE_STATIC_LIBS ON)
  #set(Boost_USE_STATIC_RUNTIME OFF)
  #set(Boost_USE_DEBUG_RUNTIME  OFF)
  #set(Boost_USE_MULTITHREADED ON)
  set(Boost_DEBUG ON)
  #link_directories(${Boost_LIBRARY_DIRS}) # to support Visual Studio's auto-linking

  if (components)
    set(comp_args REQUIRED COMPONENTS ${components})
  endif()

  find_package(Boost ${comp_args})

  #  optimized ${Boost_LOCALE_LIBRARY_RELEASE} ${Boost_SYSTEM_LIBRARY_RELEASE} ${Boost_FILESYSTEM_LIBRARY_RELEASE} ${Boost_REGEX_LIBRARY_RELEASE}
  #  debug ${Boost_LOCALE_LIBRARY_DEBUG} ${Boost_SYSTEM_LIBRARY_DEBUG} ${Boost_FILESYSTEM_LIBRARY_DEBUG} ${Boost_REGEX_LIBRARY_DEBUG} )
  # message("Boost_INCLUDE_DIRS: ${Boost_INCLUDE_DIRS}") # Empty when Boost was built for CMake
  if (TARGET Boost::boost)
    message(STATUS "Boost found as a CMake package configuration file")
    string(REGEX REPLACE "([^;]+)" "Boost::\\1" boost_components "${components}")
    target_link_libraries(${target_name} ${privacy_level} Boost::boost ${boost_components})
  elseif (Boost_FOUND)
    message(STATUS "Boost found (available via variables)")
    target_link_libraries(${target_name} ${privacy_level} ${Boost_LIBRARIES})
    target_include_directories(${target_name} ${privacy_level} ${Boost_INCLUDE_DIRS})
  else()
    message(FATAL_ERROR "Boost not found!")
  endif()

endfunction()
