#!/bin/bash

set -euox pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. $DIR/init.sh

docker --version
env | sort

# Wait for run to complete
docker run --rm \
       -e MAYHEM_CREDS="$MAYHEM_CREDS" \
       -e MAYHEM_TOKEN="$MAYHEM_TOKEN" \
       -e MAYHEM_URL="$MAYHEM_URL" \
       $BUILD_TAG \
       /bin/bash -c "mayhem login && mayhem wait --junit mayhem_results.xml \$(mayhem run ./) && cat mayhem_results.xml"