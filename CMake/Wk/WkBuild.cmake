
MACRO(MERGE ALIST BLIST OUTPUT)
   SET(BTEMP ${BLIST})
   FOREACH(A ${ALIST})
       SET(SORTED)
       SET(UNINSERTED 1)
       FOREACH(B ${BTEMP})
           IF(${UNINSERTED})
               IF(${A} STRLESS ${B})
                   SET(SORTED ${SORTED} ${A})
                   SET(UNINSERTED 0)
               ENDIF(${A} STRLESS ${B})
           ENDIF(${UNINSERTED})
           SET(SORTED ${SORTED} ${B})
       ENDFOREACH(B ${BLIST})
       IF(${UNINSERTED})
           SET(SORTED ${SORTED} ${A})
       ENDIF(${UNINSERTED})
       SET(BTEMP ${SORTED})
   ENDFOREACH(A ${ALIST})
   SET(${OUTPUT} ${BTEMP})
ENDMACRO(MERGE ALIST BLIST OUTPUT)


#
# Configure and Build process based on well-known hierarchy
# You need include and src in your hierarchy at least for this to work correctly
# You also need MergeLists.txt 
#

#WkBuild( project_name EXECUTABLE | LIBRARY [dependencies [...] ] )

macro (WkBuild project_name project_type)

	MESSAGE ( STATUS "Configuring ${project_name}" )	
		
	# testing type
	IF (NOT ${project_type} STREQUAL "EXECUTABLE" AND NOT ${project_type} STREQUAL "LIBRARY" )
		MESSAGE ( ERROR " Project type is not valid. Project type can be either EXECUTABLE or LIBRARY ")
	ENDIF (NOT ${project_type} STREQUAL "EXECUTABLE" AND NOT ${project_type} STREQUAL "LIBRARY" )		
	
	#Verbose Makefile if not release build. Making them internal not to confuse user by appearing with values used only for one project.
	IF (CMAKE_BUILD_TYPE STREQUAL Release)
		SET(CMAKE_VERBOSE_MAKEFILE OFF CACHE INTERNAL "Verbose build commands disabled for Release build." FORCE)
		SET (CMAKE_USE_RELATIVE_PATHS OFF CACHE INTERNAL "Absolute paths used in makefiles and projects for Release build." FORCE)
	ELSE (CMAKE_BUILD_TYPE STREQUAL Release)
		# To get the actual commands used
		SET(CMAKE_VERBOSE_MAKEFILE ON CACHE INTERNAL "Verbose build commands enabled for Non Release build." FORCE)
		# To have more readable filepaths used with the compiler. However this make a dependency in a symbolic linked directory fail.
		#SET (CMAKE_USE_RELATIVE_PATHS ON CACHE INTERNAL "Relative paths used in makefiles and projects for Non Release build." FORCE)
		
		#VLD
		SET(CHECK_MEM_LEAKS OFF CACHE BOOL "On to check memory with VLD (must be installed)")
		IF(CHECK_MEM_LEAKS)
			ADD_DEFINITIONS(-DVLD)
		ENDIF(CHECK_MEM_LEAKS)
	ENDIF (CMAKE_BUILD_TYPE STREQUAL Release)
	
	IF(${project_type} STREQUAL "LIBRARY")
		#Building dependencies, forcing them to static libs. Shared libs are supposed to be installed separately.
		IF ( ${ARGC} GREATER 2 )
			SET(${project_name}_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
			SET(BUILD_SHARED_LIBS OFF)
			FOREACH ( looparg ${ARGN} )
				#MESSAGE ( STATUS "==" )
				#MESSAGE ( STATUS "Cmake'ing dependency : ${looparg}" )
				#
				# CMake doesnt support convenience lib right now
				#building in separate build directory in case the father project is built in source...
				#ADD_SUBDIRECTORY(ext/${looparg} ext/${looparg}_build EXCLUDE_FROM_ALL)
				# CMake prefer the manual method
				#
				FILE(GLOB_RECURSE ${looparg}_SRCS RELATIVE ${PROJECT_SOURCE_DIR} ext/${looparg}/src/*.c ext/${looparg}/src/*.cpp ext/${looparg}/src/*.cc)
				FILE(GLOB_RECURSE ${looparg}_HEADERS RELATIVE ${PROJECT_SOURCE_DIR} ext/${looparg}/include/*.h ext/${looparg}/include/*.hh ext/${looparg}/include/*.hpp)
				MERGE("${DEPENDS_SRCS}" "${${looparg}_HEADERS};${${looparg}_SRCS}" DEPENDS_SRCS)
				#
				# Thats it !
				#
				#MESSAGE ( STATUS "Cmake'ing ${looparg} : Done." )
				#MESSAGE ( STATUS "==" )
			ENDFOREACH ( looparg )
			#MESSAGE ( STATUS "Back to configuring ${project_name} build" )
			SET( BUILD_SHARED_LIBS ${${project_name}_BUILD_SHARED_LIBS} )
		ENDIF ( ${ARGC} GREATER 2  )
	ENDIF(${project_type} STREQUAL "LIBRARY")
	IF(${project_type} STREQUAL "EXECUTABLE")
		#Building dependencies, forcing them to static libs. Shared libs are supposed to be installed separately.
		IF ( ${ARGC} GREATER 2 )
			SET(${project_name}_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
			SET(BUILD_SHARED_LIBS OFF)
			FOREACH ( looparg ${ARGN} )
				MESSAGE ( STATUS "==" )
				MESSAGE ( STATUS "Cmake'ing dependency : ${looparg}" )
				#building in separate build directory in case the father project is built in source...
				# TODO : BEWARE of circular dependencies...
				ADD_SUBDIRECTORY(ext/${looparg} ext/${looparg}_build EXCLUDE_FROM_ALL)
				MESSAGE ( STATUS "Cmake'ing ${looparg} : Done." )
				MESSAGE ( STATUS "==" )
			ENDFOREACH ( looparg )
			#MESSAGE ( STATUS "Back to configuring ${project_name} build" )
			SET( BUILD_SHARED_LIBS ${${project_name}_BUILD_SHARED_LIBS} )
		ENDIF ( ${ARGC} GREATER 2  )
	ENDIF(${project_type} STREQUAL "EXECUTABLE")
	
				
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
			IF(${project_type} STREQUAL "LIBRARY")
				# CMake doesnt support convenience lib right now
			ENDIF(${project_type} STREQUAL "LIBRARY")
			IF(${project_type} STREQUAL "EXECUTABLE")
				TARGET_LINK_LIBRARIES(${project_name} ${looparg})
				ADD_DEPENDENCIES(${project_name} ${looparg})
			ENDIF(${project_type} STREQUAL "EXECUTABLE")
		ENDFOREACH ( looparg )
	ENDIF ( ${ARGC} GREATER 2  )
	
	#
	# Defining where to put what has been built
	#
	SET(${project_name}_LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib CACHE PATH "Ouput directory for ${Project} libraries." )
	SET(LIBRARY_OUTPUT_PATH "${${project_name}_LIBRARY_OUTPUT_PATH}" CACHE INTERNAL "Internal CMake libraries output directory. Do not edit." FORCE)
	
	SET(${project_name}_EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin CACHE PATH "Ouput directory for ${Project} executables." )
	SET(EXECUTABLE_OUTPUT_PATH "${${project_name}_EXECUTABLE_OUTPUT_PATH}" CACHE INTERNAL "Internal CMake executables output directory. Do not edit." FORCE)
		
# Old version
#	SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib CACHE PATH "Ouput directory for libraries" FORCE)
#	SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin CACHE PATH "Output directory for executables" FORCE)
	
	#is that really usefull ?
	EXPORT_LIBRARY_DEPENDENCIES(${PROJECT_BINARY_DIR}/CMakeDepends.txt)

endmacro (WkBuild)
