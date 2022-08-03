#!/usr/bin/env bash

set -o errexit
set -o pipefail

if [ -z $1 ]; then
  HLF_VERSION=2.4.4
else
  HLF_VERSION=$1
fi

THIRDPARTY_IMAGE_VERSION=0.4.15

if [ ${HLF_VERSION:0:4} = '2.3.' -o ${HLF_VERSION:0:4} = '2.4.' ]; then
  CA_VERSION=1.5.2
  SAMPLE_BRANCH=main
  NODE_VERSION=14.18.0
elif [ ${HLF_VERSION:0:4} = '2.0.' -o ${HLF_VERSION:0:4} = '2.1.' -o ${HLF_VERSION:0:4} = '2.2.' ]; then
  CA_VERSION=1.5.2
  SAMPLE_BRANCH=v${HLF_VERSION}
  NODE_VERSION=12.14.0
else
  CA_VERSION=$HLF_VERSION
  SAMPLE_BRANCH=v${HLF_VERSION}
  NODE_VERSION=8.9.0
fi

# Install NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] || curl --fail --silent --show-error -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.3/install.sh | bash
. "$NVM_DIR/nvm.sh"

# Install node and npm
nvm which ${NODE_VERSION} >/dev/null 2>&1 || nvm install ${NODE_VERSION}

nvm use ${NODE_VERSION}
nvm alias default ${NODE_VERSION}
echo "default" > $HOME/.nvmrc

curl -sSL https://raw.githubusercontent.com/hyperledger-labs/weft/main/install.sh | bash
