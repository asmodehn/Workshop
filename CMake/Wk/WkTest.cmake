#
# Defining test rules based on a well known hierarchy
# You need at least the test subdirectory in you hierarchy for this to work.
# One source file can be used for a set of tests.
#

if ( CMAKE_BACKWARDS_COMPATIBILITY LESS 2.6.3 )
	message ( FATAL_ERROR " CMAKE MINIMUM BACKWARD COMPATIBILITY REQUIRED : 2.6.3 !" )
endif( CMAKE_BACKWARDS_COMPATIBILITY LESS 2.6.3 )

#WkTestBuild( test_name )

MACRO(WkTestBuild )

	option(${PROJECT_NAME}_ENABLE_TESTS "Wether or not you want the project to include the tests and enable automatic testing for ${PROJECT_NAME}" OFF)

	
					foreach ( looparg ${${PROJECT_NAME}_bin_depends} )
					#reincluding export file to get dependencies...
					include(${${looparg}_EXPORT_CMAKE}) 
					GET_TARGET_PROPERTY(${looparg}_LOCATION ${looparg} IMPORTED_LOCATION_RELEASE)
					message ( SEND_ERROR "${${looparg}_LOCATION}" )
					endforeach ( looparg ${${PROJECT_NAME}_bin_depends} )
	
	IF(${PROJECT_NAME}_ENABLE_TESTS)
		ENABLE_TESTING()
		
		foreach( test_name ${ARGN})
			FILE(GLOB testsource RELATIVE ${PROJECT_SOURCE_DIR} test/${test_name}.c test/${test_name}.cc test/${test_name}.cpp )
			#MESSAGE ( STATUS "Detected ${test_name} Source : ${testsource}" )
		
			#To make sure the source file exists
			IF (testsource)
				#Create output directories
				IF ( NOT EXISTS ${PROJECT_BINARY_DIR}/test )
					FILE ( MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/test )
				ENDIF ( NOT EXISTS ${PROJECT_BINARY_DIR}/test )
			
				#Really needed ??
				# TODO : investigate
				IF ( NOT EXISTS ${PROJECT_BINARY_DIR}/test/${CMAKE_BUILD_TYPE} )
					FILE ( MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/test/${CMAKE_BUILD_TYPE} )
				ENDIF ( NOT EXISTS ${PROJECT_BINARY_DIR}/test/${CMAKE_BUILD_TYPE} )
			
				#Set where test executables should be found
				SET(${PROJECT_NAME}_TESTS_OUTPUT_PATH ${PROJECT_BINARY_DIR}/test CACHE PATH "Ouput directory for ${Project} tests.")
				mark_as_advanced(FORCE ${PROJECT_NAME}_TESTS_OUTPUT_PATH)
				SET(EXECUTABLE_OUTPUT_PATH "${${PROJECT_NAME}_TESTS_OUTPUT_PATH}" CACHE INTERNAL "Internal CMake executables output directory. Do not edit." FORCE)
			
				#build
				ADD_EXECUTABLE(${test_name} ${testsource})
				TARGET_LINK_LIBRARIES(${test_name} ${PROJECT_NAME})
				ADD_DEPENDENCIES(${test_name} ${PROJECT_NAME})
				
				#We need to move project libraries and dependencies to the test target location after build.
				#We need to do that everytime to make sure we have the latest version
				#TODO : only when lib dynamic ( and module )
				#TODO : dependencies
				GET_TARGET_PROPERTY(${PROJECT_NAME}_LOCATION ${PROJECT_NAME} LOCATION)
				GET_TARGET_PROPERTY(${test_name}_LOCATION ${test_name} LOCATION)
				get_filename_component(${test_name}_PATH ${${test_name}_LOCATION} PATH)
				ADD_CUSTOM_COMMAND( TARGET ${test_name} POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy_if_different ${${PROJECT_NAME}_LOCATION} ${${test_name}_PATH}
														COMMENT "Copying ${${PROJECT_NAME}_LOCATION} to ${${test_name}_PATH}" )
				#needed for each imported binary dependency as well
				foreach ( looparg ${${PROJECT_NAME}_bin_depends} )
					GET_TARGET_PROPERTY(${looparg}_LOCATION ${looparg} IMPORTED_LOCATION_RELEASE)
					message ( SEND_ERROR "${${looparg}_LOCATION}" )
					ADD_CUSTOM_COMMAND( TARGET ${test_name} POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy_if_different ${${looparg}_LOCATION} ${${test_name}_PATH}
														COMMENT "Copying ${${PROJECT_NAME}_LOCATION} to ${${test_name}_PATH}" )
				
				endforeach ( looparg ${${PROJECT_NAME}_bin_depends} )
			ENDIF (testsource)
		endforeach ( test_name ${ARGN})
	ENDIF(${PROJECT_NAME}_ENABLE_TESTS)

ENDMACRO(WkTestBuild)

#
# Calls the same test executable multiple times, eachtime with 1 argument
#
# WkTestRun( test_name [ arguments [...] ] )
#

MACRO(WkTestRun test_name )

	IF(${PROJECT_NAME}_ENABLE_TESTS)
		ENABLE_TESTING()
	
		#if test arguments
		IF ( ${ARGC} GREATER 2 )
			FOREACH ( looparg ${ARGN} )
				ADD_TEST(${test_name}_${looparg} ${PROJECT_BINARY_DIR}/test/${test_name} ${looparg})
			ENDFOREACH ( looparg )
		ELSE ( ${ARGC} GREATER 2  )
			ADD_TEST(${test_name} ${PROJECT_BINARY_DIR}/test/${test_name})
		ENDIF ( ${ARGC} GREATER 2  )
	
	ENDIF(${PROJECT_NAME}_ENABLE_TESTS)

ENDMACRO(WkTestRun)
