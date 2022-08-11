# Gateway Client Application 

## Prerequisites 

- node 

## Register and enroll a new user at the org1 CA

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

## Go Bananas

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

## Guide 