Workshop
========

Where all prototypes are grown, before making it into their own repository.

= Welcome to the default Workshop project =

This project aims at gathering little pieces of code, in a reusable way.
It can be used as a starting point for new prototypes ;)

Currently worked on prototypes include :
 * A portable C ISO90 memory debugger : CisoMemoryDebugger
 * A portable C ISO90 logger : CisoLogger
 * A portable C++ functor implementation : CppFunctor
 * A portable C++ logger : CppLogger
 * A portable C++ Static Assertion : CppStaticAssert
 * A portable C++ KDTree Implementation : [https://gna.org/projects/kdtree KDTree]
 * A portable C++ SDL utility toolkit : [https://gna.org/projects/aml SDLut]
 * A portable CMake enhancement with default hierarchy, to ease CMake base development : WkCmake
 * A NetBSD Tcl/Tk script to show graphically the memory usage of a running program : NetbsdMupg
 * A Documentation about installing NetBSD on server or client machine : [https://gna.org/projects/netbsd-intro NetBSDIntro]

If you want more information about the Trac Project Management , please have a look at the TracGuide.[[BR]]
If you need support about Trac, just check TracSupport.

For a complete list of Workshop project wiki pages, see TitleIndex.

Currently there is no release for the Workshop project.
If you have an account on this server and you want to checkout the current version of the sources from svn :

{{{
svn co svn+ssh://asmodehn.fr/home/svn/Workshop/trunk Workshop
}}}
Please make sure the user to login with is correctly setup, especially if you are using windows. Otherwise specify the user in the url, and omit externals, as they will not work.
To specify the auto login user on windows the easiest solution is to get putty, and configure the Connection / Data / username field and save as default settings.
Or you can modify the Subversion application data in you Documents and settings to force the username.

If you want an account please contact [mailto:admin@asmodehn.fr admin@asmodehn.fr]

To build a project using cmake, just cd to the correct directory ( where the corresponding CMakeLists.txt is located ) and run cmake :

{{{
cd /path/to/project/ && mkdir build && cd build && cmake ..
}}}
to get a build setup with the default values.[[BR]]
Or use ccmake ( unix / linux ) or cmakesetup.exe ( windows ) if you want to setup your own build options.[[BR]]
Once the build is ready you can use make or your usual IDE to build the software.

For more information about cmake build, please consult the [http://www.cmake.org "CMake Website"]









The C ISO90 Memory Debugger is the beginning of a portable memory debugger that you can include in your project source to detect memory leaks.

It is aimed at support malloc, calloc, realloc and strdup allocations, and support free deallocation.

It uses CisoLogger to show detected memory leaks and other various results.

Another goal is to make use of it in a C++ Memory Debugger, to detect new and new[] memory allocation and support delete and delete[] deallocation, on top of those already implemented.


The ISO90 Logger is the beginning of a portable Logger you can use in your project to log what you want to in a customisable way.

It is aimed at supporting customisable prefixes and loglevels.

Another goal is to make use of it in a C++ Logger.


Mupg is a Tcl/Tk script, that I eventually grabbed from the internet. I customozed it, so it could be used on NetBSD.

This is just the beginning of a project to show the resource usage of a running program graphically, based on portable unix tools, but it s already extremely useful.



This project aimed at being the implementation of a C++ Functor class that would allow the client to call any function inside any class instance as if it was a simple usual function.

This is very useful for callbacks, old C-style static callbacks.

Currently supports 1 to 3 arguments.

The goal is not to evolve as a full "Signal-Slot" or similar behavior implementation though, because some good libraries already exists. Instead this should remain simple and easy to use.




The ISO90 Logger is the beginning of a portable Logger you can use in your project to log what you want to in a customisable way.

It is aimed at supporting customisable prefixes and loglevels.

Another goal is to make use of it in a "namespace-based" C++ Logger.

Features are :[[BR]]
- Log levels - implemented and tested[[BR]]
- Prefixes - implemented and tested[[BR]]
- Specific prefix : displaying source filename and line number on runtime - implemented and tested [[BR]]

Some features are BuildType dependent :[[BR]]

Debug :[[BR]]
- Console Log[[BR]]
- Optional File Log[[BR]]

Release :[[BR]]
- Console Log disabled ( speed concerns )[[BR]]
- Optional File log[[BR]]








In projects using CMake build framework, like most of the projects here, it is possible to setup build types in a portable way.

The default cmake build types are None, Debug, Release, !RelWithDebInfo, !MinSizeRel.

However in projects using WkCmake, currently only two build types are fully supported : Release and Debug.[[BR]]
Also note that Debug is the default build type, that is the build type you get if you didnt specify anything.

Just trying to keeps things simple ;)





= C++ Functor =

This project aimed at being the implementation of a C++ Functor class that would allow the client to call any function inside any class instance as if it was a simple usual function.

This is very useful for callbacks, old C-style static callbacks.

Currently supports 1 to 3 arguments.

The goal is not to evolve as a full "Signal-Slot" or similar behavior implementation though, because some good libraries already exists. Instead this should remain simple and easy to use.

[../browser/trunk/C%2B%2B/Functor "View Source"]



= C ISO90 Memory Debugger =

This is the beginning of a portable memory debugger that you can include in your project source to detect memory leaks.

It is aimed at support malloc, calloc, realloc and strdup allocations, and support free deallocation.

It uses CisoLogger to show detected memory leaks and other various results.

Another goal is to make use of it in a C++ Memory Debugger, to detect new and new[] memory allocation and support delete and delete[] deallocation, on top of those already implemented.

[../browser/trunk/C/DbgMem "View Source"]


= C ISO90 Logger =

This project is the implementation of a portable Logger you can use in your project to log what you want to in a customisable way.

It supports customisable prefix and loglevels.

Features are :[[BR]]
- Log same message to console and to file - implemented and tested[[BR]]
- Possible different log levels for each target ( file and console ) - implemented and tested[[BR]]
- Customizable prefixes - implemented and tested[[BR]]
- Provides Source filename and line prefix - implemented and tested[[BR]]
- Provides Time/Date prefixes - implemented and tested[[BR]]

[../browser/trunk/C/Logger "View Source"]





= WkCmake =

This project is aimed at being the base of every software developped in the Workshop.

It a set of Cmake scripts and customisation, to make project creation and use with cmake extremely easy, but yet powerful.

Currently the Hierarchy used for the project is this one :

/CMakeLists.txt - the main usual CMakeLists.txt file, but now able to use WKCmake macros.[[BR]]
/CMake - a directory to store cmake scripts that will be included in CMakeLists.txt[[BR]]
/data - a directory to store data used by the project ( to be detailed )[[BR]]
/doc - a directory to store documentation for the project ( to be detailed )[[BR]]
/ext - a directory to store external dependencies that should be built and embedded inside the current project (such as convenience libraries for example).[[BR]]
/include - a directory to store client-visible header files.[[BR]]
/src - a directory to store client-invisible header and source files.[[BR]]
/test - a directory to store sources used to test the project ( to be detailed )

The header and source files are automatically detected, based on their extensions.

Currently supported extensions : .c .cc .cpp .h .hh .hpp

Java is not currently supported ( though it actually is supported by CMake itself )

Beware WkCmake projects supports only a subset of CMake's BuildType : Debug and Release

[../browser/trunk/CMake "View Source"]



= NetBSD Mupg = 

Mupg is a Tcl/Tk script, that I eventually grabbed from the internet. I customozed it, so it could be used on NetBSD.

This is just the beginning of a project to show the resource usage of a running program graphically, based on portable unix tools, but it s already extremely useful.

[../browser/trunk/NetBSD/mupg "View Source"]



= C++ Logger =

[../browser/trunk/C%2B%2B/Logger "View Source"]





= C++ Static Assertion =

[../browser/trunk/C%2B%2B/StaticAssert "View Source"]



