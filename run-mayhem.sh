#!/bin/bash

set -euxo pipefail

BUILD_TAG=forallsecure/oatpp-mahem-build
TARGET_TAG=beta.forallsecure.com:5000/forallsecure/oatpp-mayhem-harness

docker --version

# This builds the application inside of a docker image
docker build --build-arg MAYHEM_CREDS="$MAYHEM_CREDS" \
             --build-arg MAYHEM_URL="$MAYHEM_URL" \
             -t $BUILD_TAG \
             -f build.Dockerfile \
             .
# Create a container with the executable that will be fuzzed
docker run -it --rm \
       -v /var/run/docker.sock:/var/run/docker.sock \
       $BUILD_TAG \
       /bin/sh -c "docker build -t $TARGET_TAG -f mayhem.Dockerfile ."

# Upload fuzzable image to mayem so that a new mayhem run can be created
docker run -it --rm \
       -e MAYHEM_CREDS="$MAYHEM_CREDS" \
       -e MAYHEM_TOKEN="$MAYHEM_TOKEN" \
       -v /var/run/docker.sock:/var/run/docker.sock \
       $BUILD_TAG \
        /bin/sh -c "docker login -u ${MAYHEM_API_USER} -p ${MAYHEM_TOKEN} beta.forallsecure.com:5000 && docker push $TARGET_TAG"

# Launch a new mayhem run and wait for it to complete
docker run -it --rm \
       -e MAYHEM_CREDS="$MAYHEM_CREDS" \
       -e MAYHEM_TOKEN="$MAYHEM_TOKEN" \
       -e MAYHEM_URL="$MAYHEM_URL" \
       $BUILD_TAG \
       /bin/sh -c "mayhem login && mayhem run ./ && mayhem wait --junit mayhem_results.xml \$(mayhem show oatpp/oatpp-mayhem-harness | head -1 | cut -f3 --delim=' ') && cat mayhem_results.xml"