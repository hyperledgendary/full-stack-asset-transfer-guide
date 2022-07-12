#!/bin/bash

# Copyright the Hyperledger Fabric contributors. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

set -e -u -o pipefail
ROOTDIR=$(cd "$(dirname "$0")" && pwd)

prefix=fab-test-net
tempdir=$(mktemp -d -t "$prefix.XXXXX") || error_exit "Error creating temporary directory"

DIR=${FABRIC_DIR:="${ROOTDIR}/../fabric"}

if [ -d "$DIR" ]
then
    if [ "$(ls -A $DIR)" ]; then
     echo "test-network $DIR is not Empty"
     exit 1
    fi
else
    echo "Directory $DIR not found. Creating..."
    mkdir -p ${DIR}
fi

pushd ${tempdir}
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh \
    && chmod +x install-fabric.sh \
    && ./install-fabric.sh binary samples docker

git clone https://github.com/hyperledger-labs/fabric-operator.git 
popd

cp -r ${tempdir}/fabric-samples/bin ${DIR}
cp -r ${tempdir}/fabric-samples/config ${DIR}

mkdir -p ${DIR}/operator-network
mkdir -p ${DIR}/docker-test-network

cp -r ${tempdir}/fabric-operator/* ${DIR}/operator-network
cp -r ${tempdir}/fabric-samples/test-network/* ${DIR}/docker-test-network

rm -Rf "$tempdir"

# ---- now need to get the fabric-operator



