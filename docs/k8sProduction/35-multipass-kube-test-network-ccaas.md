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

- Open mp shell #1:
```shell
multipass shell fabric-dev
```

```shell
sudo su - dev 
```


## Fabric Test Network 

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

(Host OS shell):
```shell
export MULTIPASS_IP=$(multipass info fabric-dev --format json | jq -r .info.\"fabric-dev\".ipv4[0])
export TEST_NETWORK_DOMAIN=$(echo $MULTIPASS_IP | tr -s '.' '-').nip.io

```

- Build a docker container for the chaincode 
```shell
export CHAINCODE_NAME=asset-tx-typescript
export CONTAINER_REGISTRY=$TEST_NETWORK_DOMAIN:5000
export CHAINCODE_IMAGE=$CONTAINER_REGISTRY/$CHAINCODE_NAME

docker build -t $CHAINCODE_IMAGE contracts/$CHAINCODE_NAME 

```






- Set the `peer` env context:
```shell
export FABRIC_CFG_PATH=$PWD/config/org1
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_ADDRESS=org1-peer1.${TEST_NETWORK_DOMAIN}:443
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=$PWD/config/build/enrollments/org1/users/org1admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=$PWD/config/build/channel-msp/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem

```



