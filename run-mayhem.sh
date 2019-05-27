#!/bin/sh

set -euxo pipefail

BUILD_TAG=forallsecure/oatpp-mahem-build

docker --version

# This builds the application inside of a docker image
docker build --build-arg MAYHEM_CREDS="$MAYHEM_CREDS" \
             --build-arg MAYHEM_URL="$MAYHEM_URL" \
             -t $BUILD_TAG \
             -f build.Dockerfile \
             .
# Create a container with the executable that will be fuzzed
docker run -it --rm BUILD_TAG \
       /bin/sh -c "docker build -t beta.forallsecure.com:5000/forallsecure/oatpp-mayhem-harness -f mayhem.Dockerfile ."

# Upload fuzzable image to mayem so that a new mayhem run can be created
docker run -it --rm \
       -e MAYHEM_CREDS="$MAYHEM_CREDS" \
       -e MAYHEM_TOKEN="$MAYHEM_TOKEN" \
       $BUILD_TAG \
        /bin/sh -c "docker login -u ${MAYHEM_API_USER} -p ${MAYHEM_TOKEN} beta.forallsecure.com:5000 && docker push beta.forallsecure.com:5000/forallsecure/oatpp-mayhem-harness"

# Launch a new mayhem run and wait for it to complete
docker run -it --rm \
       -e MAYHEM_CREDS="$MAYHEM_CREDS" \
       -e MAYHEM_TOKEN="$MAYHEM_TOKEN" \
       -e MAYHEM_URL="$MAYHEM_URL" \
       $BUILD_TAG \
       /bin/sh -c "mayhem login && mayhem run ./ && mayhem wait && mayhem show"