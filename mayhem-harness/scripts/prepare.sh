#!/bin/bash

set -euox pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# $BUILD_TAG and $TARGET_TAG come from init.sh where they are shared between scripts
. $DIR/init.sh

docker --version

# This builds the application inside of a docker image
docker build --build-arg MAYHEM_CREDS="$MAYHEM_CREDS" \
             --build-arg MAYHEM_URL="$MAYHEM_URL" \
             -t $BUILD_TAG \
             -f build.Dockerfile \
             .
# Create a container with the executable that will be fuzzed
docker run -t --rm \
       -v /var/run/docker.sock:/var/run/docker.sock \
       $BUILD_TAG \
       /bin/sh -c "docker build -t $TARGET_TAG -f mayhem.Dockerfile ."

# Upload fuzzable image to mayem so that a new mayhem run can be created
docker run -t --rm \
       -e MAYHEM_CREDS="$MAYHEM_CREDS" \
       -e MAYHEM_TOKEN="$MAYHEM_TOKEN" \
       -v /var/run/docker.sock:/var/run/docker.sock \
       $BUILD_TAG \
        /bin/sh -c "docker login -u ${MAYHEM_API_USER} -p ${MAYHEM_TOKEN} beta.forallsecure.com:5000 && docker push $TARGET_TAG"