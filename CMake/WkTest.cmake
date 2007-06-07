#
# Defining test rules based on a well known hierarchy
# You need at least the test subdirectory in you hierarchy for this to work.
#

#WkTest( project_name testsource [arguments [...] ] )

MACRO(WkTest project_name testsource )

	SET(ENABLE_TESTS OFF CACHE BOOL "Wether or not you want the project to include the tests and enable automatic testing")

	IF(ENABLE_TESTS)
		ENABLE_TESTING()
	
		GET_FILENAME_COMPONENT( test ${testsource} NAME_WE)
	
		ADD_EXECUTABLE(${project_name}_${test} ${testsource})
		TARGET_LINK_LIBRARIES(${project_name}_${test} ${project_name})
		ADD_DEPENDENCIES(${project_name}_${test} ${project_name})
	
		#if test arguments
		IF ( ${ARGC} GREATER 2 )
			FOREACH ( looparg ${ARGN} )
				ADD_TEST(${project_name}_${test}_${looparg} ${EXECUTABLE_OUTPUT_PATH}/${project_name}_${test} ${looparg})
			ENDFOREACH ( looparg )
		ELSE ( ${ARGC} GREATER 2  )
			ADD_TEST(${project_name}_${test} ${EXECUTABLE_OUTPUT_PATH}/${project_name}_${test})
		ENDIF ( ${ARGC} GREATER 2  )
	
	ENDIF(ENABLE_TESTS)

ENDMACRO(WkTest)

# This macro will browse the test subdirectory and create a test target for each file found to be called once without arguments,
# assuming that each and everysource file in test has a main entry point.

#WkTestAllOnce ( project_name )

MACRO(WkTestAllOnce project_name )

	AUX_SOURCE_DIRECTORY(test testsources)
	FOREACH ( testsrc ${testsources} )
		WkTest( ${project_name} ${testsrc} )
	ENDFOREACH ( testsrc ${testsources} )
	
ENDMACRO(WkTestAllOnce)
