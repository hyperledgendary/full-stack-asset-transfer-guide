# Chaincode as a Service 

This scenario runs chaincode "as a service" on the local host VM.  Fabric runs in a multipass VM on KIND.


## Multipass VM 

```shell
multipass launch \
  --name        fabric-dev \
  --disk        80G \
  --cpus        8 \
  --mem         8G \
  --cloud-init  infrastructure/multipass-cloud-config.yaml

multipass mount $PWD/config fabric-dev:/mnt/config

```


## Fabric Test Network 

```shell
multipass shell fabric-dev

sudo su - dev 
```

```shell
git clone https://github.com/hyperledger/fabric-samples.git
cd fabric-samples/test-network-k8s

export TEST_NETWORK_DOMAIN=$(hostname -I  | cut -d ' ' -f 1 | tr -s '.' '-').nip.io
export TEST_NETWORK_STAGE_DOCKER_IMAGES=false
export TEST_NETWORK_LOCAL_REGISTRY_INTERFACE=0.0.0.0

time ./network kind
time ./network cluster init
time ./network up
time ./network channel create
 
# Copy the crypto material to the host OS via the multipass volume mount 
cp -r build /mnt/config 

```

```shell
k9s -n test-network
```


## Chaincode as a Service 

### SSH reverse proxy

Open a reverse-tunnel / proxy, directing traffic from the VM's port :9999 to the host OS :9999.
When the peer initiates a handshake to the CCaaS endpoint, traffic will be directed to a process 
running locally on the host OS. 

```shell
export MULTIPASS_IP=$(multipass info fabric-dev --format json | jq -r .info.\"fabric-dev\".ipv4[0])
export TEST_NETWORK_DOMAIN=$(echo $MULTIPASS_IP | tr -s '.' '-').nip.io

```

- Add your ~/.ssh/id_rsa.pub public key to the multipass `dev` user's ~/.ssh/authorized_keys

```shell
todo: 
```


### Launch Chaincode as a Service 

Open a second shell on the host OS. 

```shell
export MULTIPASS_IP=$(multipass info fabric-dev --format json | jq -r .info.\"fabric-dev\".ipv4[0])
export TEST_NETWORK_DOMAIN=$(echo $MULTIPASS_IP | tr -s '.' '-').nip.io

```

- Build a chaincode docker image (optional: may just be launched / debugged as a native process)
```shell
export CHAINCODE_NAME=asset-tx-typescript
export CHAINCODE_LABEL=basic
export CONTAINER_REGISTRY=$TEST_NETWORK_DOMAIN:5000
export CHAINCODE_IMAGE=$CONTAINER_REGISTRY/$CHAINCODE_NAME
export CHAINCODE_PACKAGE=$CHAINCODE_NAME-ccaas.tgz 

docker build -t $CHAINCODE_IMAGE contracts/$CHAINCODE_NAME 

```

- Prepare a chaincode as a service package.  The address for the chaincode will reference a port forward 
  within the Virtual Machine, tunneling traffic back to the CCaaS endpoint running on the Host OS:
```shell
cat << EOF > connection.json
{
  "address": "${MULTIPASS_IP}:9999",
  "dial_timeout": "10s",
  "tls_required": false
}
EOF

cat << EOF > metadata.json
{
  "type": "ccaas",
  "label": "${CHAINCODE_LABEL}"
}
EOF

tar -zcf code.tar.gz connection.json
tar -zcf ${CHAINCODE_PACKAGE} code.tar.gz metadata.json

rm code.tar.gz metadata.json connection.json 

```

- Launch the chaincode as a service: 
```shell
export CHAINCODE_SERVER_ADDRESS=0.0.0.0:9999
export CHAINCODE_ID=$CHAINCODE_LABEL:$(shasum -a 256 ${CHAINCODE_PACKAGE} | tr -s ' ' | cut -d ' ' -f 1)

docker run \
  --rm \
  --name $CHAINCODE_NAME \
  -p 9999:9999 \
  -e CHAINCODE_SERVER_ADDRESS \
  -e CHAINCODE_ID \
  $CHAINCODE_IMAGE
    
```


### Install the contract 

- start a new shell on the host 

- Set the `peer` env context:
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

- Install the chaincode
```shell
export CHAINCODE_NAME=asset-tx-typescript
export CHAINCODE_PACKAGE=$CHAINCODE_NAME-ccaas.tgz 

export VERSION=1
export SEQUENCE=1

```

```shell
peer lifecycle chaincode install ${CHAINCODE_PACKAGE}

export PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid ${CHAINCODE_PACKAGE}) && echo $PACKAGE_ID

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


