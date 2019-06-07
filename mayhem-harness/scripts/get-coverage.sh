#!/bin/bash

set -euox pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Make sure we are working int he parent folder so that ALL source is covered.
cd $DIR/../..

#
# CMake puts object files and gcov files in the build folder. For each source
# file, this find the corresponding object/gcov files and references their
# folder as the 'output-folder' to correctly invoke gcov
#
files=$(find . -name "*.cpp")
for f in $files
do
  filename=$(basename -- "$f")
  no_suffix="${filename%.*}"
  objfile=$filename.o
  for o in $(find . -name $objfile)
  do
    objdir=$( dirname $o)
    echo $objdir
    #
    # CMake includes the original file extension in the gcov files,
    # but gcov expects no original suffix!
    #
    # [CMAKE]
    # file.cpp ->
    #          file.cpp.o
    #          file.cpp.gcda
    #          file.cpp.gcno
    # [expected]
    # file.cpp ->
    #          file.gcda
    #          file.gcno
    #
    # The following makes sure that this assumption by gcov is
    # satisfied
    mv $objdir/$no_suffix*.gcda $objdir/$no_suffix.gcda
    mv $objdir/$no_suffix*.gcno $objdir/$no_suffix.gcno
    gcov $f -o $objdir
  done
done

#
# Put all of the coverage files together for sonarqube
#
for f in $(find . -name "*.gcov")
do
  cp $f coverage-results
done