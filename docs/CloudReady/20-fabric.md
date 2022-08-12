# Deploy a Fabric Network 

[PREV: Select a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)

---


## Pre Checks 

- TEST_NETWORK_INGRESS_DOMAIN is set 

## Operator Sample Network 

- Open a shell on the multipass VM 
```shell
# todo: ssh 
multipass shell fabric-dev 

```

```shell
git clone https://github.com/hyperledger-labs/fabric-operator.git
cd ~/fabric-operator/sample-network

export INSTANCE_IP=$(hostname -I | cut -d ' ' -f 1)
export TEST_NETWORK_INGRESS_DOMAIN=$(echo $INSTANCE_IP | tr -s '.' '-').nip.io
export TEST_NETWORK_PEER_IMAGE=ghcr.io/hyperledger-labs/k8s-fabric-peer
export TEST_NETWORK_PEER_IMAGE_LABEL=v0.7.2

```

- Apply a series of CA, peer, and orderer CRDs to fabric-operator 
```shell
./network up

```

- Create `mychannel`
```shell
./network channel create 

```

- Copy the crypto material from the sample network to the host OS
```shell
rm -rf ~/full-stack-asset-transfer-guide/config/build 
mkdir -p ~/full-stack-asset-transfer-guide/config/build 
cp -r temp/* ~/full-stack-asset-transfer-guide/config/build/

```

- Exit the multipass shell.


## Post Checks 

```shell
curl --cacert config/build/cas/org1-ca/tls-cert.pem https://test-network-org1-ca-ca.$TEST_NETWORK_INGRESS_DOMAIN/cainfo
```


## Take it Further:  

### Build a network with Ansible
  - just operator 
  - just console 
  - just sample-network 

### Build a network with the Fabric Operations Console

- just operator 
- just console 
- open https://fabricinfra-hlf-console-console.$TEST_NETWORK_INGRESS_DOMAIN/    ( admin/password )  

