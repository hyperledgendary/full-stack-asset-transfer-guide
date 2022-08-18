# Chaincode

[PREV: Deploy a Fabric Network](20-fabric.md) <==> [NEXT: Go Bananas](40-bananas.md)

---

## Checks

```shell

just check-fabric

```


## Set the peer client environment

```shell

# org1-peer1: 
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_ADDRESS=${WORKSHOP_NAMESPACE}-org1-peer1-peer.${WORKSHOP_INGRESS_DOMAIN}:443
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=${WORKSHOP_CRYPTO}/enrollments/org1/users/org1admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${WORKSHOP_CRYPTO}/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem
export CORE_PEER_CLIENT_CONNTIMEOUT=10s
export CORE_PEER_DELIVERYTIMEOUT_CONNTIMEOUT=10s
export ORDERER_ENDPOINT=${WORKSHOP_NAMESPACE}-org0-orderersnode1-orderer.${WORKSHOP_INGRESS_DOMAIN}:443
export ORDERER_TLS_CERT=${WORKSHOP_CRYPTO}/channel-msp/ordererOrganizations/org0/orderers/org0-orderersnode1/tls/signcerts/tls-cert.pem

```

## Docker Engine Configuration

**NOTE: SKIP THIS STEP IF USING `localho.st` AS THE INGRESS DOMAIN** 

Configure the docker engine with the insecure container registry `${WORKSHOP_INGRESS_DOMAIN}:5000`

For example:  (Docker -> Preferences -> Docker Engine) 
```json
{
  "insecure-registries": [
    "192-168-205-6.nip.io:5000"
  ]
}
```

- apply and restart

## Chaincode Revision

```shell

CHANNEL_NAME=mychannel
VERSION=v0.0.1
SEQUENCE=1

```

## Build the Chaincode Docker Image

```shell

CHAINCODE_NAME=asset-transfer
CHAINCODE_PACKAGE=${CHAINCODE_NAME}.tgz
CONTAINER_REGISTRY=$WORKSHOP_INGRESS_DOMAIN:5000
CHAINCODE_IMAGE=$CONTAINER_REGISTRY/$CHAINCODE_NAME

# Build the chaincode image
docker build -t $CHAINCODE_IMAGE contracts/$CHAINCODE_NAME-typescript

# Push the image to the insecure container registry
docker push $CHAINCODE_IMAGE

```


## Prepare a k8s Chaincode Package

```shell

IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' $CHAINCODE_IMAGE | cut -d'@' -f2)

infrastructure/pkgcc.sh -l $CHAINCODE_NAME -n localhost:5000/$CHAINCODE_NAME -d $IMAGE_DIGEST

```

## Install the Chaincode

```shell

peer lifecycle chaincode install $CHAINCODE_PACKAGE

export PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid $CHAINCODE_PACKAGE) && echo $PACKAGE_ID

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


# Take it Further 

## Edit, compile, upload, and re-install your chaincode: 

```shell

SEQUENCE=$((SEQUENCE + 1))
VERSION=v0.0.$SEQUENCE

```

- Make a change to the contracts/asset-transfer-typescript source code 
- build a new chaincode docker image and publish to the local container registry  
- prepare a new chaincode package as above.
- install, approve, and commit as above.


## Install chaincode from a CI Pipeline

```shell

SEQUENCE=$((SEQUENCE + 1))
VERSION=v0.1.3
CHAINCODE_PACKAGE=asset-transfer-typescript-${VERSION}.tgz

```

- Download a chaincode release artifact from GitHub:
```shell

curl -LO https://github.com/hyperledgendary/full-stack-asset-transfer-guide/releases/download/${VERSION}/${CHAINCODE_PACKAGE}

```

- install, approve, and commit as above. 


## Debug with Chaincode as a Service 

- prepare a chaincode package with connection.json -> HOST IP:9999  (todo: link to dig out)
- compute CHAINCODE_ID=shasum CC package.tgz 
- docker run -e CHAINCODE_ID -e CHAINCODE_SERVER_ADDRESS ... $CHAINCODE_IMAGE in a different shell 
- install, approve, commit as above. 


## Deploy Chaincode With Ansible 

- cp tgz from github releases -> _cfg/
- edit _cfg/cc yaml with package name 
- `just ... chaincode`  


---

[PREV: Deploy a Fabric Network](20-fabric.md) <==> [NEXT: Go Bananas](40-bananas.md)
