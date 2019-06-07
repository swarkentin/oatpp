#!/bin/bash

# Move to the parent folder
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR/..

# Build oatpp
mkdir build
cd build
cmake  -DCMAKE_BUILD_TYPE=Debug ..
make install

# Build the test harness
cd $DIR
mkdir build
cd build
cmake  -DCMAKE_BUILD_TYPE=Debug ..
make