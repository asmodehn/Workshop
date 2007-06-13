CMAKE_MINIMUM_REQUIRED(VERSION 2.4)

PROJECT( DbgMem C )

INCLUDE ( CMake/WkCompilerSetup.cmake )
INCLUDE ( CMake/WkBuild.cmake )
INCLUDE ( CMake/WkTest.cmake )

WkCompilerSetup( DbgMem )

WkBuild( DbgMem LIBRARY)

WkTestAllOnce( DbgMem )

