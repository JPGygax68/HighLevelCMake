# This script is intended to be called from within a custom command.
# It takes three parameters:
#   <dependency_list_file>    # full path of the file containing a list (one item per line) of
#                               the packages required to fulfill the dependencies
#   <config_in_file>          # full path to the config template file
#   <config_out_file>         # full path of the config file to be written

# (Arg 0 is cmake executable, arg 1 is "-P" switch, arg2 is path of this script)
set(target "${CMAKE_ARGV3}")
set(finddeps_file "${CMAKE_ARGV4}")
set(config_in_file "${CMAKE_ARGV5}")
set(config_out_file "${CMAKE_ARGV6}")

message("Generating config file \"${config_out_file}\" for target \"${target}\" from dependency list \"${finddeps_file}\" and template \"${config_in_file}\"")

if (EXISTS "${finddeps_file}")
  file(READ "${finddeps_file}" FIND_DEPENDENCIES)
  set(FIND_DEPENDENCIES "include(CMakeFindDependencyMacro)\n${FIND_DEPENDENCIES}")
endif()

set(TARGET ${target})
configure_file("${config_in_file}" "${config_out_file}" @ONLY)
