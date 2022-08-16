# Cloud Ready Setup

==> [NEXT: Deploy a Kube](./10-kube.md)

---

## Prerequisites 

- [docker](https://www.docker.com/get-started/)

- [kubectl](https://kubernetes.io/docs/tasks/tools/)

- [jq](https://stedolan.github.io/jq/download/)

- [k9s](https://k9scli.io/topics/install/) (recommended)

- [full-stack-asset-transfer-guide](https://github.com/hyperledgendary/full-stack-asset-transfer-guide) (this project):
```shell

git clone https://github.com/hyperledgendary/full-stack-asset-transfer-guide.git
cd full-stack-asset-transfer-guide

```

- Hyperledger Fabric [client binaries](https://hyperledger-fabric.readthedocs.io/en/latest/install.html#download-fabric-samples-docker-images-and-binaries):
```shell

curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh | bash -s -- binary

```

- Workshop environment:

```shell

export WORKSHOP_PATH=$(pwd)
export FABRIC_CFG_PATH=${WORKSHOP_PATH}/config  
export PATH=${WORKSHOP_PATH}/bin:$PATH

```


### Ready?

```shell

./check.sh

```


--- 

==> [NEXT: Deploy a Kube](./10-kube.md)
