#!/usr/bin/env bash

SUCCESS="✅"
WARN="⚠️ "
EXIT=0

if ! command -v docker &> /tmp/cmdpath
then
    echo "${WARN} Please install Docker; suggested install commands:"
    EXIT=1
else
    echo -e "${SUCCESS} Docker found:\t$(cat /tmp/cmdpath)"
fi

if ! command -v kubectl &> /tmp/cmdpath
then
    echo "${WARN} Please install kubectl if you want to use k8s; suggested install commands:"
    EXIT=1
else
    echo -e "${SUCCESS} kubectl found:\t$(cat /tmp/cmdpath)"
fi

# Install kind
KIND_VERSION=0.14.0
if ! command -v kind &> /tmp/cmdpath
then
  echo "${WARN} Please install kind; suggested install commands:"
  echo "sudo curl --fail --silent --show-error -L https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64 -o /usr/local/bin/kind"
  echo "sudo chmod 755 /usr/local/bin/kind"
  echo
  EXIT=1
else
    echo -e "${SUCCESS} kind found:\t\t$(cat /tmp/cmdpath)"
fi

# Install k9s
K9S_VERSION=0.25.3
if ! command -v k9s &> /tmp/cmdpath
then
  echo "${WARN} Please install k9s; suggested install commands:"
  echo "curl --fail --silent --show-error -L https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz -o /tmp/k9s_Linux_x86_64.tar.gz"
  echo "tar -zxf /tmp/k9s_Linux_x86_64.tar.gz -C /usr/local/bin k9s"
  echo "sudo chown root:root /usr/local/bin/k9s"
  echo "sudo chmod 755 /usr/local/bin/k9s"
  echo
  EXIT=1
else
  echo -e "${SUCCESS} k9s found:\t\t$(cat /tmp/cmdpath)"
fi

# Install just
JUST_VERSION=1.2.0
if ! command -v just &> /tmp/cmdpath
then
  echo "${WARN} Please install just; suggested install commands:"
  echo "curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --tag ${JUST_VERSION} --to /usr/local/bin"
  EXIT=1
else
  echo -e "${SUCCESS} Just found:\t\t$(cat /tmp/cmdpath)"
fi

# Install weft
if ! command -v weft &> /tmp/cmdpath
then
  echo "${WARN} Please install weft; suggested install commands:"
  echo "npm install -g @hyperledger-labs/weft"
  EXIT=1
else 
  echo -e "${SUCCESS} weft found:\t\t$(cat /tmp/cmdpath)"
fi



if ! command -v peer &> /tmp/cmdpath
then
  echo "${WARN} Please install the peer; suggested install commands:"
  echo "curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh | bash -s -- binary"
  echo 'export PATH=$(pwd)/bin:$PATH'
  echo 'export FABRIC_CFG_PATH=$(pwd)/config'
  EXIT=1
else
  echo -e "${SUCCESS} peer found:\t\t$(cat /tmp/cmdpath)"
fi

# tests if varname is defined in the env AND it's an existing directory
function must_declare() {
  local varname=$1

  if [[ ! -d ${!varname} ]]; then
    echo "${WARN} ${varname} must be set to a directory"
    EXIT=1

  else
    echo -e "${SUCCESS} ${varname}:\t${!varname}"
  fi
}

must_declare "FABRIC_CFG_PATH"
must_declare "WORKSHOP_PATH"

rm /tmp/cmdpath &> /dev/null

exit $EXIT
