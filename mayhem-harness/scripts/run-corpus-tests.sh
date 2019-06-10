#!/bin/bash

set -euox pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Work in the mayhem-harness folder
cd $DIR/..

# Run each corpus test to gather coverage
for test in corpus/*
do
  build/mayhem-harness-exe & sleep 1; nc 127.0.0.1 8000 < $test
done