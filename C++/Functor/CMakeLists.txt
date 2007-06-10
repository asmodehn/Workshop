CMAKE_MINIMUM_REQUIRED(VERSION 2.4)

PROJECT( Functor C )

INCLUDE ( CMake/WkCompilerSetup.cmake )
INCLUDE ( CMake/WkBuild.cmake )
INCLUDE ( CMake/WkTest.cmake )

WkCompilerSetup( Functor )

WkBuild( Functor LIBRARY )

WkTestAllOnce( Functor )

