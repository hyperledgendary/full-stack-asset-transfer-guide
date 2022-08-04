#
# SPDX-License-Identifier: Apache-2.0
#
FROM ubuntu:latest

# Build tools
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install build-essential gcc gzip \
    && apt-get -y install python3 python3-distutils libpython3-dev software-properties-common \   
    && apt-get -y install curl git jq unzip moreutils 


ADD provision-root.sh /config/provision-root.sh
RUN cat /config/provision-root.sh | bash
# RUN curl -sSL https://raw.githubusercontent.com/hyperledgendary/fabric-devenv/main/provision-root.sh | bash

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN useradd -ms /bin/bash dev && usermod -g docker dev
USER dev
ADD provision-user.sh /home/dev/provision-user.sh
RUN cat /home/dev/provision-user.sh | bash

WORKDIR /home/dev
RUN curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh | bash -s -- binary

RUN mkdir -p /home/dev/workshop

WORKDIR /home/dev/workshop
ENV PATH=/home/dev/bin:$PATH
ENV FABRIC_CFG_PATH=/home/dev/config
ENTRYPOINT ["bash"]
