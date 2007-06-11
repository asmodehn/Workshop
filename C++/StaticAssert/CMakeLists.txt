CMAKE_MINIMUM_REQUIRED(VERSION 2.4)

PROJECT( StaticAssert C++ )

INCLUDE ( CMake/WkCompilerSetup.cmake )
INCLUDE ( CMake/WkBuild.cmake )
INCLUDE ( CMake/WkTest.cmake )

WkCompilerSetup( StaticAssert )

WkBuild( StaticAssert LIBRARY )

WkTestAllOnce( StaticAssert )

