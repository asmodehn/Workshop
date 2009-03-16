CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
	
INCLUDE ( CMake/WkBuild.cmake )
INCLUDE ( CMake/WkTest.cmake )

WkProject( ProjectB C )

WkBuild( LIBRARY STATIC )
WkBinDepends( RELEASE ProjectC )

WkTestBuild( maintestB )
WkTestRun( maintestB )
