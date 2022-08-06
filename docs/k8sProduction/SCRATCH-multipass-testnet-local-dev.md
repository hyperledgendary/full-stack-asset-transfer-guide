# Full stack with multipass and the Kubernetes Test Network

This scenario sets up a multipass VM with the kubernetes test network and an insecure docker registry.

Chaincode and application development is done locally on the HOST OS, connecting to the Fabric network 
via Nginx ingress.

![Multipass VM with Kube Test Network](../images/multipass-test-network.png)


## Download Fabric CLI binaries 

```shell
curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/bootstrap.sh | bash -s -- -s -d
export PATH=$PWD/bin:$PATH

```


## Multipass VM

- scrub everything Fabric / k8s related on host os.

- install multipass
```shell
brew install --cask multipass
```

- create vm :
```shell
multipass launch \
  --name        fabric-dev \
  --disk        80G \
  --cpus        8 \
  --mem         8G \
  --cloud-init  infrastructure/multipass-cloud-config.yaml

multipass mount $PWD/config fabric-dev:/mnt/config 
```


## Test Network 

- open MP shell: 
```shell
multipass shell fabric-dev
sudo su - dev
```

- create a KIND cluster and install the test network 
```shell
# until PR #811 lands: 
# git clone https://github.com/hyperledger/fabric-samples.git
git clone https://github.com/jkneubuh/fabric-samples.git -b feature/k8s-builder-v7
```

```shell
cd ~/fabric-samples/test-network-k8s

export TEST_NETWORK_DOMAIN=$(hostname -I  | cut -d ' ' -f 1 | tr -s '.' '-').nip.io 
export TEST_NETWORK_CHAINCODE_BUILDER=k8s
export TEST_NETWORK_STAGE_DOCKER_IMAGES=false
export TEST_NETWORK_LOCAL_REGISTRY_INTERFACE=0.0.0.0
```

```shell
# Set up the test network 
./network kind 
./network cluster init 
./network up
./network channel create 

# Copy the crypto material to the host OS via the multipass volume mount 
cp -r build /mnt/config 
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

echo "Connecting to Fabric domain $TEST_NETWORK_DOMAIN"
```

- Set the peer context for the Org1 administrator: 
```shell
export FABRIC_CFG_PATH=$PWD/config
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_ADDRESS=org1-peer1.${TEST_NETWORK_DOMAIN}:443
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=$PWD/config/build/enrollments/org1/users/org1admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=$PWD/config/build/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem
export CORE_PEER_CLIENT_CONNTIMEOUT=10s
export CORE_PEER_DELIVERYTIMEOUT_CONNTIMEOUT=10s
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
	chaincode approveformyorg \
	--channelID     mychannel \
	--name          ${CHAINCODE_NAME} \
	--version       ${VERSION} \
	--package-id    ${PACKAGE_ID} \
	--sequence      ${SEQUENCE} \
	--orderer       org0-orderer1.${TEST_NETWORK_DOMAIN}:443 \
	--tls --cafile  ${PWD}/config/build/channel-msp/ordererOrganizations/org0/orderers/org0-orderer1/tls/signcerts/tls-cert.pem \
	--connTimeout   15s

peer lifecycle \
	chaincode commit \
	--channelID     mychannel \
	--name          ${CHAINCODE_NAME} \
	--version       ${VERSION} \
	--sequence      ${SEQUENCE} \
	--orderer       org0-orderer1.${TEST_NETWORK_DOMAIN}:443 \
	--tls --cafile  ${PWD}/config/build/channel-msp/ordererOrganizations/org0/orderers/org0-orderer1/tls/signcerts/tls-cert.pem \
	--connTimeout   15s

```

```shell
peer chaincode query -n $CHAINCODE_NAME -C mychannel -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}' | jq

```

## Gateway Application Development 



```shell
pushd applications/trader-typescript 
npm install
```


### Register and enroll a new user at the org1 CA 

```shell
USERNAME=org1user 
PASSWORD=org1userpw 

fabric-ca-client  register \
  --id.name       ${USERNAME} \
  --id.secret     ${PASSWORD} \
  --id.type       client \
  --url           https://org1-ca.${TEST_NETWORK_DOMAIN} \
  --tls.certfiles $PWD/config/build/cas/org1-ca/tlsca-cert.pem \
  --mspdir        $PWD/config/build/enrollments/org1/users/rcaadmin/msp

fabric-ca-client enroll \
  --url           https://${USERNAME}:${PASSWORD}@org1-ca.${TEST_NETWORK_DOMAIN} \
  --tls.certfiles $PWD/config/build/cas/org1-ca/tlsca-cert.pem \
  --mspdir        $PWD/config/build/enrollments/org1/users/${USERNAME}/msp
  
```

### Go Bananas 

```shell
export PEER_HOST_ALIAS=org1-peer1.${TEST_NETWORK_DOMAIN} 
export PEER_ENDPOINT=org1-peer1.${TEST_NETWORK_DOMAIN}:443

export KEY_DIRECTORY_PATH=$PWD/config/build/enrollments/org1/users/${USERNAME}/msp/keystore/
export CERT_PATH=$PWD/config/build/enrollments/org1/users/${USERNAME}/msp/signcerts/cert.pem
export TLS_CERT_PATH=$PWD/config/build/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem

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