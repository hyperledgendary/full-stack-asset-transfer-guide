# Apache-2.0

# Main justfile to run all the scripts
#
# To install 'just' see https://github.com/casey/just#installation


# Ensure all properties are exported as shell env-vars
set export

# set the current directory, and the location of the test dats
CWDIR := justfile_directory()

_default:
  @just --list

bootstrap:
    #!/bin/bash
    

# Starts and configures a local KIND cluster
cluster:
    #!/bin/bash
    set -ex -o pipefail
    pushd  ./fabric/operator-network/sample-network
    ./network kind
    ./network cluster init
    popd

# Installs and configures a sample Fabric Network
network:
    #!/bin/bash
    set -ex -o pipefail

    docker run --rm -u $(id -u) -v ${HOME}/.kube/:/home/ibp-user/.kube/ -v ${CWDIR}/infrastructure/fabric_network_playbooks:/playbooks -v ${CWDIR}/_cfg:/_cfg --network=host ofs-ansible:latest ansible-playbook /playbooks/00-complete.yml        


# Install the operations console
console: operator
    #!/bin/bash
    set -ex -o pipefail

    docker run --rm -v ${HOME}/.kube/:/home/ibp-user/.kube/ -v $(pwd)/infrastructure/operator_console_playbooks:/playbooks --network=host ofs-ansible:latest ansible-playbook /playbooks/01-operator-install.yml    
    docker run --rm -v ${HOME}/.kube/:/home/ibp-user/.kube/ -v $(pwd)/infrastructure/operator_console_playbooks:/playbooks --network=host ofs-ansible:latest ansible-playbook /playbooks/02-console-install.yml

    AUTH=$(curl -X POST https://fabricinfra-hlf-console-console.localho.st:443/ak/api/v2/permissions/keys -u admin:password -k -H 'Content-Type: application/json' -d '{"roles": ["writer", "manager"],"description": "newkey"}')
    KEY=$(echo $AUTH | jq .api_key | tr -d '"')
    SECRET=$(echo $AUTH | jq .api_secret | tr -d '"')

    echo "Writing authentication file for Ansible based IBP (Software) network building"
    cat << EOF > $CWDIR/_cfg/auth-vars.yml
    api_key: $KEY
    api_endpoint: http://fabricinfra-hlf-console-console.localho.st/
    api_authtype: basic
    api_secret: $SECRET
    EOF
    cat ${CWDIR}/_cfg/auth-vars.yml

# Installs just the operator
operator:
    #!/bin/bash
    pushd  ./fabric/operator-network/sample-network
    ./network operator
    popd

# Removes the local cluster
unkind:
    pushd  ./fabric/operator-network/sample-network
    ./network unkind
    popd
