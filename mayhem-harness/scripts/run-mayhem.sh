#!/bin/bash

set -euox pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# $BUILD_TAG and $TARGET_TAG come from init.sh where they are shared between scripts
. $DIR/init.sh

echo $(pwd)

docker --version

# Wait for run to complete
docker run --rm \
       -e MAYHEM_CREDS="$MAYHEM_CREDS" \
       -e MAYHEM_TOKEN="$MAYHEM_TOKEN" \
       -e MAYHEM_URL="$MAYHEM_URL" \
       -v $(pwd)/mayhem-harness/corpus:$(pwd)/mayhem-harness/corpus \
       -v $(pwd)/test-results:$(pwd)/mayhem-harness/test-results \
       $BUILD_TAG \
       /bin/bash -c "mayhem login && mayhem wait --junit test-results/mayhem_results.xml \$(mayhem run ./) && mayhem sync ./"

# Extract SonarQube build wrapper output
docker run --rm \
       -e MAYHEM_CREDS="$MAYHEM_CREDS" \
       -e MAYHEM_TOKEN="$MAYHEM_TOKEN" \
       -e MAYHEM_URL="$MAYHEM_URL" \
       -v $(pwd)/bw_output:$(pwd)/bw_output \
       $BUILD_TAG \
       /bin/bash -c "cp -R bw_output/* ../bw_output"

# Get coverage
docker run --rm \
       -e MAYHEM_CREDS="$MAYHEM_CREDS" \
       -e MAYHEM_TOKEN="$MAYHEM_TOKEN" \
       -e MAYHEM_URL="$MAYHEM_URL" \
       -v $(pwd)/mayhem-harness/corpus:$(pwd)/mayhem-harness/corpus \
       -v $(pwd)/coverage-results:$(pwd)/mayhem-harness/coverage-results \
       $BUILD_TAG \
       /bin/bash -c "cd build && cd .. && scripts/run-corpus-tests.sh && scripts/get-coverage.sh && cp gcov/* coverage-results/"
