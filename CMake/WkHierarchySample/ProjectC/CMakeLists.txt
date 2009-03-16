CMAKE_MINIMUM_REQUIRED(VERSION 2.6 FATAL_ERROR)

INCLUDE ( CMake/WkBuild.cmake )
INCLUDE ( CMake/WkTest.cmake )

WkProject( ProjectC C )

WkBuild( LIBRARY SHARED )

WkTestBuild( maintestC )
WkTestRun( maintestC )

