# Full stack with multipass and the Kubernetes Test Network 

## Multipass VM 

- scrub everything Fabric / k8s related on host os. 
- stop docker desktop 

- install multipass 
```shell
brew install --cask multipass
```

- create vm : 
```shell
multipass       launch \
  --name        fabric-dev \
  --disk        80G \
  --cpus        8 \
  --mem         8G \
  --cloud-init  infrastructure/multipass-cloud-config.yaml
```

- Open mp shell #1: 
```shell
multipass shell fabric-dev
```

```shell
sudo su - dev 
```

## Git stuff 

```shell
# until PR #809 lands: 
# git clone https://github.com/hyperledger/fabric-samples.git
git clone https://github.com/jkneubuh/fabric-samples.git -b feature/enroll-rcaadmin 

git clone https://github.com/hyperledgendary/full-stack-asset-transfer-guide.git
```

## Test network 

```shell
cd ~/fabric-samples/test-network-k8s

export PATH=$PWD:$PWD/bin:$PATH
export SAMPLE_NETWORK_DIR=$PWD 
export TEST_NETWORK_STAGE_DOCKER_IMAGES="false"
export TEST_NETWORK_K8S_CHAINCODE_BUILDER_VERSION="v0.6.0"
export TEST_NETWORK_CHAINCODE_BUILDER="k8s"
export TEST_NETWORK_DOMAIN=$(hostname -I  | cut -d ' ' -f 1 | tr -s '.' '-').nip.io 
```

```shell
network kind 
network cluster init 
network up
network channel create 
```

## Install asset-tx chaincode

```shell
cd ~/full-stack-asset-transfer-guide/contracts/asset-tx-typescript

export CHAINCODE_NAME=$(basename $PWD)
export NS=test-network
#export TEST_NETWORK_DOMAIN=vcap.me
export FABRIC_CFG_PATH=${SAMPLE_NETWORK_DIR}/config/org1
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_ADDRESS=org1-peer1.${TEST_NETWORK_DOMAIN}:443
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=${SAMPLE_NETWORK_DIR}/build/enrollments/org1/users/org1admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${SAMPLE_NETWORK_DIR}/build/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem
```

Build a docker image, upload to a repo, and construct a cc package
```shell
docker build -t localhost:5000/${CHAINCODE_NAME} .
docker push localhost:5000/${CHAINCODE_NAME} 

IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' localhost:5000/${CHAINCODE_NAME} | cut -d'@' -f2)

../../infrastructure/pkgcc.sh -l ${CHAINCODE_NAME} -n localhost:5000/${CHAINCODE_NAME} -d ${IMAGE_DIGEST} 
```

install the chaincode
```shell
export VERSION=1
export SEQUENCE=1
```

```shell
peer lifecycle chaincode install ${CHAINCODE_NAME}.tgz 

export PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid ${CHAINCODE_NAME}.tgz) && echo $PACKAGE_ID

peer lifecycle \
	chaincode approveformyorg \
	--channelID     mychannel \
	--name          ${CHAINCODE_NAME} \
	--version       ${VERSION} \
	--package-id    ${PACKAGE_ID} \
	--sequence      ${SEQUENCE} \
	--orderer       org0-orderer1.${TEST_NETWORK_DOMAIN}:443 \
	--tls --cafile  ${SAMPLE_NETWORK_DIR}/build/channel-msp/ordererOrganizations/org0/orderers/org0-orderer1/tls/signcerts/tls-cert.pem \
	--connTimeout   15s

peer lifecycle \
	chaincode commit \
	--channelID     mychannel \
	--name          ${CHAINCODE_NAME} \
	--version       ${VERSION} \
	--sequence      ${SEQUENCE} \
	--orderer       org0-orderer1.${TEST_NETWORK_DOMAIN}:443 \
	--tls --cafile  ${SAMPLE_NETWORK_DIR}/build/channel-msp/ordererOrganizations/org0/orderers/org0-orderer1/tls/signcerts/tls-cert.pem \
	--connTimeout   15s



```

```shell
peer chaincode query -n $CHAINCODE_NAME -C mychannel -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}' | jq

```


## Gateway Client Application:

### Client Certificates 

TODO:  Run an org client registration in the cluster, and enroll from the HOST OS to download certificates locally.

(in multipass shell)
```shell
cd ~/

cat fabric-samples/test-network-k8s/build/enrollments/org1/users/org1admin/msp/keystore/key.pem 

cat fabric-samples/test-network-k8s/build/enrollments/org1/users/org1admin/msp/signcerts/cert.pem 

cat fabric-samples/test-network-k8s/build/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem 
```

Write the above content to a local `keystore/key.pem`, `signcerts/cert.pem`, and `tlscacerts/tlsca-signcert.pem`.

```shell
cd applications/trader-typescript

export CHAINCODE_NAME=asset-tx-typescript

export KEY_DIRECTORY_PATH=/tmp/keystore
export CERT_PATH=/tmp/signcerts/cert.pem
export TLS_CERT_PATH=/tmp/tlscacerts/tlsca-signcert.pem
export PEER_HOST_ALIAS=org1-peer1.192-168-205-6.nip.io
export PEER_ENDPOINT=org1-peer1.192-168-205-6.nip.io:443
```
