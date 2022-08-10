# Full stack with multipass and the Fabric Operator

This scenario sets up a KIND Kubenetes cluster on a multipass VM, using [fabric-operator](https://github.com/hyperledger-labs/fabric-operator)
to create a Fabric network by applying a series of peer, orderer, and CA CRDs to the k8s API controller.

Chaincode may be run on the host OS "as a service", or the image can be uploaded to a container registry and launched 
in the cluster using the [k8s chaincode builder](https://github.com/hyperledger-labs/fabric-builder-k8s).

Gateway applications run locally on the HOST OS, connecting to the Fabric network endpoints via Nginx ingress.

![Multipass VM with Fabric Operator](../images/multipass-operator-network.png)


## Prerequisites

- Fabric CLI binaries:
```shell
curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/bootstrap.sh | bash -s -- -s -d
export PATH=$PWD/bin:$PATH

```

- [Multipass #cloud-init](https://multipass.run/install)
```shell
brew install --cask multipass
```

- [jq](https://stedolan.github.io/jq/download/)


## Create a Multipass Virtual Machine

```shell
multipass launch \
  --name        fabric-dev \
  --disk        80G \
  --cpus        8 \
  --mem         8G \
  --cloud-init  infrastructure/multipass-cloud-config.yaml

multipass mount $PWD/config fabric-dev:/mnt/config

```

## Operator Sample Network 

- open MP shell:
```shell
multipass shell fabric-dev
sudo su - dev
```

- Create a KIND cluster and install the operator
```shell
git clone https://github.com/hyperledger-labs/fabric-operator.git
```

- Apply CRDs to the K8s API controller: 
```shell
cd ~/fabric-operator/sample-network 

export TEST_NETWORK_DOMAIN=$(hostname -I  | cut -d ' ' -f 1 | tr -s '.' '-').nip.io 
export TEST_NETWORK_INGRESS_DOMAIN=${TEST_NETWORK_DOMAIN}
export TEST_NETWORK_STAGE_DOCKER_IMAGES=true
export TEST_NETWORK_LOCAL_REGISTRY_INTERFACE=0.0.0.0
export TEST_NETWORK_PEER_IMAGE=ghcr.io/hyperledger-labs/k8s-fabric-peer
export TEST_NETWORK_PEER_IMAGE_LABEL=v0.7.2

time ./network kind 
time ./network cluster init
time ./network up
time ./network channel create 
 
# Copy the crypto material to the host OS via the multipass volume mount 
mkdir -p /mnt/config/build && cp -r temp/* /mnt/config/build

```

- Observe the target Kubernetes namespace
```shell
k9s -n test-network

```


### Install the Chaincode

After the network has been set up in the multipass VM, all interaction will occur via the Ingress on port :443.

To avoid the use of a public container registry, the multipass VM has been configured with an insecure Docker
registry at port :5000.  Before images can be uploaded to the cluster, the Docker engine must be configured with
the insecure registry URL and restarted.

E.g. on OSX / Docker Desktop, add the following stanza to the Docker -> Preferences -> Docker Engine config, using
the `$TEST_NETWORK_DOMAIN` as allocated to the multipass VM:
```json
{  
  "insecure-registries": [
    "192-168-205-6.nip.io:5000"
  ]
}
```

Open a new shell on the host OS:

```shell
export MULTIPASS_IP=$(multipass info fabric-dev --format json | jq -r .info.\"fabric-dev\".ipv4[0])
export TEST_NETWORK_DOMAIN=$(echo $MULTIPASS_IP | tr -s '.' '-').nip.io
export TEST_NETWORK_NS=test-network

echo "Connecting to Fabric domain $TEST_NETWORK_DOMAIN"

```

- Set the peer context for the Org1 administrator:
```shell
export FABRIC_CFG_PATH=$PWD/config
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_ADDRESS=${TEST_NETWORK_NS}-org1-peer1-peer.${TEST_NETWORK_DOMAIN}:443
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=$PWD/config/build/enrollments/org1/users/org1admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=$PWD/config/build/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem
export CORE_PEER_CLIENT_CONNTIMEOUT=10s
export CORE_PEER_DELIVERYTIMEOUT_CONNTIMEOUT=10s

export ORDERER_ENDPOINT=${TEST_NETWORK_NS}-org0-orderersnode1-orderer.${TEST_NETWORK_DOMAIN}:443
export ORDERER_TLS_CERT=${PWD}/config/build/channel-msp/ordererOrganizations/org0/orderers/org0-orderersnode1/tls/signcerts/tls-cert.pem
export CHANNEL_NAME=mychannel
```

- Build a docker image, upload to the docker registry, and prepare a k8s chaincode package:
```shell
export CHAINCODE_NAME=asset-tx-typescript
export CONTAINER_REGISTRY=$TEST_NETWORK_DOMAIN:5000
export CHAINCODE_IMAGE=$CONTAINER_REGISTRY/$CHAINCODE_NAME

docker build -t $CHAINCODE_IMAGE contracts/$CHAINCODE_NAME
docker push $CHAINCODE_IMAGE

IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' $CHAINCODE_IMAGE | cut -d'@' -f2)

infrastructure/pkgcc.sh -l $CHAINCODE_NAME -n localhost:5000/$CHAINCODE_NAME -d $IMAGE_DIGEST
 
```

- Install the contract to org1-peer1:
```shell
export VERSION=1
export SEQUENCE=1

```

```shell
peer lifecycle chaincode install ${CHAINCODE_NAME}.tgz 

export PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid ${CHAINCODE_NAME}.tgz) && echo $PACKAGE_ID

peer lifecycle \
	chaincode       approveformyorg \
	--channelID     ${CHANNEL_NAME} \
	--name          ${CHAINCODE_NAME} \
	--version       ${VERSION} \
	--package-id    ${PACKAGE_ID} \
	--sequence      ${SEQUENCE} \
	--orderer       ${ORDERER_ENDPOINT} \
	--tls --cafile  ${ORDERER_TLS_CERT} \
	--connTimeout   15s

peer lifecycle \
	chaincode       commit \
	--channelID     ${CHANNEL_NAME} \
	--name          ${CHAINCODE_NAME} \
	--version       ${VERSION} \
	--sequence      ${SEQUENCE} \
	--orderer       ${ORDERER_ENDPOINT} \
	--tls --cafile  ${ORDERER_TLS_CERT} \
	--connTimeout   15s

```

```shell
peer chaincode query -n $CHAINCODE_NAME -C mychannel -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}' | jq

```

## Gateway Application Development

### Register and enroll a new user at the org1 CA

```shell
USERNAME=org1user 
PASSWORD=org1userpw

fabric-ca-client  register \
  --id.name       ${USERNAME} \
  --id.secret     ${PASSWORD} \
  --id.type       client \
  --url           https://${TEST_NETWORK_NS}-org1-ca-ca.${TEST_NETWORK_DOMAIN} \
  --tls.certfiles $PWD/config/build/cas/org1-ca/tls-cert.pem \
  --mspdir        $PWD/config/build/enrollments/org1/users/rcaadmin/msp

fabric-ca-client enroll \
  --url           https://${USERNAME}:${PASSWORD}@${TEST_NETWORK_NS}-org1-ca-ca.${TEST_NETWORK_DOMAIN} \
  --tls.certfiles $PWD/config/build/cas/org1-ca/tls-cert.pem \
  --mspdir        $PWD/config/build/enrollments/org1/users/${USERNAME}/msp
  
export PEER_HOST_ALIAS=${TEST_NETWORK_NS}-org1-peer1-peer.${TEST_NETWORK_DOMAIN} 
export PEER_ENDPOINT=${TEST_NETWORK_NS}-org1-peer1-peer.${TEST_NETWORK_DOMAIN}:443

export KEY_DIRECTORY_PATH=$PWD/config/build/enrollments/org1/users/${USERNAME}/msp/keystore/
export CERT_PATH=$PWD/config/build/enrollments/org1/users/${USERNAME}/msp/signcerts/cert.pem
export TLS_CERT_PATH=$PWD/config/build/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem

```

### Go Bananas

```shell
pushd applications/trader-typescript 
npm install
```

```shell
npm start create banana bananaman yellow 

npm start getAllAssets

npm start transfer banana appleman Org1MSP 

npm start getAllAssets 

npm start transfer banana bananaman Org2MSP 

npm start transfer banana bananaman Org1MSP 

```

## Teardown

```shell
popd 
rm -rf config/build 

multipass delete fabric-dev 
multipass purge 


```