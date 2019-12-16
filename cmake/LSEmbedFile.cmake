if(__ls_embed_files)
  return()
endif()
set(__ls_embed_files INCLUDED)

# TODO: make this cross-compilable
add_executable(embedfile "${CMAKE_CURRENT_LIST_DIR}/embedfile.c")


function(ls_embed_file)

  cmake_parse_arguments(args "" "SOURCE_GROUP;SIZE_TYPE" "" ${ARGN})
  list(LENGTH args_UNPARSED_ARGUMENTS unparsed_count)
  if (unparsed_count EQUAL "3")
    list(GET args_UNPARSED_ARGUMENTS 0 target)
    list(GET args_UNPARSED_ARGUMENTS 1 symbol)
    list(GET args_UNPARSED_ARGUMENTS 2 rsrc_file)
  else()
    # TODO: synopsis string
    message(FATAL_ERROR "ls_embed_files(${ARGN}): first parameter must be target where to embed the file, second must be name of export symbol")
  endif()

  set(gensrc_file "${CMAKE_CURRENT_BINARY_DIR}/${symbol}.c")
  if (args_SIZE_TYPE)
    set(size_type "${args_SIZE_TYPE}")
  else()
    set(size_type "size_t")
  endif()

  add_custom_command(
    OUTPUT "${gensrc_file}"
    COMMAND embedfile ${symbol} "${CMAKE_CURRENT_SOURCE_DIR}/${rsrc_file}" "${size_type}"
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${rsrc_file}"
  )

  target_sources(${target} PRIVATE "${rsrc_file}" "${gensrc_file}" )

  if (args_SOURCE_GROUP)
    source_group(${args_SOURCE_GROUP} FILES "${rsrc_file}")
  endif()

endfunction()
