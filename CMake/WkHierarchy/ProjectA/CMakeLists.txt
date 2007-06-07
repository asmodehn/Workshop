CMAKE_MINIMUM_REQUIRED(VERSION 2.4)

PROJECT( ProjectA C CXX )

INCLUDE ( CMake/WkCompilerSetup.cmake )
INCLUDE ( CMake/WkBuild.cmake )
INCLUDE ( CMake/WkTest.cmake )

WkCompilerSetup( ProjectA )

# Building shared library only for main target. dependencies are forced to static in WkBuild.
# Otherwise they would be separate package.
SET(BUILD_SHARED_LIBS ON)

WkBuild( ProjectA LIBRARY ProjectB )

WkTest( ProjectA test/test.cc)

