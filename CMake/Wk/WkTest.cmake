#
# Defining test rules based on a well known hierarchy
# You need at least the test subdirectory in you hierarchy for this to work.
# One source file can be used for a set of tests.
#

if ( CMAKE_BACKWARDS_COMPATIBILITY LESS 2.6 )
	message ( FATAL_ERROR " CMAKE MINIMUM BACKWARD COMPATIBILITY REQUIRED : 2.6 !" )
endif( CMAKE_BACKWARDS_COMPATIBILITY LESS 2.6 )

#WkTestBuild( test_name project_dependencies [ other_dependencies [...] ] )

MACRO(WkTestBuild test_name project_name  )

	option(${project_name}_ENABLE_TESTS "Wether or not you want the project to include the tests and enable automatic testing for ${project_name}" OFF)

	IF(${project_name}_ENABLE_TESTS)
		ENABLE_TESTING()
		
		FILE(GLOB testsource RELATIVE ${PROJECT_SOURCE_DIR} test/${test_name}.c test/${test_name}.cc test/${test_name}.cpp )
		#MESSAGE ( STATUS "Detected ${test_name} Source : ${testsource}" )
		
		#To make sure the source file exists
		IF (testsource)
			#Create output directories
			IF ( NOT EXISTS ${PROJECT_BINARY_DIR}/test )
				FILE ( MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/test )
			ENDIF ( NOT EXISTS ${PROJECT_BINARY_DIR}/test )
			
			IF ( NOT EXISTS ${PROJECT_BINARY_DIR}/test/${CMAKE_BUILD_TYPE} )
				FILE ( MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/test/${CMAKE_BUILD_TYPE} )
			ENDIF ( NOT EXISTS ${PROJECT_BINARY_DIR}/test/${CMAKE_BUILD_TYPE} )
			
			#Set where main library & test executables should be founded (useful for debuging under VS)
			SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/test)
			#SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)
			
			#build
			ADD_EXECUTABLE(${test_name} ${testsource})
			TARGET_LINK_LIBRARIES(${test_name} ${project_name})
			ADD_DEPENDENCIES(${test_name} ${project_name})
			
			#We need to move project libraries and dependencies to the test target location after build.
			#We need to do that everytime to make sure we have the latest version
			#TODO : only when lib dynamic ( and module )
			#TODO : dependencies
			GET_TARGET_PROPERTY(${project_name}_LOCATION ${project_name} LOCATION)
			GET_TARGET_PROPERTY(${test_name}_LOCATION ${test_name} LOCATION)
			get_filename_component(${test_name}_PATH ${${test_name}_LOCATION} PATH)
			ADD_CUSTOM_COMMAND( TARGET ${test_name} POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy_if_different ${${project_name}_LOCATION} ${${test_name}_PATH}
													COMMENT "Copying ${${project_name}_LOCATION} to ${${test_name}_PATH}" )
			
			#if test arguments
			IF ( ${ARGC} GREATER 2 )
				#Forcing static libraries. test are always executables, and shared libraries or modules should be built and installed separately, if they ever have to come into a test...
				SET(${project_name}_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
				SET(BUILD_SHARED_LIBS OFF)
				FOREACH ( looparg ${ARGN} )
					MESSAGE ( STATUS "==" )
					MESSAGE ( STATUS "Cmake'ing ${test_name} Dependency : ${looparg}" )
					ADD_SUBDIRECTORY(test/ext/${looparg} test/ext/${looparg}_build EXCLUDE_FROM_ALL)
					TARGET_LINK_LIBRARIES(${test_name} ${looparg})
					ADD_DEPENDENCIES(${test_name} ${looparg})
					INCLUDE_DIRECTORIES(test/ext/${looparg}/include)
					MESSAGE ( STATUS "Cmake'ing ${looparg} : Done." )
					MESSAGE ( STATUS "==" )
				ENDFOREACH ( looparg )
				#MESSAGE ( STATUS "Back to configuring ${project_name} build" )
				SET( BUILD_SHARED_LIBS ${${project_name}_BUILD_SHARED_LIBS} )
			ENDIF ( ${ARGC} GREATER 2  )
		ENDIF (testsource)
	
	ENDIF(${project_name}_ENABLE_TESTS)

ENDMACRO(WkTestBuild)

#
# Calls the same test executable multiple times, eachtime with 1 argument
#
# WkTestRun( test_name [ arguments [...] ] )
#

MACRO(WkTestRun test_name project_name)

	IF(${project_name}_ENABLE_TESTS)
		ENABLE_TESTING()
	
		#if test arguments
		IF ( ${ARGC} GREATER 2 )
			FOREACH ( looparg ${ARGN} )
				ADD_TEST(${test_name}_${looparg} ${PROJECT_BINARY_DIR}/test/${test_name} ${looparg})
			ENDFOREACH ( looparg )
		ELSE ( ${ARGC} GREATER 2  )
			ADD_TEST(${test_name} ${PROJECT_BINARY_DIR}/test/${test_name})
		ENDIF ( ${ARGC} GREATER 2  )
	
	ENDIF(${project_name}_ENABLE_TESTS)

ENDMACRO(WkTestRun)

# This helper macro will browse the test subdirectory and create a test target for each file found to be called once without arguments,
# assuming that each and everysource file in test has a main entry point.

#WkTestAllOnce ( project_name [common additional dependencies [...] ])

macro(WkTestAllOnce project_name )

	file(GLOB testsources RELATIVE ${PROJECT_SOURCE_DIR} test/*.c test/*.cpp test/*.cc)
	message ( STATUS "Test Sources : ${testsources} " )
	foreach ( testsrc ${testsources} )
		get_filename_component(testtarget ${testsrc} NAME_WE)
		WkTestBuild(${testtarget} ${project_name} ${ARGN} )
		WkTestRun(${testtarget} ${project_name})
	endforeach ( testsrc ${testsources} )
	
endmacro(WkTestAllOnce)
