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


# Main justfile to run all the scripts
#
# To install 'just' see https://github.com/casey/just#installation


# Ensure all properties are exported as shell env-vars
set export

# set the current directory, and the location of the test dats
CWDIR := justfile_directory()

_default:
  @just -f {{justfile()}}  --list

bootstrap:
    #!/bin/bash


cluster_name := "kind"


doit: kind review-config operator console sample-network

# Starts a local KIND Kubernetes cluster
# Installs Nginx ingress controller
# Adds a DNS override in kube DNS for *.localho.st -> Nginx LB IP
kind:
    infrastructure/kind_with_nginx.sh {{cluster_name}}
    ls -lart ~/.kube/config
    chmod o+r ~/.kube/config

unkind:
    #!/bin/bash
    kind delete cluster --name {{cluster_name}}

review-config:
    #!/bin/bash
    mkdir -p _cfg
    rm -rf _cfg/*  || true
    
    cp ${CWDIR}/infrastructure/configuration/*.yml ${CWDIR}/_cfg

    echo ">> Fabric Operations Console Configuration"
    echo ""
    cat ${CWDIR}/_cfg/operator-console-vars.yml

    echo ">> Fabric Common Configuration"
    echo ""
    cat ${CWDIR}/_cfg/fabric-common-vars.yml

    echo ">> Fabric Org1 Configuration"
    echo ""
    cat ${CWDIR}/_cfg/fabric-org1-vars.yml

    echo ">> Fabric Org2 Configuration"
    echo ""
    cat ${CWDIR}/_cfg/fabric-org2-vars.yml

    echo ">> Fabric Orderer Configuration"
    echo ""
    cat ${CWDIR}/_cfg/fabric-ordering-org-vars.yml

# Just install the fabric-operator
operator:
    #!/bin/bash
    set -ex -o pipefail

    docker run \
        --rm \
        -v ${HOME}/.kube/:/home/ibp-user/.kube/ \
        -v ${CWDIR}/_cfg:/_cfg \
        -v $(pwd)/infrastructure/operator_console_playbooks:/playbooks \
        --network=host \
        ofs-ansible:latest \
            ansible-playbook /playbooks/01-operator-install.yml


# Install the operations console and fabric-operator
console: 
    #!/bin/bash
    set -ex -o pipefail

    docker run \
        --rm \
        -v ${HOME}/.kube/:/home/ibp-user/.kube/ \
        -v $(pwd)/infrastructure/operator_console_playbooks:/playbooks \
        -v ${CWDIR}/_cfg:/_cfg \
        --network=host \
        ofs-ansible:latest \
            ansible-playbook /playbooks/02-console-install.yml

    AUTH=$(curl -X POST https://fabricinfra-hlf-console-console.localho.st:443/ak/api/v2/permissions/keys -u admin:password -k -H 'Content-Type: application/json' -d '{"roles": ["writer", "manager"],"description": "newkey"}')
    KEY=$(echo $AUTH | jq .api_key | tr -d '"')
    SECRET=$(echo $AUTH | jq .api_secret | tr -d '"')

    echo "Writing authentication file for Ansible based IBP (Software) network building"
    mkdir -p _cfg
    cat << EOF > $CWDIR/_cfg/auth-vars.yml
    api_key: $KEY
    api_endpoint: http://fabricinfra-hlf-console-console.localho.st/
    api_authtype: basic
    api_secret: $SECRET
    EOF
    cat ${CWDIR}/_cfg/auth-vars.yml

# Installs and configures a sample Fabric Network
sample-network: 
    #!/bin/bash
    set -ex -o pipefail

    docker run \
        --rm \
        -u $(id -u) \
        -v ${HOME}/.kube/:/home/ibp-user/.kube/ \
        -v ${CWDIR}/infrastructure/fabric_network_playbooks:/playbooks \
        -v ${CWDIR}/_cfg:/_cfg \
        --network=host \
        ofs-ansible:latest \
            ansible-playbook /playbooks/00-complete.yml

build-chaincode:
    #!/bin/bash
    set -ex -o pipefail
    pushd ${CWDIR}/contracts/asset-tx-typescript

    export IMG_NAME=localhost:5000/asset_tx
    DOCKER_BUILDKIT=1 docker build -t ${IMAGE_NAME} . --target k8s
    docker push ${IMG_NAME}

    # note the double { } for escaping
    export IMG_SHA=$(docker inspect --format='{{{{index .RepoDigests 0}}' localhost:5000/asset_tx | cut -d'@' -f2)
    weft chaincode package k8s --name ${IMG_NAME} --digest ${IMG_SHA}

    popd

deploy-chaincode: 
    #!/bin/bash
    set -ex -o pipefail

    cp ${CWDIR}/contracts/asset-tx-typescript/asset-tx-chaincode-vars.yml ${CWDIR}/_cfg
    docker run \
        --rm \
        -u $(id -u) \
        -v ${HOME}/.kube/:/home/ibp-user/.kube/ \
        -v ${CWDIR}/infrastructure/production_chaincode_playbooks:/playbooks \
        -v ${CWDIR}/_cfg:/_cfg \
        --network=host \
        ofs-ansible:latest \
            ansible-playbook /playbooks/19-install-and-approve-chaincode.yml 

    docker run \
        --rm \
        -u $(id -u) \
        -v ${HOME}/.kube/:/home/ibp-user/.kube/ \
        -v ${CWDIR}/infrastructure/production_chaincode_playbooks:/playbooks \
        -v ${CWDIR}/_cfg:/_cfg \
        --network=host \
        ofs-ansible:latest \
            ansible-playbook /playbooks/20-install-and-approve-chaincode.yml 

    docker run \
        --rm \
        -u $(id -u) \
        -v ${HOME}/.kube/:/home/ibp-user/.kube/ \
        -v ${CWDIR}/infrastructure/production_chaincode_playbooks:/playbooks \
        -v ${CWDIR}/_cfg:/_cfg \
        --network=host \
        ofs-ansible:latest \
            ansible-playbook /playbooks/21-commit-chaincode.yml 

# register-application: 
#     #!/bin/bash
#     set -ex -o pipefail

#     docker run \
#         --rm \
#         -u $(id -u) \
#         -v ${HOME}/.kube/:/home/ibp-user/.kube/ \
#         -v ${CWDIR}/infrastructure/fabric_network_playbooks:/playbooks \
#         -v ${CWDIR}/_cfg:/_cfg \
#         --network=host \
#         ofs-ansible:latest \
#             ansible-playbook /playbooks/22-register-application.yml           
