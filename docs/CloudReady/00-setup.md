# Setup

==> [NEXT: Select a Kube](./10-kube.md)

---

## Design the assets and contracts


- [jq](https://stedolan.github.io/jq/download/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Fabric CLI binaries:
```shell
curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/bootstrap.sh | bash -s -- -s -d
export PATH=$PWD/bin:$PATH

```

```shell
./cloud-check.sh
```

todo: test for kubectl >= 1.24.  There are issues for older revs. 

