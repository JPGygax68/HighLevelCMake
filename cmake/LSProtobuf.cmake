if(__ls_protobuf)
  return()
endif()
set(__ls_protobuf INCLUDED)

message(WARNING "This module (LSProtobuf.cmake) is DEPRECATED - it was not working reliably enough. "
  "Please use find_package(Protobuf ...) with target_link_libraries() instead.")

#-----------------------------------------------------------------------------
# This CMake script makes Google Protobuf available to Locsim projects.
#
# If Protobuf is installed on your system, it will use the installed version.
# If not, it will download, build and install it as part of the configuration
# process (this may take a few minutes).
#
# This script will make available the function protobuf_generate_cpp() (see
# https://cmake.org/cmake/help/latest/module/FindProtobuf.html), but also
# adds the following convenience function:
#  ls_protobuf_lib(<target> [STATIC|SHARED] <protobuf_files.proto>...)
# This will create a static or shared library target that can be linked to
# your project.
#-----------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.14)

# TODO: add another option to enable download+build, so that it won't start w/o asking the user?
# TODO: can this be done with conditional options?
option(LOCSIM_PROTOBUF_FORCE_OWN_BUILD "Do not attempt to find an installed version of Protobuf; always download and build it" OFF)
if (NOT LOCSIM_PROTOBUF_FORCE_OWN_BUILD)
  find_package(Protobuf 3.8)
endif()

if (NOT Protobuf_FOUND)

  include(ExternalProject)

  set(GIT_REPOSITORY "https://github.com/protocolbuffers/protobuf.git")

  set(prefix "protobuf-external")
  set(target "protobuf-external")
  set(trigger_build_dir "${CMAKE_CURRENT_BINARY_DIR}") # /force_${target}")

  file(MAKE_DIRECTORY "${trigger_build_dir}" "${trigger_build_dir}/build")

  set(cache_args
    "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}"
    "-Dprotobuf_BUILD_TESTS:BOOL=OFF"
    "-Dprotobuf_BUILD_EXAMPLES:BOOL=OFF"
    "-Dprotobuf_BUILD_PROTOC_BINARIES:BOOL=ON"
    "-Dprotobuf_WITH_ZLIB:BOOL=OFF"
    "-Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF"
    "-DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}"
    "-DCMAKE_INSTALL_PREFIX:PATH=${CURRENT_BINARY_DIR}"
    # other project specific parameters
  )
  set(git_tag "3.8.x")

  #generate false dependency project
  set(CMAKE_LIST_CONTENT "
    cmake_minimum_required(VERSION 3.14)

    include(ExternalProject)
    ExternalProject_Add(${target}
      # PREFIX ${prefix}
      # URL ${PROTOBUF_TAR_GZ}
      GIT_REPOSITORY \"${GIT_REPOSITORY}\"
      GIT_TAG \"${git_tag}\"
      # BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/protobuf
      CMAKE_CACHE_ARGS \"${cache_args}\"
      SOURCE_SUBDIR cmake
      # BUILD_ALWAYS 1
      STEP_TARGETS build
      # INSTALL_COMMAND \"\"
    )"
  )

  file(WRITE ${trigger_build_dir}/CMakeLists.txt "${CMAKE_LIST_CONTENT}")

  execute_process(COMMAND "${CMAKE_COMMAND}"
    "-DCMAKE_INSTALL_PREFIX=${trigger_build_dir}"
    "-Dprotobuf_MODULE_COMPATIBLE=ON"
    ..
    WORKING_DIRECTORY "${trigger_build_dir}/build"
  )
  execute_process(COMMAND "${CMAKE_COMMAND}" --build .
    WORKING_DIRECTORY "${trigger_build_dir}/build"
  )

  # ExternalProject_Get_Property(protobuf-external source_dir)

  set(protobuf_MODULE_COMPATIBLE ON)
  find_package(Protobuf 3.8 CONFIG REQUIRED PATHS "${trigger_build_dir}" NO_DEFAULT_PATH)

endif()


function(ls_protobuf_lib)

  cmake_parse_arguments(args "STATIC;SHARED" "" "" ${ARGN})

  list(GET args_UNPARSED_ARGUMENTS 0 target_name)
  #message("protobuf target_name: ${target_name}")
  list(REMOVE_AT args_UNPARSED_ARGUMENTS 0)
  set(proto_files ${args_UNPARSED_ARGUMENTS})
  #message("proto_files: ${proto_files}")
  if (args_STATIC)
    set(type STATIC)
  elseif(args_SHARED)
    set(type SHARED)
  else()
    set(type STATIC)
  endif()

  protobuf_generate_cpp(proto_srcs proto_hdrs ${proto_files})

  add_library(${target_name} ${type} ${proto_srcs} ${proto_hdrs})
  foreach (hdr ${proto_hdrs})
    set_target_properties(${target_name} PROPERTIES PUBLIC_HEADER ${hdr})
  endforeach()
  target_compile_options(${target_name} PRIVATE $<$<CXX_COMPILER_ID:MSVC>:-wd26495>)
  # protobuf_generate_cpp() write the include files to the current binary dir
  target_include_directories(${target_name} PUBLIC "${CMAKE_CURRENT_BINARY_DIR}")
  target_link_libraries(${target_name} PUBLIC protobuf::libprotobuf)

endfunction()
