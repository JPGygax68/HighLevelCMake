if(__ls_add_glew)
  return()
endif()
set(__ls_add_glew INCLUDED)


function(ls_link_glew)

  # Try to make sure that find_package() will find the right version (32-bit or 64-bit)
  if (NOT CMAKE_LIBRARY_ARCHITECTURE)
    if (NOT TARGET_ARCHITECTURE)
      determine_target_architecture(TARGET_ARCHITECTURE)
    endif()
    set(CMAKE_LIBRARY_ARCHITECTURE ${TARGET_ARCHITECTURE})
  endif()

  # Find and add the package
  find_package(GLEW REQUIRED)
  target_include_directories(${PROJECT_NAME} PRIVATE ${GLEW_INCLUDE_DIR})
  target_link_libraries(${PROJECT_NAME} PRIVATE ${GLEW_LIBRARY})

  # Ensure that the GLEW DLL will be copied to the same directory as the target
  # TODO: support the static variant of GLEW that does not need this
  # TODO: handle the special case of debugging directly with the Locsim executable?
  string(REPLACE "/lib/" "/bin/" GLEW_BINARY ${GLEW_LIBRARY})
  string(REPLACE ".lib" ".dll" GLEW_BINARY ${GLEW_BINARY})
  add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different
          "${GLEW_BINARY}"                              # <--this is in-file
          $<TARGET_FILE_DIR:${PROJECT_NAME}>)           # <--this is out-file path

  message("GLEW library dependency added to target ${PROJECT_NAME}")

endfunction()
