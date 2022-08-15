# Deploy a Fabric Network 

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)

---

## Ready?

- todo: write a check.sh for each exercise 
```shell
   [[ -d ${WORKSHOP_PATH}         ]] || echo stop1 \
&& [[ -v WORKSHOP_INGRESS_DOMAIN  ]] || echo stop2 \
&& [[ -v WORKSHOP_NAMESPACE       ]] || echo stop3 \

```

## Operator Sample Network 

- Install the fabric-operator [Kubernetes Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
```shell

kubectl apply -k https://github.com/hyperledger-labs/fabric-operator.git/config/crd

```

- todo: don't clone fabric-operator to set up a network.  just use just targets in this project
```shell
pushd /tmp 
git clone https://github.com/hyperledger-labs/fabric-operator.git
cd fabric-operator/sample-network

export TEST_NETWORK_PEER_IMAGE=ghcr.io/hyperledger-labs/k8s-fabric-peer
export TEST_NETWORK_PEER_IMAGE_LABEL=v0.7.2
export TEST_NETWORK_INGRESS_DOMAIN=$WORKSHOP_INGRESS_DOMAIN
export TEST_NETWORK_NS=$WORKSHOP_NAMESPACE

```

- Apply a series of CA, peer, and orderer resources to the Kube API controller
```shell

./network down   # todo - just sample-network will need to scrub crypto material from a previous network 
./network up
./network channel create

```

- Copy the network crypto material to the asset transfer guide config folder: 
```shell

export WORKSHOP_CRYPTO=$WORKSHOP_PATH/_cfg/sample-network

rm -rf $WORKSHOP_PATH/_cfg/sample-network
mkdir -p $WORKSHOP_CRYPTO
cp -r temp/* $WORKSHOP_CRYPTO

popd

```


## Post Checks 

```shell

curl \
  -s \
  --cacert $WORKSHOP_CRYPTO/cas/org1-ca/tls-cert.pem \
  https://${WORKSHOP_NAMESPACE}-org1-ca-ca.$WORKSHOP_INGRESS_DOMAIN/cainfo \
  | jq

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


