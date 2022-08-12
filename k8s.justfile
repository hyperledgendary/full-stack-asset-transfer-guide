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


cluster_name   := env_var_or_default("TEST_NETWORK_CLUSTER_NAME",   "kind")
namespace      := env_var_or_default("TEST_NETWORK_NS",             "fabricinfra")
ingress_domain := env_var_or_default("TEST_NETWORK_INGRESS_DOMAIN", "localho.st")

doit: kind review-config operator console sample-network

# Starts a local KIND Kubernetes cluster
# Installs Nginx ingress controller
# Adds a DNS override in kube DNS for *.{{ ingress_domain }} -> Nginx LB IP
kind:
    infrastructure/kind_with_nginx.sh {{cluster_name}}
    ls -lart ~/.kube/config
    chmod o+r ~/.kube/config

unkind:
    #!/bin/bash
    kind delete cluster --name {{cluster_name}}
    docker kill kind-registry
    docker rm kind-registry

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
        ghcr.io/ibm-blockchain/ofs-ansibe:main \
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
        ghcr.io/ibm-blockchain/ofs-ansibe:main \
            ansible-playbook /playbooks/02-console-install.yml

    AUTH=$(curl -X POST https://{{ namespace }}-hlf-console-console.{{ ingress_domain }}:443/ak/api/v2/permissions/keys -u admin:password -k -H 'Content-Type: application/json' -d '{"roles": ["writer", "manager"],"description": "newkey"}')
    KEY=$(echo $AUTH | jq .api_key | tr -d '"')
    SECRET=$(echo $AUTH | jq .api_secret | tr -d '"')

    echo "Writing authentication file for Ansible based IBP (Software) network building"
    mkdir -p _cfg
    cat << EOF > $CWDIR/_cfg/auth-vars.yml
    api_key: $KEY
    api_endpoint: http://{{ namespace }}-hlf-console-console.{{ ingress_domain }}/
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
        ghcr.io/ibm-blockchain/ofs-ansibe:main \
            ansible-playbook /playbooks/00-complete.yml

build-chaincode:
	#!/bin/bash
	set -ex -o pipefail
	pushd ${CWDIR}/contracts/asset-tx-typescript
	DOCKER_BUILDKIT=1 docker build -t asset_tx . --target k8s
	docker tag asset_tx localhost:5000/asset_tx
	docker push localhost:5000/asset_tx
	# note the double { } for escaping
	export IMG_SHA=$(docker inspect --format='{{{{index .RepoDigests 0}}' localhost:5000/asset_tx | cut -d'@' -f2)
	cat << IMAGEJSON-EOF > image.json
	{
	  "name": "localhost:5000/asset_tx",
	  "digest": "${IMG_SHA}"
	}
	IMAGEJSON-EOF

	tar -czf code.tar.gz image.json

	cat << METADATAJSON-EOF > metadata.json
	{
	    "type": "k8s",
	    "label": "asset-tx"
	}
	METADATAJSON-EOF
	tar -czf ${CWDIR}/_cfg/asset-tx-k8s-contract.tgz metadata.json code.tar.gz
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
        ghcr.io/ibm-blockchain/ofs-ansibe:main \
            ansible-playbook /playbooks/19-install-and-approve-chaincode.yml 

    docker run \
        --rm \
        -u $(id -u) \
        -v ${HOME}/.kube/:/home/ibp-user/.kube/ \
        -v ${CWDIR}/infrastructure/production_chaincode_playbooks:/playbooks \
        -v ${CWDIR}/_cfg:/_cfg \
        --network=host \
        ghcr.io/ibm-blockchain/ofs-ansibe:main \
            ansible-playbook /playbooks/20-install-and-approve-chaincode.yml 

    docker run \
        --rm \
        -u $(id -u) \
        -v ${HOME}/.kube/:/home/ibp-user/.kube/ \
        -v ${CWDIR}/infrastructure/production_chaincode_playbooks:/playbooks \
        -v ${CWDIR}/_cfg:/_cfg \
        --network=host \
        ghcr.io/ibm-blockchain/ofs-ansibe:main \
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
#         ghcr.io/ibm-blockchain/ofs-ansibe:main \
#             ansible-playbook /playbooks/22-register-application.yml           
