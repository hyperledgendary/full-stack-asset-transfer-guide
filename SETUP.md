# Essential Setup

Remeber to clone this repository!

```shell
git clone https://github.com/hyperledgendary/full-stack-asset-transfer-guide.git  fabric-workshop
```


You can use your local environment with the tools listed below or use a virtual environment.

If you have Vagrant (with VirtualBox) you can use the Vagrant fabdev environment
```bash
HLF_VERSION=2.4 vagrant up
```

Experimental: but there is a `dockerfile` in the `_bootstrap` directory; docker and just are required
(or if you don't have just, copy the docker run command from justfile.dev)

```
docker build -t fabgo .

# run this in several cli windows
just -f justfile.dev devshell
```


## Required Tools

If you don't have these already, please install these first.

- [docker engine](https://docs.docker.com/engine/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [jq](https://stedolan.github.io/jq/)
- [just](https://github.com/casey/just#installation) to run all the comamnds here directly
- [kind](https://kind.sigs.k8s.io/) if you want to create a cluster locally, see below for other options
- [k9s](https://k9scli.io) (recommended, but not essential)

## Development tools

You will need a set of tools to work with development along with an editor and the compiler of your choice
- weft
```
npm install -g @hyperledger-labs/weft

# or if you don't want to authenticate to github packages

curl -sSL https://raw.githubusercontent.com/hyperledger-labs/weft/main/install.sh | sh
```

- peer cli
```
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
./install-fabric.sh binary

export PATH=$(pwd)/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/config
```

## Beta Ansible Playbooks

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

