# Essential Setup

Remember to clone this repository!

```shell
git clone https://github.com/hyperledgendary/full-stack-asset-transfer-guide.git workshop
cd workshop
export WORKSHOP_PATH=$(pwd)
```

> to check the tools you already have  `./check.sh`

## Option 1: Use local environment

Do you want to configure your local environment with the workshop dependencies?

- To develop an application and/or contract (first two parts of workshop) follow the *DEV* setup below

- To deploy a chaincode to kubernetes in a production manner (third part of workshop) follow the *PROD* setup below

## Option 2: Use a Multipass Ubuntu image

If you do not want to install dependencies on your local environment, you can use a Multipass Ubuntu image instead.

- [Install multipass](https://multipass.run/install)

- Launch the virtual machine and automatically install the workshop dependencies:

```shell
multipass launch \
  --name        fabric-dev \
  --disk        80G \
  --cpus        8 \
  --mem         8G \
  --cloud-init  infrastructure/multipass-cloud-config.yaml
```

- Mount the local workshop to your multipass vm:

```shell
multipass mount $PWD fabric-dev:/home/ubuntu/full-stack-asset-transfer-guide
```

- Open a shell on the virtual machine:

```shell
multipass shell fabric-dev
```

- You are now inside the virtual machine. cd to the workshop directory:

```shell
cd full-stack-asset-transfer-guide
```

- Install Fabric peer CLI and set environment variables
```shell
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
./install-fabric.sh binary
export WORKSHOP_PATH=$(pwd)
export PATH=${WORKSHOP_PATH}/bin:$PATH
export FABRIC_CFG_PATH=${WORKSHOP_PATH}/config
```

## Option 3: Use a docker container

Experimental: but there is a `dockerfile` in the `_bootstrap` directory; docker and just are required
(or if you don't have just, copy the docker run command from the justfile)

```shell
docker build -t fabgo .

# run this in several cli windows
just devshell
```

## DEV - Required Tools

You will need a set of tools to assist with chaincode and application development.
We'll assume you are developing in Node for this workshop, but you could also develop in Java or Go by installing the respective compilers.

- [docker engine](https://docs.docker.com/engine/install/)

- [just](https://github.com/casey/just#installation) to run all the commands here directly

- [nvm](https://github.com/nvm-sh/nvm#installing-and-updating) to install node and npm
```shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```

- [node v16 and npm](https://github.com/nvm-sh/nvm#usage) to run node chaincode and applications
```shell
nvm install 16
```

- [typescript](https://www.typescriptlang.org/download) to compile typescript chaincode and applications to node
```shell
npm install -g typescript
```

- [weft ](https://www.npmjs.com/package/@hyperledger-labs/weft) Hyperledger-Labs cli to work with identities and chaincode packages
```shell
npm install -g @hyperledger-labs/weft
```

- Fabric peer CLI
```shell
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
./install-fabric.sh binary
export WORKSHOP_PATH=$(pwd)
export PATH=${WORKSHOP_PATH}/bin:$PATH
export FABRIC_CFG_PATH=${WORKSHOP_PATH}/config
```

## PROD - Required Tools for Kubernetes Deployment

- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [jq](https://stedolan.github.io/jq/)
- [just](https://github.com/casey/just#installation) to run all the comamnds here directly
- [kind](https://kind.sigs.k8s.io/) if you want to create a cluster locally, see below for other options
- [k9s](https://k9scli.io) (recommended, but not essential)

### Beta Ansible Playbooks

The v2.0.0-beta Ansible Collection for Hyperledger Fabric is required for Kubernetes deployment. This isn't yet being published.

```shell
git clone https://github.com/IBM-Blockchain/ansible-collection.git  
cd ansible-collection
docker build -t ofs-ansible .
```

Note to extract a PR
```shell
git fetch origin pull/615/head:latest
git checkout latest
```
