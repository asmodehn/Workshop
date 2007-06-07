
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
