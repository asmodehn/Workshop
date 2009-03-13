if ( CMAKE_BACKWARDS_COMPATIBILITY LESS 2.6 )
	message ( FATAL_ERROR " CMAKE MINIMUM BACKWARD COMPATIBILITY REQUIRED : 2.6 !" )
endif( CMAKE_BACKWARDS_COMPATIBILITY LESS 2.6 )

#
# Defining installation rules based on well known hierarchy
#

MACRO (WkInstall project_name)

	INSTALL ( FILES ${HEADERS} DESTINATION ${VERSION}/include )

	INSTALL	(
		TARGETS ${project_name}
		RUNTIME DESTINATION ${VERSION}/bin
		LIBRARY DESTINATION ${VERSION}/lib
		ARCHIVE DESTINATION ${VERSION}/lib/static
		)

ENDMACRO(WkInstall project_name)
