
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
INCLUDE (CMake/WkCMake.cmake)
WkCMakeDir( CMake )

WkProject ( DumbNet C )

WkBuild (LIBRARY SHARED )

WkTestBuild(dn_client)
WkTestBuild(dn_server)
WkTestBuild(dn_udp_client)
WkTestBuild(dn_udp_server)
WkTestBuild(dn_error)

#WkTestRun(server dn_server)
#WkTestRun(client dn_client)

WkTestRun(error dn_error)
