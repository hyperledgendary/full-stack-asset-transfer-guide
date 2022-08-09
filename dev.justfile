#
# Copyright contributors to the Hyperledgendary Full Stack Asset Transfer project
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
# 	  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


# Main justfile to run all the developmnet scripts
# To install 'just' see https://github.com/casey/just#installation


# Ensure all properties are exported as shell env-vars
set export

# set the current directory, and the location of the test dats
CWDIR := justfile_directory()

_default:
  @just -f {{justfile()}} --list 

check:
  ${CWDIR}/check.sh

microfab-bye:
    #!/bin/bash
    set -e -o pipefail
    echo "Removing Microfab container if already running..."
    docker kill microfab >/dev/null || true

# Launch a micro fab instance and create configuration in _cfg/uf
microfab: microfab-bye
    #!/bin/bash
    set -e -o pipefail

    export CFG=$CWDIR/_cfg/uf
    export MICROFAB_CONFIG='{
        "endorsing_organizations":[
            {
                "name": "org1"
            }
        ],
        "channels":[
            {
                "name": "mychannel",
                "endorsing_organizations":[
                    "org1"
                ]
            }
        ],
        "capability_level":"V2_0"
    }'
    
    mkdir -p $CFG
    echo
    echo "Stating microfab...."
    docker run --name microfab --network host --rm -d -e MICROFAB_CONFIG="${MICROFAB_CONFIG}"  ibmcom/ibp-microfab    
    sleep 3
    curl -s http://console.127-0-0-1.nip.io:8080/ak/api/v1/components | weft microfab -w $CFG/_wallets -p $CFG/_gateways -m $CFG/_cfg/_msp -f
    cat << EOF > $CFG/org1admin.env
    export CORE_PEER_LOCALMSPID=org1MSP
    export CORE_PEER_MSPCONFIGPATH=$CFG/_cfg/_msp/org1/org1admin/msp
    export CORE_PEER_ADDRESS=org1peer-api.127-0-0-1.nip.io:8080
    export FABRIC_CFG_PATH=$CWDIR/config
    export PATH="${CWDIR}/bin:$PATH"
    EOF

    echo
    echo "To get an peer cli environment run:"
    echo
    echo '   source $WORKSHOP/_cfg/uf/org1admin.env' 
    
debugcc:
    #!/bin/bash
    set -e -o pipefail

    export CFG=$CWDIR/_cfg/uf

    pushd $CWDIR/contracts/asset-tx-typescript

    export CHAINCODE_SERVER_ADDRESS=0.0.0.0:9999
    export CHAINCODE_ID=$(weft chaincode package caas --path . --label asset-tx-ts --address ${CHAINCODE_SERVER_ADDRESS} --archive asset-tx-ts.tgz --quiet)
    export CORE_PEER_LOCALMSPID=org1MSP
    export CORE_PEER_MSPCONFIGPATH=$CFG/_cfg/_msp/org1/org1admin/msp
    export CORE_PEER_ADDRESS=org1peer-api.127-0-0-1.nip.io:8080

    echo "CHAINCODE_ID=${CHAINCODE_ID}"

    set -x && peer lifecycle chaincode install asset-tx-ts.tgz &&     { set +x; } 2>/dev/null
    echo
    set -x && peer lifecycle chaincode approveformyorg --channelID mychannel --name asset-tx -v 0 --package-id $CHAINCODE_ID --sequence 1 && { set +x; } 2>/dev/null
    echo
    set -x && peer lifecycle chaincode commit --channelID mychannel --name asset-tx -v 0 --sequence 1 && { set +x; } 2>/dev/null
    echo
    set -x && peer lifecycle chaincode querycommitted --channelID=mychannel && { set +x; } 2>/dev/null
    echo
    popd

    cat << CC_EOF >> $CFG/org1admin.env
    export CHAINCODE_SERVER_ADDRESS=0.0.0.0:9999
    export CHAINCODE_ID=${CHAINCODE_ID}
    CC_EOF

    echo "Added CHAINCODE_ID and CHAINCODE_SERVER_ADDRESS to org1admin.env"
    echo
    echo '   source $WORKSHOP/_cfg/uf/org1admin.env' 

devshell:
    docker run \
        --rm \
        -u $(id -u) \
        -it \
        -v ${CWDIR}:/home/dev/workshop \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --network=host \
        fabgo:latest
