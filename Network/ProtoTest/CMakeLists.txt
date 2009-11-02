CMAKE_MINIMUM_REQUIRED ( VERSION 2.6)
INCLUDE ( CMake/WkCMake.cmake )
WkCMakeDir ( CMake )

WkProject ( ProtoTest C)

WkBuild ( LIBRARY STATIC )

WkLink()

WkTestBuild( client client.c)
WkTestBuild( server server.c)


