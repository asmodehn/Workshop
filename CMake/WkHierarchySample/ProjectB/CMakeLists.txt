CMAKE_MINIMUM_REQUIRED(VERSION 2.4)

PROJECT( ProjectB C )

INCLUDE ( CMake/WkCMake/WkCompilerSetup.cmake )
INCLUDE ( CMake/WkCMake/WkBuild.cmake )
INCLUDE ( CMake/WkCMake/WkTest.cmake )

WkCompilerSetup( ProjectB )

WkBuild( ProjectB LIBRARY )

WkTestAllOnce( ProjectB )

