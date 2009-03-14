if ( CMAKE_BACKWARDS_COMPATIBILITY LESS 2.6 )
	message ( FATAL_ERROR " CMAKE MINIMUM BACKWARD COMPATIBILITY REQUIRED : 2.6 !" )
endif( CMAKE_BACKWARDS_COMPATIBILITY LESS 2.6 )

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

#WkBuild( project_name EXECUTABLE | LIBRARY [ STATIC|SHARED|MODULE ]  )

macro (WkBuild project_name project_type load_type)

	message ( STATUS "Configuring ${project_name}" )	
		
	# testing type
	if (NOT ${project_type} STREQUAL "EXECUTABLE" AND NOT ${project_type} STREQUAL "LIBRARY" )
		message ( FATAL_ERROR " Project type ${project_type} is not valid. Project type can be either EXECUTABLE or LIBRARY")
	endif (NOT ${project_type} STREQUAL "EXECUTABLE" AND NOT ${project_type} STREQUAL "LIBRARY" )
	if ( ${project_type} STREQUAL "LIBRARY" 
					AND NOT ${load_type} STREQUAL "STATIC"
					AND NOT ${load_type} STREQUAL "SHARED"
					AND NOT ${load_type} STREQUAL "MODULE"
		)
		message ( FATAL_ERROR " Project Load type ${load_type} is not valid. Project Load type can be either STATIC, SHARED or MODULE")
	endif  ( ${project_type} STREQUAL "LIBRARY" 
					AND NOT ${load_type} STREQUAL "STATIC"
					AND NOT ${load_type} STREQUAL "SHARED"
					AND NOT ${load_type} STREQUAL "MODULE"
		)
	
	#Verbose Makefile if not release build. Making them internal not to confuse user by appearing with values used only for one project.
	if (CMAKE_BUILD_TYPE STREQUAL Release)
		set(CMAKE_VERBOSE_MAKEFILE OFF CACHE INTERNAL "Verbose build commands disabled for Release build." FORCE)
		set(CMAKE_USE_RELATIVE_PATHS OFF CACHE INTERNAL "Absolute paths used in makefiles and projects for Release build." FORCE)
	else (CMAKE_BUILD_TYPE STREQUAL Release)
		# To get the actual commands used
		set(CMAKE_VERBOSE_MAKEFILE ON CACHE INTERNAL "Verbose build commands enabled for Non Release build." FORCE)
		
		#VLD
		set(CHECK_MEM_LEAKS OFF CACHE BOOL "On to check memory with VLD (must be installed)")
		if(CHECK_MEM_LEAKS)
			add_definitions(-DVLD)
		endif(CHECK_MEM_LEAKS)
	endif (CMAKE_BUILD_TYPE STREQUAL Release)
	
