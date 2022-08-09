#!/usr/bin/env bash


if ! command -v docker &> /dev/null
then
    echo " :-/ Please install Docker"
else  
    echo " :-) Docker found"
fi

if ! command -v kubectl &> /dev/null
then
    echo " :-/ Please install kubectl if you want to use k8s"
else  
    echo " :-) kubectl found"
fi

# Install kind
KIND_VERSION=0.14.0
if ! command -v kind &> /dev/null
then
  echo " :-/ Please install kind"
  echo "sudo curl --fail --silent --show-error -L https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64 -o /usr/local/bin/kind"
  echo "sudo chmod 755 /usr/local/bin/kind"
  echo
else  
    echo " :-) kind found"  
fi

# Install k9s
K9S_VERSION=0.25.3
if ! command -v k9s &> /dev/null
then
  echo " :-/ Please install k9s"
  echo "curl --fail --silent --show-error -L https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz -o /tmp/k9s_Linux_x86_64.tar.gz"
  echo "tar -zxf /tmp/k9s_Linux_x86_64.tar.gz -C /usr/local/bin k9s"
  echo "sudo chown root:root /usr/local/bin/k9s"
  echo "sudo chmod 755 /usr/local/bin/k9s"
  echo
else 
  echo " :-) k9s found"
fi

# Install just
JUST_VERSION=1.2.0
if [ ! -x "/usr/local/bin/just" ]; then
  echo " :-/ Please install just"
  echo "curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --tag ${JUST_VERSION} --to /usr/local/bin"
else 
  echo " :-) Just found"
fi

if ! command -v peer
then
  echo " :-/ Please install the peer"
  echo "curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh | bash -s -- binary"
  echo 'export PATH=$(pwd)/bin:$PATH'
  echo 'export FABRIC_CFG_PATH=$(pwd)/config'
else 
  echo " :-) peer found"
fi
 
