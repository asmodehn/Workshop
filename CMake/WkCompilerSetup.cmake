#
# Compiler Specific rules
# All modifications for Flags should be here
# These macros exists to use more pedantic rules to build software. Thus improving the quality of working code
#

# Macros to redefine default options for build type

# Usage : WkSetCFlags( Project Build [flags] )

macro(WkSetCFlags Project Build)
	IF (${Build} STREQUAL All )
		SET(${Project}_C_FLAGS "${ARGN}" CACHE STRING "${Project} Flags for C Compiler.")
		MARK_AS_ADVANCED(FORCE ${Project}_C_FLAGS )
		SET(CMAKE_C_FLAGS "${${Project}_C_FLAGS}" CACHE INTERNAL "Internal CMake C Flags do not edit." FORCE)
	ELSEIF (${Build} STREQUAL Debug )
		SET(${Project}_C_FLAGS_DEBUG "${ARGN}" CACHE STRING " ${Project} Flags used by the C compiler during debug builds.")
		MARK_AS_ADVANCED(FORCE ${Project}_C_FLAGS_DEBUG )
		SET(CMAKE_C_FLAGS_DEBUG "${${Project}_C_FLAGS_DEBUG}" CACHE INTERNAL "Internal CMake C flags for Debug mode do not edit." FORCE)
	ELSEIF (${Build} STREQUAL Release )
		SET(${Project}_C_FLAGS_RELEASE "${ARGN}" CACHE STRING " ${Project} Flags used by the C compiler during release builds.")
		MARK_AS_ADVANCED(FORCE ${Project}_C_FLAGS_RELEASE )
		SET(CMAKE_C_FLAGS_RELEASE "${${Project}_C_FLAGS_RELEASE}" CACHE INTERNAL "Internal CMake C flags for Release mode do not edit." FORCE)
	ENDIF (${Build} STREQUAL All )
endmacro(WkSetCFlags )

# Usage : WkSetCXXFlags( Project Build [flags] )

macro(WkSetCXXFlags Project Build)
	IF (${Build} STREQUAL All )
		SET(${Project}_CXX_FLAGS "${ARGN}" CACHE STRING "${Project} Flags for C++ Compiler.")
		MARK_AS_ADVANCED(FORCE ${Project}_CXX_FLAGS )
		SET(CMAKE_CXX_FLAGS "${${Project}_CXX_FLAGS}" CACHE INTERNAL "Internal CMake C++ Flags do not edit." FORCE)
	ELSEIF (${Build} STREQUAL Debug )
		SET(${Project}_CXX_FLAGS_DEBUG "${ARGN}" CACHE STRING " ${Project} Flags used by the C++ compiler during debug builds.")
		MARK_AS_ADVANCED(FORCE ${Project}_CXX_FLAGS_DEBUG )
		SET(CMAKE_CXX_FLAGS_DEBUG "${${Project}_CXX_FLAGS_DEBUG}" CACHE INTERNAL "Internal CMake C++ flags for Debug mode do not edit." FORCE)
	ELSEIF (${Build} STREQUAL Release )
		SET(${Project}_CXX_FLAGS_RELEASE "${ARGN}" CACHE STRING " ${Project} Flags used by the C++ compiler during release builds.")
		MARK_AS_ADVANCED(FORCE ${Project}_CXX_FLAGS_RELEASE )
		SET(CMAKE_CXX_FLAGS_RELEASE "${${Project}_CXX_FLAGS_RELEASE}" CACHE INTERNAL "Internal CMake C++ flags for Release mode do not edit." FORCE)		
	ENDIF (${Build} STREQUAL All )
endmacro(WkSetCXXFlags )

# TODO : Java flags ???

# Usage : WkSetExeLinkerFlags( Project Build [flags] )

