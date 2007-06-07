#!/bin/sh
#
# Shell script to generate a blank hierarchy that follows Workshop habits.
# This should be used for creating new projects which aims at using Wk*.cmake build system
#

mkdir CMake
mkdir data
mkdir doc
mkdir ext
mkdir include
mkdir src
mkdir test

touch CMakeLists.txt

# this should be improved to create a sample blank project using Wk*.cmake modules, possibly interactively...
