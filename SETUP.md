# Essential Setup

Remember to clone this repository!

```shell
git clone https://github.com/hyperledgendary/full-stack-asset-transfer-guide.git workshop
cd workshop
export WORKSHOP=$(pwd)
```

> to check the tools you already have  `./check.sh`


- Do you want to configure your local environment?
    - Do you want to develop an application and/or contract?
        - Yes; opt for the *DEV* tools listed below

    - Do you want to deploy a chaincode in a production manner?
        - Yes; opt for the *PROD* tools listed below

- Do you have Vagrant already installed?
    If you have Vagrant (with VirtualBox) you can use the Vagrant fabdev environment


    ```bash
    HLF_VERSION=2.4 vagrant up
    ```
- Do you have Multipass installed?
    <multipass >

- Would you like to use a dev-container?

Experimental: but there is a `dockerfile` in the `_bootstrap` directory; docker and just are required
(or if you don't have just, copy the docker run command from the justfile)

```
docker build -t fabgo .

# run this in several cli windows
just devshell
```

## DEV - Required Tools

You will need a set of tools to work with development along with an editor and the compiler of your choice.

- [docker engine](https://docs.docker.com/engine/install/)

- [just](https://github.com/casey/just#installation) to run all the commands here directly

- [weft ](https://www.npmjs.com/package/@hyperledger-labs/weft)  Hyperledger-Labs cli to work with identities and chaincode packages
```
npm install -g @hyperledger-labs/weft
```

- Fabric peer CLI
```
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
./install-fabric.sh binary

export PATH=$(pwd)/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/config
```

## PROD - Required Tools

- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [jq](https://stedolan.github.io/jq/)
- [just](https://github.com/casey/just#installation) to run all the comamnds here directly
- [kind](https://kind.sigs.k8s.io/) if you want to create a cluster locally, see below for other options
- [k9s](https://k9scli.io) (recommended, but not essential)
### Beta Ansible Playbooks

The v2.0.0-beta Ansible Collection for Hyperledger Fabric is required. This isn't yet being published.

```
git clone https://github.com/IBM-Blockchain/ansible-collection.git  
cd ansible-collection
docker build -t ofs-ansible .
```

Note to extract a PR
```
git fetch origin pull/615/head:latest
git checkout latest
```
