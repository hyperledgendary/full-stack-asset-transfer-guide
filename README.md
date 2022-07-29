# full-stack-asset-transfer-guide

**AIM:** To show a full end-to-end development of a solution on the Hyperledger Fabric Platform
**OBJECTIVES:** 

- Show how a Asset Transfer solution can be modelled and take advantage of a blockchains qualitites of service.
- Show how a Hyperledger Fabric network can be created via automation in K8S
	- Showing how the Fabric Operator and Console can be installed via Ansible playbooks
	- Show how a multi-organization configuration of Fabric can be created
- Show how for an Asset Transfer solution a Smart Contract can be written to support the business logic
	- Show how this can be developed iteratively to get correct function in a development context
	- Show how this can be then deployed to a production-class environment
- Show how client applications can be written using the Gateway functionality
	- Demonstrate how the simplification of the Gateway makes connecting applications more streamlined
	- Show how this streamlined approach improves resilience and availability
- Show how the tooling around Fabric can be used to improve the experience.

---
Please ensure you've the [requisite tools installed](./SETUP.md)
---
## Scenario

- Asset transfer, based on the secured assest transfer scenario.
- Token based settlement of the final amount
- Organizations: 
    - Escrow (as endorsing org)
    - Regulator (as ordering org)
    - Bank/Finance Company (two of)


## Smart Contract Developing

- [Introduction to Smart Contract Developing](./docs/SmartContractDev/00-Introduction.md)
- write contract
- test deployment
- iterate on changes to confirm fun ction

## Write Application Code

- [Introuction to Application Developing](./docs/ApplicationDev/00-introduction.md)
- client sdks for both parties working with assets
- how these can be written and debugged

## Deploy to production-grade

- [Introduction to Deploying to k8s clusters](./docs/k8sProduction/00-Introduction.md)
- [Locally using KIND](./docs/k8sProduction/01-KINDOpenSourcFabricStack.md)


- Start KIND
- Add the Operator/Console
- Create network

## Operate

- Deploy Contracts





## Josh scratch notes on running the gateway client app on FOS 

- setup sample network asset-transfer-basic ccaas 
- todo: trader / basic with k8s builder package  

```shell
export SAMPLE_NETWORK_DIR=/Users/jkneubuh/github.com/jkneubuh/fabric-operator/sample-network
export CHAINCODE_NAME=asset-tx-typescript


export KEY_DIRECTORY_PATH=${SAMPLE_NETWORK_DIR}/temp/enrollments/org1/users/org1admin/msp/keystore/
export CERT_PATH=${SAMPLE_NETWORK_DIR}/temp/enrollments/org1/users/org1admin/msp/signcerts/cert.pem
export TLS_CERT_PATH=${SAMPLE_NETWORK_DIR}/temp/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem
export PEER_HOST_ALIAS=test-network-org1-peer1-peer.localho.st
export PEER_ENDPOINT=test-network-org1-peer1-peer.localho.st:443
```

```shell
npm start getAllAssets
```

### chaincode 

Get the chaincode packager script 
```shell
curl -fsSL https://raw.githubusercontent.com/hyperledgendary/package-k8s-chaincode-action/main/pkgk8scc.sh -o pkgk8scc.sh && chmod u+x pkgk8scc.sh
```

Env setup for the test network org1msp 
```shell
export NS=test-network
export TEST_NETWORK_INGRESS_DOMAIN=localho.st
export FABRIC_CFG_PATH=${SAMPLE_NETWORK_DIR}/temp/config
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_ADDRESS=${NS}-org1-peer1-peer.${TEST_NETWORK_INGRESS_DOMAIN}:443
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=${SAMPLE_NETWORK_DIR}/temp/enrollments/org1/users/org1admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${SAMPLE_NETWORK_DIR}/temp/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem

```

```shell
export CC_NAME=asset-tx-typescript
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
	--orderer       ${NS}-org0-orderersnode1-orderer.${TEST_NETWORK_INGRESS_DOMAIN}:443 \
	--tls --cafile  ${SAMPLE_NETWORK_DIR}/temp/channel-msp/ordererOrganizations/org0/orderers/org0-orderersnode1/tls/signcerts/tls-cert.pem \
	--connTimeout   15s

peer lifecycle \
	chaincode commit \
	--channelID     mychannel \
	--name          ${CHAINCODE_NAME} \
	--version       ${VERSION} \
	--sequence      ${SEQUENCE} \
	--orderer       ${NS}-org0-orderersnode1-orderer.${TEST_NETWORK_INGRESS_DOMAIN}:443 \
	--tls --cafile  ${SAMPLE_NETWORK_DIR}/temp/channel-msp/ordererOrganizations/org0/orderers/org0-orderersnode1/tls/signcerts/tls-cert.pem \
	--connTimeout   15s



```






### SCRATCH 



cc package: 
```shell
IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' localhost:5000/${CHAINCODE_NAME} | cut -d'@' -f2)

cat << IMAGEJSON-EOF > image.json
{
  "name": "localhost:5000/${CHAINCODE_NAME}",
  "digest": "${IMAGE_DIGEST}"
}
IMAGEJSON-EOF

tar -czf code.tar.gz image.json

cat << METADATAJSON-EOF > metadata.json
{
  "type": "k8s",
  "label": "basic"
}
METADATAJSON-EOF

tar -czf ${CHAINCODE_NAME}.tgz metadata.json code.tar.gz

```
