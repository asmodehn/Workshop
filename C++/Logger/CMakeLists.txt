CMAKE_MINIMUM_REQUIRED(VERSION 2.4)

PROJECT( Logger C++ )

INCLUDE ( CMake/WkCompilerSetup.cmake )
INCLUDE ( CMake/WkBuild.cmake )
INCLUDE ( CMake/WkTest.cmake )

WkCompilerSetup( Logger )

WkBuild( Logger LIBRARY )

WkTestAllOnce( Logger )

