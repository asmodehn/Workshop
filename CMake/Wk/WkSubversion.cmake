#TODO : Use SVN version to find > 1.1.0 : supports symbolic links :D
#TODO : Use CMake > 2.6 : find subversion has been added


# macro to get the SVN Revision number
find_program( SVNVERSION
  svnversion
  /usr/local/bin
  /usr/pkg/bin
  /usr/bin
)

macro( svn_repository_version DESTVAR TOPDIR )
	# Only work if SVNVERSION exist (prog found)
	IF(SVNVERSION)
		exec_program( ${SVNVERSION} ${TOPDIR} ARGS "." OUTPUT_VARIABLE DESTVARORI )
		STRING(REGEX REPLACE "(.+):(.+)" "\\1_\\2" ${DESTVAR} ${DESTVARORI})
	ENDIF(SVNVERSION)
endmacro( svn_repository_version )


#
# Common use of Cmake in RAGE
#

svn_repository_version( SVN_REV ${CMAKE_SOURCE_DIR})
SET (VERSION ${SVN_REV} CACHE STRING "The detected revision of the source repository" FORCE)

SET(BUILD_SHARED_LIBS OFF)

