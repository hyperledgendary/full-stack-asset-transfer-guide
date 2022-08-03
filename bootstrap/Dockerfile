#
# SPDX-License-Identifier: Apache-2.0
#
FROM ubuntu:latest

# Build tools
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install build-essential gcc gzip \
                  python3 python3-distutils libpython3-dev software-properties-common \   
                  curl git jq


ADD provision-root.sh /config/provision-root.sh
RUN cat /config/provision-root.sh | bash
# RUN curl -sSL https://raw.githubusercontent.com/hyperledgendary/fabric-devenv/main/provision-root.sh | bash

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN useradd -ms /bin/bash dev && usermod -g docker dev
USER dev
ADD provision-user.sh /home/dev/provision.sh
RUN cat /home/dev/provision.sh | bash

RUN mkdir -p /home/dev/workshop
WORKDIR /home/dev/workshop

ENTRYPOINT ["bash"]
