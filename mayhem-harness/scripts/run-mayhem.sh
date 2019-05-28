#!/bin/bash

set -euox pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. $DIR/init.sh

docker --version

# Launch a new mayhem run and wait for it to complete
run=$(docker run -it --rm \
       -e MAYHEM_CREDS="$MAYHEM_CREDS" \
       -e MAYHEM_TOKEN="$MAYHEM_TOKEN" \
       -e MAYHEM_URL="$MAYHEM_URL" \
       -v "$DIR/.config/mayhem:/root/.config/mayhem" \
       $BUILD_TAG \
       /bin/sh -c "mayhem login &> /dev/null; mayhem run ./")

run=`echo "$run" | tail -1`
echo "Waiting for run '$run'..."

# Wait for run to complete
docker run -it --rm \
       -e MAYHEM_CREDS="$MAYHEM_CREDS" \
       -e MAYHEM_TOKEN="$MAYHEM_TOKEN" \
       -v "$DIR/.config/mayhem:/root/.config/mayhem" \
       $BUILD_TAG \
       /bin/sh -c "mayhem wait --junit mayhem_results.xml $run && cat mayhem_results.xml"