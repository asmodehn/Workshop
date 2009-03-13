CMAKE_MINIMUM_REQUIRED(VERSION 2.6 FATAL_ERROR)

INCLUDE ( CMake/WkCMake/WkCompilerSetup.cmake )
INCLUDE ( CMake/WkCMake/WkBuild.cmake )
INCLUDE ( CMake/WkCMake/WkTest.cmake )

PROJECT( ProjectC C )

WkCompilerSetup( ProjectC )

WkBuild( ProjectC LIBRARY DYNAMIC )

WkTestAllOnce( ProjectC )

