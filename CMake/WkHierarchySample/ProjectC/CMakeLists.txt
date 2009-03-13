CMAKE_MINIMUM_REQUIRED(VERSION 2.6 FATAL_ERROR)

INCLUDE ( CMake/WkCompilerSetup.cmake )
INCLUDE ( CMake/WkBuild.cmake )
INCLUDE ( CMake/WkTest.cmake )

PROJECT( ProjectC C )

WkCompilerSetup( ProjectC )

WkBuild( ProjectC LIBRARY SHARED )

WkTestAllOnce( ProjectC )

