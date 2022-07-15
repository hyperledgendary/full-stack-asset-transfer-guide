#
# SPDX-License-Identifier: Apache-2.0
#
FROM ubuntu:latest

# Build tools
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install build-essential gcc gzip \
                  python3 python3-distutils libpython3-dev software-properties-common \   
                  curl git jq\    
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Kube CLI (and OpenShift wrapper)
RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.6.0-202005061824.git.1.7376912.el7/linux/oc.tar.gz --output oc.tar.gz \
   && tar xvzf oc.tar.gz \
   && chmod u+x ./oc \
   && mv ./oc /usr/local/bin/oc

COPY ibm-blockchain_platform-1.2.1.tar.gz .

# Python & Ansible
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python3 get-pip.py  \
    && pip3 install  "ansible>=2.9,<2.10" fabric-sdk-py python-pkcs11 openshift semantic_version\
    && ansible --version \
    && ansible-galaxy collection install ./ibm-blockchain_platform-1.2.1.tar.gz -f

# Node
# ENV NODE_VERSION 14.15.4
# RUN export NVM_DIR="$HOME/.nvm" \
#     && . "$NVM_DIR/nvm.sh" \
#     && nvm install $NODE_VERSION \
#     && nvm alias default $NODE_VERSION \
#     && nvm use default 
#     # && npm install --unsafe-perm -g @hyperledgendary/weftility@0.0.7

# Fabric tooling
RUN mkdir -p /opt/fabric \
    && curl -sSL https://github.com/hyperledger/fabric/releases/download/v2.4.3/hyperledger-fabric-linux-amd64-2.4.3.tar.gz | tar xzf - -C /opt/fabric  \
    && curl -sSL https://github.com/hyperledger/fabric-ca/releases/download/v1.5.3/hyperledger-fabric-ca-linux-amd64-1.5.3.tar.gz | tar xzf - -C /opt/fabric
ENV FABRIC_CFG_PATH=/opt/fabric/config
ENV PATH=/opt/fabric/bin:${PATH}

# Add editor
RUN cd /usr/local/bin; curl https://getmic.ro | bash \
    && curl -sL https://github.com/jt-nti/cds-cli/releases/download/0.3.0/cds-0.3.0-linux > /opt/fabric/bin/cds && chmod +x /opt/fabric/bin/cds

RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin


COPY ./justfile /justfile

WORKDIR /workspace
ENTRYPOINT ["just","-f","/justfile"]