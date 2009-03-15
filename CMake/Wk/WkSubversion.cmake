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
	message("Retrieving SVN repository information...")
	Subversion_WC_INFO(${PROJECT_SOURCE_DIR} ${project_name})
	#This requires connection to the server which might be annoying...
	#Subversion_WC_LOG(${PROJECT_SOURCE_DIR} ${project_name})
	#message("Last changed log is ${${project_name}_LAST_CHANGED_LOG}")
	SET (${project_name}_REVISION ${${project_name}_WC_REVISION} CACHE STRING "The detected revision of the source repository" FORCE)
else(Subversion_FOUND)
	SET (${project_name}_REVISION "SVN-NOTFOUND" CACHE STRING "The detected revision of the source repository" FORCE)
endif(Subversion_FOUND)

endmacro (WkSvn)