#	IF(${project_type} STREQUAL "LIBRARY")
#		#Building dependencies, forcing them to static libs. Shared libs are supposed to be installed separately.
#		IF ( ${ARGC} GREATER 2 )
#			FOREACH ( looparg ${ARGN} )
#				FILE(GLOB_RECURSE ${looparg}_SRCS RELATIVE ${PROJECT_SOURCE_DIR} ext/${looparg}/src/*.c ext/${looparg}/src/*.cpp ext/${looparg}/src/*.cc)
#				FILE(GLOB_RECURSE ${looparg}_HEADERS RELATIVE ${PROJECT_SOURCE_DIR} ext/${looparg}/include/*.h ext/${looparg}/include/*.hh ext/${looparg}/include/*.hpp)
#				MERGE("${DEPENDS_SRCS}" "${${looparg}_HEADERS};${${looparg}_SRCS}" DEPENDS_SRCS)
#			ENDFOREACH ( looparg )
#			#MESSAGE ( STATUS "Back to configuring ${project_name} build" )
#		ENDIF ( ${ARGC} GREATER 2  )
#	ENDIF(${project_type} STREQUAL "LIBRARY")
#	IF(${project_type} STREQUAL "EXECUTABLE")
		#Building dependencies recursively.
		file(GLOB project_depends RELATIVE ${PROJECT_SOURCE_DIR} ext/* )
				
		message ( STATUS " Dependencies detected : ${project_depends}" )
		
		if ( ${project_depends} )
			set(${project_name}_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
			#making sure that by default we build static libraries
			set(BUILD_SHARED_LIBS OFF)
			foreach ( looparg ${project_depends} )
				message ( STATUS "==" )
				message ( STATUS "Cmake'ing dependency ${looparg} : Started." )
				#building in separate build directory in case the father project is built in source...
				add_subdirectory(ext/${looparg} ext/${looparg}_build )
				message ( STATUS "Cmake'ing dependency ${looparg} : Done." )
				message ( STATUS "==" )
			endforeach ( looparg )
			#MESSAGE ( STATUS "Back to configuring ${project_name} build" )
			set( BUILD_SHARED_LIBS ${${project_name}_BUILD_SHARED_LIBS} )
		endif ( ${project_depends} )
#	ENDIF(${project_type} STREQUAL "EXECUTABLE")
	
				
	#Defining target
	
	#VS workaround to display headers
	FILE(GLOB_RECURSE HEADERS RELATIVE ${PROJECT_SOURCE_DIR} include/*.h include/*.hh include/*.hpp)
	FILE(GLOB_RECURSE SOURCES RELATIVE ${PROJECT_SOURCE_DIR} src/*.c src/*.cpp src/*.cc)

	#Including configured headers (
	#	-binary for the configured header, 
	#	-Cmake for Wk headers
	#	-source for the unmodified ones, 
	#	-and in source/src for internal ones)
	INCLUDE_DIRECTORIES( ${PROJECT_SOURCE_DIR}/CMake ${PROJECT_SOURCE_DIR}/include ${PROJECT_SOURCE_DIR}/src)
 
   #Including dependencies' headers
   #
        #IF ( ${ARGC} GREATER 2 )
    #            FOREACH ( looparg ${ARGN} )
    #                    INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/ext/${looparg}/include)
    #            ENDFOREACH ( looparg )
    #    ENDIF ( ${ARGC} GREATER 2  )

	#TODO : find a simpler way than this complex merge...
	MERGE("${HEADERS}" "${SOURCES}" SOURCES)
	#MESSAGE ( STATUS "Sources : ${SOURCES}" )
	
	if(${project_type} STREQUAL "LIBRARY")
		#message ( SEND_ERROR "add_library(${project_name} ${load_type} ${SOURCES} )" )
		add_library(${project_name} ${load_type} ${SOURCES})
		if(${load_type} STREQUAL "SHARED")
			set_target_properties(${project_name} PROPERTIES DEFINE_SYMBOL "WK_SHAREDLIB_BUILD")
		endif(${load_type} STREQUAL "SHARED")
	endif(${project_type} STREQUAL "LIBRARY")
	if(${project_type} STREQUAL "EXECUTABLE")
		add_executable(${project_name} ${SOURCES})
	endif(${project_type} STREQUAL "EXECUTABLE")

	#needed in case we dont have recognised file extension
	#SET_TARGET_PROPERTIES(${project_name} PROPERTIES LINKER_LANGUAGE CXX)
	#disabled to support different languages
	
	#
	#Linking dependencies
	#
	
	IF ( ${project_depends} )
		FOREACH ( looparg ${project_depends} )
			IF(${project_type} STREQUAL "LIBRARY")
				# CMake doesnt support convenience lib right now
			ENDIF(${project_type} STREQUAL "LIBRARY")
			IF(${project_type} STREQUAL "EXECUTABLE")
				TARGET_LINK_LIBRARIES(${project_name} ${looparg})
				ADD_DEPENDENCIES(${project_name} ${looparg})
			ENDIF(${project_type} STREQUAL "EXECUTABLE")
		ENDFOREACH ( looparg )
	ENDIF ( ${project_depends} )
	
	#
	# Defining where to put what has been built
	#
	
	SET(${project_name}_LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib CACHE PATH "Ouput directory for ${Project} libraries." )
	SET(LIBRARY_OUTPUT_PATH "${${project_name}_LIBRARY_OUTPUT_PATH}" CACHE INTERNAL "Internal CMake libraries output directory. Do not edit." FORCE)
	
	SET(${project_name}_EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin CACHE PATH "Ouput directory for ${Project} executables." )
	SET(EXECUTABLE_OUTPUT_PATH "${${project_name}_EXECUTABLE_OUTPUT_PATH}" CACHE INTERNAL "Internal CMake executables output directory. Do not edit." FORCE)

	#
	# Copying include directory if needed after build ( for  use by another project later )
	# for library (and modules ? )
	#
	
	if(${project_type} STREQUAL "LIBRARY") 
		ADD_CUSTOM_COMMAND( TARGET ${project_name} POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy_directory ${PROJECT_SOURCE_DIR}/include ${PROJECT_BINARY_DIR}/include
													COMMENT "Copying ${PROJECT_SOURCE_DIR}/include to ${PROJECT_BINARY_DIR}" )
	endif(${project_type} STREQUAL "LIBRARY") 
	
	
	#is that really usefull ?
	EXPORT_LIBRARY_DEPENDENCIES(${PROJECT_BINARY_DIR}/CMakeDepends.txt)

endmacro (WkBuild)
