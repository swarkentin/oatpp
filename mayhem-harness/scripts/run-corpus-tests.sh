#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Work in the mayhem-harness folder
cd $DIR/..

# Run each corpus test to gather coverage
for test in corpus/*
do
  echo "Running mayhem test: $test"
  # Do not run web server for more than 5sec per test
  build/mayhem-harness-exe 5000 & sleep 1; nc 127.0.0.1 8000 < $test
done