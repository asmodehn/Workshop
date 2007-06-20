CMAKE_MINIMUM_REQUIRED(VERSION 2.4)

PROJECT( Logger C )

INCLUDE ( CMake/WkCompilerSetup.cmake )
INCLUDE ( CMake/WkBuild.cmake )
INCLUDE ( CMake/WkTest.cmake )

WkCompilerSetup( Logger )

WkBuild( Logger LIBRARY )

#DEBUGING MEMORY WITH OR WITHOUT VLD
IF (CHECK_MEM_LEAKS)
	WkTestAllOnce( Logger )
ELSE (CHECK_MEM_LEAKS)
	WkTestAllOnce( Logger DbgMem )
ENDIF (CHECK_MEM_LEAKS)
