CMake Utils
===========

This section contains utilities for CMAKE.

Simply include the cmake file you want to use, and call the macro where it suits
you.

In the Wk subdirectory you will find a set of script to help you build software,
as long as you keeps the hierarchy similar to WkHierarchySample

One good practice is to use svn::external directory property to automatically
fetch those in your project.

WkCmake
-------

This project is aimed at being the base of every software developped in the Workshop.

It a set of Cmake scripts and customisation, to make project creation and use with cmake extremely easy, but yet powerful.

Currently the Hierarchy used for the project is this one :

/CMakeLists.txt - the main usual CMakeLists.txt file, but now able to use WKCmake macros.
/CMake - a directory to store cmake scripts that will be included in CMakeLists.txt
/data - a directory to store data used by the project ( to be detailed )
/doc - a directory to store documentation for the project ( to be detailed )
/ext - a directory to store external dependencies that should be built and embedded inside the current project (such as convenience libraries for example).
/include - a directory to store client-visible header files.
/src - a directory to store client-invisible header and source files.
/test - a directory to store sources used to test the project ( to be detailed )

The header and source files are automatically detected, based on their extensions.

Currently supported extensions : .c .cc .cpp .h .hh .hpp

Java is not currently supported ( though it actually is supported by CMake itself )

Beware WkCmake projects supports only a subset of CMake's BuildType : Debug and Release

