# Deploy a Fabric Network 

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)

---

## Checks 

- todo: write a check.sh for each exercise 
```shell
   [[ -d ${WORKSHOP_PATH} ]] || echo stop1 \
&& [[ -v WORKSHOP_IP      ]] || echo stop2 \

```


## Operator Sample Network 

- Open a new shell and connect to the VM
```shell
# todo: ssh authorized_keys -> ubuntu@${WORKSHOP_IP}
multipass shell fabric-dev 

```

- Install the fabric-operator [Kubernetes Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
```shell
kubectl apply -k https://github.com/hyperledger-labs/fabric-operator.git/config/crd

```

```shell
git clone https://github.com/hyperledger-labs/fabric-operator.git
cd ~/fabric-operator/sample-network

export TEST_NETWORK_INGRESS_DOMAIN=$(hostname -I | cut -d ' ' -f 1 | tr -s '.' '-').nip.io
export TEST_NETWORK_PEER_IMAGE=ghcr.io/hyperledger-labs/k8s-fabric-peer
export TEST_NETWORK_PEER_IMAGE_LABEL=v0.7.2

```

- Apply a series of CA, peer, and orderer resources to the Kube API controller
```shell
./network up

```

- Create `mychannel`
```shell
./network channel create 

```

- Extract the network crypto material
```shell
# todo: ssh + tar.  Do NOT use a volume share to the host OS. 

# Delete the crypto material from any previous run 
rm -rf ~/full-stack-asset-transfer-guide/config/build

# Copy the crypto material for the newly created network to the host volume share  
mkdir -p ~/full-stack-asset-transfer-guide/config/build 
cp -r temp/* ~/full-stack-asset-transfer-guide/config/build/

```

- Exit the multipass shell.  All further interaction with the network will be run from the host OS. 


## Configure the Fabric Ingress Domain

```shell
WORKSHOP_NAMESPACE=test-network
WORKSHOP_CRYPTO=$WORKSHOP_PATH/config/build 
WORKSHOP_DOMAIN=$(echo $WORKSHOP_IP | tr -s '.' '-').nip.io && echo $WORKSHOP_DOMAIN

```


## Post Checks 

```shell
curl --cacert $WORKSHOP_CRYPTO/cas/org1-ca/tls-cert.pem https://${WORKSHOP_NAMESPACE}-org1-ca-ca.$WORKSHOP_DOMAIN/cainfo

```


# Take it Further:  

### Build a network with Ansible
- just operator 
- just console 
- just sample-network 

### Build a network with the Fabric Operations Console

- just operator 
- just console 
- open https://fabricinfra-hlf-console-console.$TEST_NETWORK_INGRESS_DOMAIN/    ( admin/password )  

---

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)