macro(WkSetExeLinkerFlags Project Build)
	IF (${Build} STREQUAL All )
		SET(${Project}_EXE_LINKER_FLAGS "${ARGN}" CACHE STRING "${Project} Flags used by the linker.")
		MARK_AS_ADVANCED(FORCE ${Project}_EXE_LINKER_FLAGS )
		SET(CMAKE_EXE_LINKER_FLAGS "${${Project}_EXE_LINKER_FLAGS}" CACHE INTERNAL "Internal CMake linker Flags do not edit." FORCE)
	ELSEIF (${Build} STREQUAL Debug )
		SET(${Project}_EXE_LINKER_FLAGS_DEBUG "${ARGN}" CACHE STRING " ${Project} Flags used by the linker during debug builds.")
		MARK_AS_ADVANCED(FORCE ${Project}_EXE_LINKER_FLAGS_DEBUG )
		SET(CMAKE_EXE_LINKER_FLAGS_DEBUG "${${Project}_EXE_LINKER_FLAGS_DEBUG}" CACHE INTERNAL "Internal CMake linker flags for Debug mode do not edit." FORCE)
	ELSEIF (${Build} STREQUAL Release )
		SET(${Project}_EXE_LINKER_FLAGS_RELEASE "${ARGN}" CACHE STRING " ${Project} Flags used by the linker during release builds.")
		MARK_AS_ADVANCED(FORCE ${Project}_EXE_LINKER_FLAGS_RELEASE )
		SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "${${Project}_EXE_LINKER_FLAGS_RELEASE}" CACHE INTERNAL "Internal CMake linker flags for Release mode do not edit." FORCE)		
	ENDIF (${Build} STREQUAL All )
endmacro(WkSetExeLinkerFlags )


# Usage : WkSetSharedLinkerFlags( Project Build [flags] )

