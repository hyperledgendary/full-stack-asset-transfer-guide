# Deploy a chaincode to a running Fabric Network on K8S

Starting from a clean system, clone this repo, and open a couple of terminal windows

## Package the contract

The packaging of the contract is slightly different here.

From the `contract/asset-tx-typescript` directory

```
npm install
npm run build
weft chaincode package k8s --path . --label asset-tx-ts --address ${CHAINCODE_SERVER_ADDRESS} --archive asset-tx-ts-caas.tgz --quiet
```
This can be installed into the peer at a later state

## Chaincode container image

A chaincode container image needs to be created; there is a sample dockerfile in `asset-tx-typescript` directory.  You have liberty to change a lot of this dockerfile to your own preferences. 




