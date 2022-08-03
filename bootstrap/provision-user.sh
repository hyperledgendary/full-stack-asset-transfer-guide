#!/usr/bin/env bash
s
set -o errexit
set -o pipefail

NODE_VERSION=14.18.0

# Install NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] || curl --fail --silent --show-error -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.3/install.sh | bash
. "$NVM_DIR/nvm.sh"

# Install node and npm
nvm which ${NODE_VERSION} >/dev/null 2>&1 || nvm install ${NODE_VERSION}

nvm use ${NODE_VERSION}
nvm alias default ${NODE_VERSION}
echo "default" > $HOME/.nvmrc

set -x
curl -sSL https://raw.githubusercontent.com/hyperledger-labs/weft/main/install.sh | bash  && true

# curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh -o ./install-fabric.sh \
#     && chmod +x install-fabric.sh \
#     && ./install-fabric.sh binary
