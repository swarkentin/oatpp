FROM debian:buster

ARG MAYHEM_CREDS
ARG MAYHEM_URL

RUN apt update \
  && apt install -y cmake \
  netcat \
  build-essential \
  curl \
  git \
  ca-certificates \
  apt-transport-https \
  gnupg2 \
  software-properties-common \
  unzip

# Download mayhem cli
RUN curl -v -u ${MAYHEM_CREDS} -o mayhem ${MAYHEM_URL}/images/mayhem && chmod +x mayhem &&  mv mayhem /usr/local/bin/

# Install Docker so that we can create a docker image for uploading
# to mayhem
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey \
  && add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
  $(lsb_release -cs) \
  stable" \
  && apt-get update \
  && apt-get -y install docker-ce

COPY . /home/travis/build/swarkentin/oatpp
WORKDIR /home/travis/build/swarkentin/oatpp/mayhem-harness

# Sonar build wrapper
RUN curl -o build-wrapper.zip https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip \
  && unzip build-wrapper.zip

RUN mkdir build \
  && cd build \
  && cmake  -DCMAKE_BUILD_TYPE=Debug .. \
  && ../build-wrapper-linux-x86/build-wrapper-linux-x86-64 --out-dir ../bw_output make


EXPOSE 8000 8000