macro(WkSetSharedLinkerFlags Project Build)
	IF (${Build} STREQUAL All )
		SET(${Project}_SHARED_LINKER_FLAGS "${ARGN}" CACHE STRING "${Project} Flags used by the linker during the creation of dll's.")
		MARK_AS_ADVANCED(FORCE ${Project}_SHARED_LINKER_FLAGS )
		SET(CMAKE_SHARED_LINKER_FLAGS "${${Project}_SHARED_LINKER_FLAGS}" CACHE INTERNAL "Internal CMake linker Flags do not edit." FORCE)
	ELSEIF (${Build} STREQUAL Debug )
		SET(${Project}_SHARED_LINKER_FLAGS_DEBUG "${ARGN}" CACHE STRING " ${Project} Flags used by the linker during debug builds.")
		MARK_AS_ADVANCED(FORCE ${Project}_SHARED_LINKER_FLAGS_DEBUG )
		SET(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${${Project}_SHARED_LINKER_FLAGS_DEBUG}" CACHE INTERNAL "Internal CMake linker flags for Debug mode do not edit" FORCE)
	ELSEIF (${Build} STREQUAL Release )
		SET(${Project}_SHARED_LINKER_FLAGS_RELEASE "${ARGN}" CACHE STRING " ${Project} Flags used by the linker during release builds.")
		MARK_AS_ADVANCED(FORCE ${Project}_SHARED_LINKER_FLAGS_RELEASE )
		SET(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${${Project}_SHARED_LINKER_FLAGS_RELEASE}" CACHE INTERNAL "Internal CMake linker flags for Release mode do not edit" FORCE)		
	ENDIF (${Build} STREQUAL All )
endmacro(WkSetSharedLinkerFlags )


# Usage : WkSetModuleLinkerFlags( Project Build [flags] )

macro(WkSetModuleLinkerFlags Project Build)
	IF (${Build} STREQUAL All )
		SET(${Project}_MODULE_LINKER_FLAGS "${ARGN}" CACHE STRING "${Project} Flags used by the linker during the creation of modules.")
		MARK_AS_ADVANCED(FORCE ${Project}_MODULE_LINKER_FLAGS )
		SET(CMAKE_MODULE_LINKER_FLAGS "${${Project}_MODULE_LINKER_FLAGS}" CACHE INTERNAL "Internal CMake linker Flags do not edit." FORCE)
	ELSEIF (${Build} STREQUAL Debug )
		SET(${Project}_MODULE_LINKER_FLAGS_DEBUG "${ARGN}" CACHE STRING " ${Project} Flags used by the linker during debug builds.")
		MARK_AS_ADVANCED(FORCE ${Project}_MODULE_LINKER_FLAGS_DEBUG )
		SET(CMAKE_MODULE_LINKER_FLAGS_DEBUG "${${Project}_MODULE_LINKER_FLAGS_DEBUG}" CACHE INTERNAL "Internal CMake linker flags for Debug mode do not edit" FORCE)
	ELSEIF (${Build} STREQUAL Release )
		SET(${Project}_MODULE_LINKER_FLAGS_RELEASE "${ARGN}" CACHE STRING " ${Project} Flags used by the linker during release builds.")
		MARK_AS_ADVANCED(FORCE ${Project}_MODULE_LINKER_FLAGS_RELEASE )
		SET(CMAKE_MODULE_LINKER_FLAGS_RELEASE "${${Project}_MODULE_LINKER_FLAGS_RELEASE}" CACHE INTERNAL "Internal CMake linker flags for Release mode do not edit" FORCE)		
	ENDIF (${Build} STREQUAL All )
endmacro(WkSetModuleLinkerFlags )
  
# Usage : WkDisableFlags ( Build )

macro ( WkDisableFlags Build )

IF(${Build} STREQUAL Debug)
	SET(CMAKE_C_FLAGS_DEBUG CACHE INTERNAL "Internal CMake C flags for Debug mode do not edit" FORCE)
	SET(CMAKE_CXX_FLAGS_DEBUG CACHE INTERNAL "Internal CMake C++ flags for Debug mode do not edit" FORCE)
	SET(CMAKE_EXE_LINKER_FLAGS_DEBUG CACHE INTERNAL "Internal CMake linker flags for Debug mode do not edit" FORCE)
	SET(CMAKE_SHARED_LINKER_FLAGS_DEBUG CACHE INTERNAL "Internal CMake linker flags for Debug mode do not edit" FORCE)
	SET(CMAKE_MODULE_LINKER_FLAGS_DEBUG CACHE INTERNAL "Internal CMake linker flags for Debug mode do not edit" FORCE)
ELSEIF(${Build} STREQUAL Release)
	SET(CMAKE_C_FLAGS_RELEASE CACHE INTERNAL "Internal CMake C flags for Release mode do not edit" FORCE)
	SET(CMAKE_CXX_FLAGS_RELEASE CACHE INTERNAL "Internal CMake C++ flags for Release mode do not edit" FORCE)
	SET(CMAKE_EXE_LINKER_FLAGS_RELEASE CACHE INTERNAL "Internal CMake linker flags for Release mode do not edit" FORCE)
	SET(CMAKE_SHARED_LINKER_FLAGS_RELEASE CACHE INTERNAL "Internal CMake linker flags for Release mode do not edit" FORCE)
	SET(CMAKE_MODULE_LINKER_FLAGS_RELEASE CACHE INTERNAL "Internal CMake linker flags for Release mode do not edit" FORCE)
ELSEIF(${Build} STREQUAL RelWithDebInfo)
	SET(CMAKE_C_FLAGS_RELWITHDEBINFO CACHE INTERNAL "Internal CMake C flags for Release with Debug Info mode do not edit" FORCE)
	SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO CACHE INTERNAL "Internal CMake C++ flags for Release with Debug Info mode do not edit" FORCE)
	SET(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO CACHE INTERNAL "Internal CMake linker flags for Release with Debug Info mode do not edit" FORCE)
	SET(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO CACHE INTERNAL "Internal CMake linker flags for Release with Debug Info mode do not edit" FORCE)
	SET(CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO CACHE INTERNAL "Internal CMake linker flags for Release with Debug Info mode do not edit" FORCE)
ELSEIF(${Build} STREQUAL MinSizeRel)
	SET(CMAKE_C_FLAGS_MINSIZEREL CACHE INTERNAL "Internal CMake C flags for Release minsize mode do not edit" FORCE)
	SET(CMAKE_CXX_FLAGS_MINSIZEREL CACHE INTERNAL "Internal CMake C++ flags for Release minsize mode do not edit" FORCE)
	SET(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL CACHE INTERNAL "Internal CMake linker flags for Release minsize mode do not edit" FORCE)
	SET(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL CACHE INTERNAL "Internal CMake linker flags for Release minsize mode do not edit" FORCE)
	SET(CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL CACHE INTERNAL "Internal CMake linker flags for Release minsize mode do not edit" FORCE)
ENDIF(${Build} STREQUAL Debug)

endmacro ( WkDisableFlags )
  
macro ( WkCompilerSetup Project )

# default build type and set of build mode possibilities
	IF(NOT CMAKE_BUILD_TYPE)
	  SET(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build, options are: None(${Project}_CXX_FLAGS or ${Project}_C_FLAGS used) Debug Release." FORCE)
	ENDIF(NOT CMAKE_BUILD_TYPE)
	
	WkDisableFlags( RelWithDebInfo )
	WkDisableFlags( MinSizeRel )
	
	IF(MSVC)
	
		MESSAGE( STATUS "Visual Studio Compiler detected. Adjusting C++ flags...")
		WkSetCFlags ( ${Project} All "/DWIN32 /D_WINDOWS /W3 /Zm1000" )
		WkSetCFlags ( ${Project} Debug "/D_DEBUG /MDd /Zi /Ob0 /Od /RTC1" )
		WkSetCFlags ( ${Project} Release "/MD /O2 /Ob2 /D NDEBUG" )
		WkSetCXXFlags ( ${Project} All "/DWIN32 /D_WINDOWS /W3 /Zm1000 /EHsc /GR" )
		WkSetCXXFlags ( ${Project} Debug "/D_DEBUG /MDd /Zi /Ob0 /Od /RTC1 /wd4100 /wd4290 /wd4512" )
		WkSetCXXFlags ( ${Project} Release "/MD /O2 /Ob2 /D NDEBUG /NODEFAULTLIB:msvcrt.lib" )
		WkSetExeLinkerFlags ( ${Project} All "/MANIFEST /STACK:10000000 /machine:I386" )
		WkSetSharedLinkerFlags ( ${Project} All "/MANIFEST /STACK:10000000 /machine:I386" )
		WkSetModuleLinkerFlags ( ${Project} All "/MANIFEST /STACK:10000000 /machine:I386" )
		
		WkSetExeLinkerFlags( ${Project} Debug )
		WkSetSharedLinkerFlags( ${Project} Debug )
		WkSetModuleLinkerFlags( ${Project} Debug )
			
		WkSetExeLinkerFlags( ${Project} Release )
		WkSetSharedLinkerFlags( ${Project} Release )
		WkSetModuleLinkerFlags( ${Project} Release )
		
	ELSEIF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
		
		MESSAGE( STATUS "GNU Compiler detected.")
		
		SET(GENERATE_PROFILING_INFO OFF CACHE BOOL "On to generate profiling information to use with gprof.")
		SET(PROFILE_FLAG)	
		IF(GENERATE_PROFILING_INFO)
			SET(PROFILE_FLAG -pg)
		ENDIF(GENERATE_PROFILING_INFO)

		WkSetCFlags ( ${Project} All "${PROFILE_FLAG} -Wall -pedantic" )
		WkSetCFlags ( ${Project} Debug "-g -D_DEBUG" )
		WkSetCFLags ( ${Project} Release "-O3 -DNDEBUG" )
		WkSetCXXFlags ( ${Project} All "${PROFILE_FLAG} -Wall -Wabi -pedantic" )
		WkSetCXXFlags ( ${Project} Debug "-g -D_DEBUG" )
		WkSetCXXFLags ( ${Project} Release "-O3 -DNDEBUG" )

		IF (MSYS)
			WkSetExeLinkerFlags( ${Project} All -Wl,--warn-once )
			WkSetSharedLinkerFlags( ${Project} All -Wl,--warn-once )
			WkSetModuleLinkerFlags( ${Project} All -Wl,--warn-once )
		ELSE (MSYS)
			WkSetExeLinkerFlags( ${Project} All -Wl,--warn-unresolved-symbols,--warn-once )
			WkSetSharedLinkerFlags( ${Project} All -Wl,--warn-unresolved-symbols,--warn-once )
			WkSetModuleLinkerFlags( ${Project} All -Wl,--warn-unresolved-symbols,--warn-once )
		ENDIF (MSYS)

		WkSetExeLinkerFlags( ${Project} Debug )
		WkSetSharedLinkerFlags( ${Project} Debug )
		WkSetModuleLinkerFlags( ${Project} Debug )
			
		WkSetExeLinkerFlags( ${Project} Release )
		WkSetSharedLinkerFlags( ${Project} Release )
		WkSetModuleLinkerFlags( ${Project} Release )
		
	ENDIF(MSVC)

#per build mode section
	IF (CMAKE_BUILD_TYPE STREQUAL Debug)
		IF(MSVC)			
			SET(CMAKE_CXX_WARNING_LEVEL 4)
		ENDIF(MSVC)
		IF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
			IF(CMAKE_COMPILER_IS_GNUCC)
			ENDIF(CMAKE_COMPILER_IS_GNUCC)
			IF(CMAKE_COMPILER_IS_GNUCXX)
			ENDIF(CMAKE_COMPILER_IS_GNUCXX)			
		ENDIF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
	ELSEIF (CMAKE_BUILD_TYPE STREQUAL Release)
		IF(MSVC)
			SET(CMAKE_CXX_WARNING_LEVEL 2)
		ENDIF(MSVC)
		IF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
			IF(CMAKE_COMPILER_IS_GNUCC)
			ENDIF(CMAKE_COMPILER_IS_GNUCC)
			IF(CMAKE_COMPILER_IS_GNUCXX)
			ENDIF(CMAKE_COMPILER_IS_GNUCXX)			
		ENDIF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
	ENDIF (CMAKE_BUILD_TYPE STREQUAL Debug)

endmacro ( WkCompilerSetup )
