#!/usr/bin/env bash

SUCCESS="✅"
WARN="⚠️"

if ! command -v docker &> /dev/null
then
    echo "${WARN} Please install Docker; suggested install commands:"
else  
    echo "${SUCCESS} Docker found"
fi

if ! command -v kubectl &> /dev/null
then
    echo "${WARN} Please install kubectl if you want to use k8s; suggested install commands:"
else  
    echo "${SUCCESS} kubectl found"
fi

# Install kind
KIND_VERSION=0.14.0
if ! command -v kind &> /dev/null
then
  echo "${WARN} Please install kind; suggested install commands:"
  echo "sudo curl --fail --silent --show-error -L https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64 -o /usr/local/bin/kind"
  echo "sudo chmod 755 /usr/local/bin/kind"
  echo
else  
    echo "${SUCCESS} kind found"  
fi

# Install k9s
K9S_VERSION=0.25.3
if ! command -v k9s &> /dev/null
then
  echo "${WARN} Please install k9s; suggested install commands:"
  echo "curl --fail --silent --show-error -L https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz -o /tmp/k9s_Linux_x86_64.tar.gz"
  echo "tar -zxf /tmp/k9s_Linux_x86_64.tar.gz -C /usr/local/bin k9s"
  echo "sudo chown root:root /usr/local/bin/k9s"
  echo "sudo chmod 755 /usr/local/bin/k9s"
  echo
else 
  echo "${SUCCESS} k9s found"
fi

# Install just
JUST_VERSION=1.2.0
if [ ! -x "/usr/local/bin/just" ]; then
  echo "${WARN} Please install just; suggested install commands:"
  echo "curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --tag ${JUST_VERSION} --to /usr/local/bin"
else 
  echo "${SUCCESS} Just found"
fi

if ! command -v peer &> /dev/null
then
  echo "${WARN} Please install the peer; suggested install commands:"
  echo "curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh | bash -s -- binary"
  echo 'export PATH=$(pwd)/bin:$PATH'
  echo 'export FABRIC_CFG_PATH=$(pwd)/config'
else 
  echo "${SUCCESS} peer found"
fi
 
if [[ ! -z "${FABRIC_CFG_PATH}" && -d "${FABRIC_CFG_PATH}" ]]; then
  echo "${SUCCESS} FABRIC_CFG_PATH set" 
else
  echo "${WARN}  FABRIC_CFG_PATH must be set"
fi