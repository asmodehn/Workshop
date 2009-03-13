#TODO : Use SVN version to find > 1.1.0 : supports symbolic links :D
#TODO : Use CMake > 2.6 : find subversion has been added

if ( CMAKE_BACKWARDS_COMPATIBILITY LESS 2.6 )
	message ( FATAL_ERROR " CMAKE MINIMUM BACKWARD COMPATIBILITY REQUIRED : 2.6 !" )
endif( CMAKE_BACKWARDS_COMPATIBILITY LESS 2.6 )

#
# Common use of Cmake in Wk
#


macro (WkSvn project_name)

find_package(Subversion)
if(Subversion_FOUND)
	Subversion_WC_INFO(${PROJECT_SOURCE_DIR} ${Project})
    Subversion_WC_LOG(${PROJECT_SOURCE_DIR} ${Project})
    message("Last changed log is ${Project_LAST_CHANGED_LOG}")
	SET (${project_name}_REVISION ${Project_WC_REVISION} CACHE STRING "The detected revision of the source repository" FORCE)
else(Subversion_FOUND)
	SET (${project_name}_REVISION "SVN-NOTFOUND" CACHE STRING "The detected revision of the source repository" FORCE)
endif(Subversion_FOUND)

endmacro (WkSvn)