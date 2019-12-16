message(STATUS "Initializing HLCM (High-Level CMake)...")

# CMake setup
cmake_policy(SET CMP0057 NEW) # if (... IN_LIST ...) support

include(HLCMAddConfig)
include(HCLMModule)
# TODO: ...
include(LSApplication)
include(LSLibrary)
include(LSUseLSModule)
#include(LSLinkLibrary)
include(LSLinkBoost)
#include(LSLinkGLBinding)
#include(LSLinkGlew)
#include(LSLinkGlad)
include(LSLinkDependency)
#include(LSInstallTarget)
include(LSInstallExportSet)
include(LSInstallPackageConfig)
include(LSEmbedFile)
include(LSCopySharedLibs)

# Setup

# TODO: PARENT_SCOPE is required in case ls-cmake was added via add_subdirectory().
# This is not ideal; a better solution might be to set up ls-cmake as a two-tier
# cmake project, the top one containing the CMakeLists.txt file, the nested
# one (e.g. "scripts") containing the script files themselves. This would allow
# ls-cmake to be consumed as a submodule by adding "ls-cmake/scripts" to the
# module path instead of "ls-cmake", thus bypassing the add_subdirectory() that
# creates a nested variable scope.

set(LSCMAKE_MODULE_DIR "${CMAKE_CURRENT_LIST_DIR}")

# Additional configuration: DebugLocsim
if (CMAKE_CONFIGURATION_TYPES)
  if (NOT "DebugLocsim" IN_LIST CMAKE_CONFIGURATION_TYPES)
    # TODO: modifying the cache variable here, but using a normal variable might be better after all
    set(CMAKE_CONFIGURATION_TYPES ${CMAKE_CONFIGURATION_TYPES} DebugLocsim CACHE STRING "" FORCE)
  endif()
  #set(CMAKE_MAP_IMPORTED_CONFIG_DEBUGLOCSIM Debug)
  set(CMAKE_CXX_FLAGS_DEBUGLOCSIM "${CMAKE_CXX_FLAGS_DEBUG}")
  set(CMAKE_C_FLAGS_DEBUGLOCSIM "${CMAKE_C_FLAGS_DEBUG}")
  set(CMAKE_EXE_LINKER_FLAGS_DEBUGLOCSIM "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUGLOCSIM "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}")
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUGLOCSIM "C:/Locsim/DLL/")
endif()

# All binaries to the same directory, please
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
