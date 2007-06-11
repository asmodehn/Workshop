#
# Configure and Build process based on well-known hierarchy
# You need include and src in your hierarchy at least for this to work correctly
# You also need MergeLists.txt 
#

#WkBuild( project_name project_type [dependencies [...] ] )

include (CMake/MergeLists.cmake)

macro (WkBuild project_name project_type)

	MESSAGE ( STATUS "Configuring ${project_name}" )	
		
	# Managing Build Types
	
	#Verbose Makefile if not release build
	IF (CMAKE_BUILD_TYPE STREQUAL Release)
		SET(CMAKE_VERBOSE_MAKEFILE OFF CACHE BOOL "Verbose build commands disabled for Release build." FORCE)
		SET (CMAKE_USE_RELATIVE_PATHS OFF CACHE BOOL "Absolute paths used in makefiles and projects for Release build." FORCE)
	ELSE (CMAKE_BUILD_TYPE STREQUAL Release)
		# To get the actual commands used
		SET(CMAKE_VERBOSE_MAKEFILE ON CACHE BOOL "Verbose build commands enabled for Non Release build." FORCE)
		# To have more readable filepaths used with the compiler.
		SET (CMAKE_USE_RELATIVE_PATHS ON CACHE BOOL "Relative paths used in makefiles and projects for Non Release build." FORCE)
	ENDIF (CMAKE_BUILD_TYPE STREQUAL Release)
	MARK_AS_ADVANCED ( CMAKE_VERBOSE_MAKEFILE )
	MARK_AS_ADVANCED ( CMAKE_USE_RELATIVE_PATHS )
	
	#Building dependencies, forcing them to static libs. Shared libs are supposed to be installed separately
	IF ( ${ARGC} GREATER 2 )
		SET(${project_name}_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
		SET(BUILD_SHARED_LIBS OFF)
		FOREACH ( looparg ${ARGN} )
			#MESSAGE ( STATUS "Dependency build : ${looparg}" )
			#
			# CMake doesnt support convenience lib right now
			#ADD_SUBDIRECTORY(ext/${looparg})
			# CMake prefer the manual method
			#
			FILE(GLOB_RECURSE ${looparg}_SRCS RELATIVE ${PROJECT_SOURCE_DIR} ext/${looparg}/src/*.c ext/${looparg}/src/*.cpp ext/${looparg}/src/*.cc)
			FILE(GLOB_RECURSE ${looparg}_HEADERS RELATIVE ${PROJECT_SOURCE_DIR} ext/${looparg}/include/*.h ext/${looparg}/include/*.hh ext/${looparg}/include/*.hpp)
			MERGE("${DEPENDS_SRCS}" "${${looparg}_HEADERS};${${looparg}_SRCS}" DEPENDS_SRCS)
			#
			# Thats it !
			#
			#MESSAGE ( STATUS "Dependency build : Done." )
		ENDFOREACH ( looparg )
		#MESSAGE ( STATUS "Back to configuring ${project_name} build" )
		SET( BUILD_SHARED_LIBS ${${project_name}_BUILD_SHARED_LIBS} )
	ENDIF ( ${ARGC} GREATER 2  )
				
	#Defining target
	
	#VS workaround to display headers
	FILE(GLOB_RECURSE HEADERS RELATIVE ${PROJECT_SOURCE_DIR} include/*.h include/*.hh include/*.hpp)
	FILE(GLOB_RECURSE SOURCES RELATIVE ${PROJECT_SOURCE_DIR} src/*.c src/*.cpp src/*.cc)

	#Including configured headers (binary for the configured header, source for the unmodified ones, and in source/src for internal ones)
	INCLUDE_DIRECTORIES( ${PROJECT_SOURCE_DIR}/include ${PROJECT_SOURCE_DIR}/src)
 
        #Including dependencies' headers
        #
        IF ( ${ARGC} GREATER 2 )
                FOREACH ( looparg ${ARGN} )
                        INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/ext/${looparg}/include)
                ENDFOREACH ( looparg )
        ENDIF ( ${ARGC} GREATER 2  )

	MERGE("${HEADERS}" "${SOURCES}" SOURCES)
	#MESSAGE ( STATUS "Sources : ${SOURCES}" )
	
	IF(${project_type} STREQUAL "LIBRARY")
		ADD_LIBRARY(${project_name} ${DEPENDS_SRCS};${SOURCES})
	ENDIF(${project_type} STREQUAL "LIBRARY")
	IF(${project_type} STREQUAL "EXECUTABLE")
		ADD_EXECUTABLE(${project_name} ${SOURCES};${DEPENDS_SRCS})
	ENDIF(${project_type} STREQUAL "EXECUTABLE")

	#needed in case we dont have recognised file extension
	#SET_TARGET_PROPERTIES(${project_name} PROPERTIES LINKER_LANGUAGE CXX)
	#disabled to support different languages
	
	#
	#Linking dependencies
	#
	IF ( ${ARGC} GREATER 2 )
		FOREACH ( looparg ${ARGN} )
			# CMake doesnt support convenience lib right now
			#TARGET_LINK_LIBRARIES(${project_name} ${looparg})
			#ADD_DEPENDENCIES(${project_name} ${looparg})
		ENDFOREACH ( looparg )
	ENDIF ( ${ARGC} GREATER 2  )
	
	#
	# Defining where to put what has been built
	# NB : FORCE is important here to override dependencies output path...
	#
	SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib CACHE PATH "Ouput directory for libraries" FORCE)
	SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin CACHE PATH "Output directory for executables" FORCE)
	
	#is that really usefull ?
	EXPORT_LIBRARY_DEPENDENCIES(${PROJECT_BINARY_DIR}/CMakeDepends.txt)

endmacro (WkBuild)
