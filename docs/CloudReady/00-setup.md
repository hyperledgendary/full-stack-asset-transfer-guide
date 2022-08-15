# Cloud Ready Setup

==> [NEXT: Deploy a Kube](./10-kube.md)

---

## Prerequisites 

- [jq](https://stedolan.github.io/jq/download/)

- This project: 
```shell
git clone https://github.com/hyperledgendary/full-stack-asset-transfer-guide.git
cd full-stack-asset-transfer-guide

export WORKSHOP_PATH=$(pwd)

```

- Fabric CLI binaries:
```shell
curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh | bash -s -- binary

export FABRIC_CFG_PATH=$WORKSHOP_PATH/config  
export PATH=$PWD/bin:$PATH

```

- todo: test for kubectl >= 1.24.  There are issues for older revs.


### Ready?

```shell

just check

```


--- 

==> [NEXT: Deploy a Kube](./10-kube.md)
