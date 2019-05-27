FROM debian:buster

ARG MAYHEM_CREDS
ARG MAYHEM_URL

RUN apt update \
    && apt install -y cmake \
    g++ \
    curl \
    git \
    ca-certificates \
    apt-transport-https \
    gnupg2 \
    software-properties-common

# Install Docker so that we can create a docker image for uploading
# to mayhem
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable" && \
    apt-get update && \
    apt-get -y install docker-ce

ENV CXX=/usr/bin/g++
COPY . /workdir/
WORKDIR /workdir/mayhem-harness
RUN mkdir build \
    && cd build \
    && cmake  .. \
    && make

# Download mayhem cli
RUN curl -u ${MAYHEM_CREDS} -o mayhem ${MAYHEM_URL}/images/mayhem && chmod +x mayhem &&  mv mayhem /usr/local/bin/