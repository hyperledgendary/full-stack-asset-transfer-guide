# Essential Setup

You can use your local environment, or create a VM to work in 
(cite the dev environment here... )
## Clone this repository

Remeber to clone this repository!

```shell
git clone https://github.com/hyperledgendary/full-stack-asset-transfer-guide.git  fabric-workshop
```

## Required Tools

If you don't have these already, please install these first.

- [docker engine](https://docs.docker.com/engine/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [jq](https://stedolan.github.io/jq/)
- [just](https://github.com/casey/just#installation) to run all the comamnds here directly
- [kind](https://kind.sigs.k8s.io/) if you want to create a cluster locally, see below for other options
- [k9s](https://k9scli.io) (recommended, but not essential)


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

