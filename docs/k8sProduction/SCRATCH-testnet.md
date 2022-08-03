# Scratch notes for running the full stack app on kube test network and KIND 

## Set up the network 

clone fabric-samples; cd fabric-samples/test-network-k8s 

```shell
export PATH=$PWD:$PWD/bin:$PATH
```

```shell
declare -x TEST_NETWORK_CHAINCODE_BUILDER="k8s"
declare -x TEST_NETWORK_K8S_CHAINCODE_BUILDER_VERSION="v0.6.0"
declare -x TEST_NETWORK_STAGE_DOCKER_IMAGES="false"

export NS=test-network
export TEST_NETWORK_INGRESS_DOMAIN=vcap.me 
export SAMPLE_NETWORK_DIR=/Users/jkneubuh/github.com/jkneubuh/fabric-samples/test-network-k8s

```


```shell
network kind 
network cluster init 
network up
network channel create 
```

```shell
export FABRIC_CFG_PATH=${SAMPLE_NETWORK_DIR}/config/org1
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_ADDRESS=org1-peer1.${TEST_NETWORK_INGRESS_DOMAIN}:443
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=${SAMPLE_NETWORK_DIR}/build/enrollments/org1/users/org1admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${SAMPLE_NETWORK_DIR}/build/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem


```



## Install the chaincode 


Get the chaincode packager script
```shell
curl -fsSL https://raw.githubusercontent.com/hyperledgendary/package-k8s-chaincode-action/main/pkgk8scc.sh -o pkgk8scc.sh && chmod u+x pkgk8scc.sh
```

Build a docker image, upload to a repo, and construct a cc package
```shell
docker build -t localhost:5000/${CHAINCODE_NAME} .
docker push localhost:5000/${CHAINCODE_NAME} 

IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' localhost:5000/${CHAINCODE_NAME} | cut -d'@' -f2)

./pkgk8scc.sh -l ${CHAINCODE_NAME} -n localhost:5000/${CHAINCODE_NAME} -d ${IMAGE_DIGEST} 

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
	--orderer       org0-orderer1.${TEST_NETWORK_INGRESS_DOMAIN}:443 \
	--tls --cafile  ${SAMPLE_NETWORK_DIR}/build/channel-msp/ordererOrganizations/org0/orderers/org0-orderer1/tls/signcerts/tls-cert.pem \
	--connTimeout   15s

peer lifecycle \
	chaincode commit \
	--channelID     mychannel \
	--name          ${CHAINCODE_NAME} \
	--version       ${VERSION} \
	--sequence      ${SEQUENCE} \
	--orderer       org0-orderer1.${TEST_NETWORK_INGRESS_DOMAIN}:443 \
	--tls --cafile  ${SAMPLE_NETWORK_DIR}/build/channel-msp/ordererOrganizations/org0/orderers/org0-orderer1/tls/signcerts/tls-cert.pem \
	--connTimeout   15s



```

```shell
peer chaincode query -n $CHAINCODE_NAME -C mychannel -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}' | jq

```



## Gateway Application 


```shell
cd applications/trader-typescript 
npm install 
```

### Register / enroll a new user 

USERNAME=testuser 
PASSWORD=password 

```shell
fabric-ca-client  register \
  --id.name       ${USERNAME} \
  --id.secret     ${PASSWORD} \
  --id.type       client \
  --url           https://org1-ca.${TEST_NETWORK_INGRESS_DOMAIN} \
  --tls.certfiles ${SAMPLE_NETWORK_DIR}/build/cas/org1-ca/tlsca-cert.pem \
  --mspdir        ${SAMPLE_NETWORK_DIR}/build/enrollments/org1/users/rcaadmin/msp

fabric-ca-client enroll \
  --url           https://${USERNAME}:${PASSWORD}@org1-ca.${TEST_NETWORK_INGRESS_DOMAIN} \
  --tls.certfiles ${SAMPLE_NETWORK_DIR}/build/cas/org1-ca/tlsca-cert.pem \
  --mspdir        ${SAMPLE_NETWORK_DIR}/build/enrollments/org1/users/${USERNAME}/msp

```

```shell
export KEY_DIRECTORY_PATH=${SAMPLE_NETWORK_DIR}/build/enrollments/org1/users/${USERNAME}/msp/keystore/
export CERT_PATH=${SAMPLE_NETWORK_DIR}/build/enrollments/org1/users/${USERNAME}/msp/signcerts/cert.pem

export TLS_CERT_PATH=${SAMPLE_NETWORK_DIR}/build/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem
export PEER_HOST_ALIAS=org1-peer1.vcap.me
export PEER_ENDPOINT=org1-peer1.vcap.me:443
```

```shell
npm start getAllAssets
```
