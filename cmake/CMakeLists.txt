project("ls-cmake")

set(sources
  config.in.cmake
  HighLevelCMake.cmake
  HLCMUseModule.cmake
  HLCMModule.cmake # LSModule.cmake
  LSLibrary.cmake
  LSInterfaceLib.cmake
  LSApplication.cmake
  LSLinkDependency.cmake
  LSCopySharedLibs.cmake
  LSGenerateConfigFile.cmake
  LSInstallExportSet.cmake
  LSInstallPackageConfig.cmake
  LSLinkBoost.cmake
  LSEmbedFile.cmake
  embedfile.c
)

#add_custom_target("ls-cmake" SOURCES ${sources})

install(
  FILES
    ${sources}
  DESTINATION
    cmake/ls-cmake/
)

install(FILES ls-cmake-config.cmake DESTINATION "cmake/")