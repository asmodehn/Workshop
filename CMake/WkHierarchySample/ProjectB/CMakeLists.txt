CMAKE_MINIMUM_REQUIRED(VERSION 2.4)

PROJECT( ProjectB C )

INCLUDE ( CMake/Logging.cmake )
INCLUDE ( CMake/WkCompilerSetup.cmake )
INCLUDE ( CMake/WkBuild.cmake )
INCLUDE ( CMake/WkTest.cmake )

WkCompilerSetup( ProjectB )
#LogVariables()

WkBuild( ProjectB LIBRARY )

WkTestAllOnce( ProjectB )

