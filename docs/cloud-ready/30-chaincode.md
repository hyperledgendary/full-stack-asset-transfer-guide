# Chaincode 

## Prerequisites 

- docker
- `TEST_NETWORK_INGRESS_DOMAIN` 
- operator sample network
- `mychannel`


## Docker Engine Configuration 

Configure the docker engine with the insecure container registry: 

```json
{  
  "insecure-registries": [
    "192-168-205-6.nip.io:5000"
  ]
}
```


## Prepare the Chaincode Image 

```shell
export CHAINCODE_NAME=asset-tx-typescript
export CHANNEL_NAME=mychannel 
export CONTAINER_REGISTRY=$TEST_NETWORK_INGRESS_DOMAIN:5000
export CHAINCODE_IMAGE=$CONTAINER_REGISTRY/$CHAINCODE_NAME

# Build the chaincode image 
docker build -t $CHAINCODE_IMAGE contracts/$CHAINCODE_NAME

# Push the image to the insecure container registry 
docker push $CHAINCODE_IMAGE

```


## Prepare a Chaincode Package 

```shell
IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' $CHAINCODE_IMAGE | cut -d'@' -f2)

infrastructure/pkgcc.sh -l $CHAINCODE_NAME -n localhost:5000/$CHAINCODE_NAME -d $IMAGE_DIGEST

```

## Install the Chaincode 

```shell
# Set the org1-peer1 CLI context: 
export FABRIC_CFG_PATH=$PWD/config
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_ADDRESS=test-network-org1-peer1-peer.${TEST_NETWORK_INGRESS_DOMAIN}:443
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=$PWD/config/build/enrollments/org1/users/org1admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=$PWD/config/build/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem
export CORE_PEER_CLIENT_CONNTIMEOUT=10s
export CORE_PEER_DELIVERYTIMEOUT_CONNTIMEOUT=10s
export ORDERER_ENDPOINT=test-network-org0-orderersnode1-orderer.${TEST_NETWORK_INGRESS_DOMAIN}:443
export ORDERER_TLS_CERT=${PWD}/config/build/channel-msp/ordererOrganizations/org0/orderers/org0-orderersnode1/tls/signcerts/tls-cert.pem

```

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

### Guide

Prev : [Deploy a Fabric Network](20-fabric.md)

Next : [Go Bananas](40-bananas.md)