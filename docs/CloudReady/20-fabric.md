# Deploy a Fabric Network 

[PREV: Select a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)

---


todo: break this into two sections / guides:
- kustomization / k8s API controller
- ansible + console playbooks



## Pre Checks 

- TEST_NETWORK_INGRESS_DOMAIN is set 



## Operator Sample Network 

- git clone fabric-operator and : 

```shell
cd fabric-operator/sample-network

export TEST_NETWORK_PEER_IMAGE=ghcr.io/hyperledger-labs/k8s-fabric-peer
export TEST_NETWORK_PEER_IMAGE_LABEL=v0.7.2

./network up
./network channel create 
```


## Post Checks 

```shell
curl --cacert temp/cas/org1-ca/tls-cert.pem https://test-network-org1-ca-ca.$TEST_NETWORK_INGRESS_DOMAIN/cainfo
```

todo: explicit test for crypto material in the full-stack-asset-transfer-guide/config/build folder 


