# Getting Started with a Smart Contract

[PREVIOUS - Introduction](./00-Introduction.md) <==>  [NEXT Create a Blank Contract](./02-Creating-Blank-Contract.md)

---

```
git clone https://github.com/hyperledgendary/full-stack-asset-transfer-guide.git workshop
cd workshop
export WORKSHOP=$(pwd)
```

Let's dive straight into creating some code to manage an 'asset'; best to have two windows open, one for running the Fabric network and one for the chaincode development

## Start the Fabric Infrastructure

Startup the Fabric Infrastructure, we're using MicroFab here as it's a single container and fast to start. Plus it already has the configuration required within it to start external chaincodes.

(do this in the Fabric dev window)

```bash
just -f dev.justfile microfab
```

A file  `org1admin.env` is written out that contains the environment variables needed to run applications etc _as the org1 admin_
*ensure that you `source _cfg/uf/org1admin.env`*

At this point you may wish to run `docker logs -f microfab` to watch the activity.

## Pacakge and deploy against Fabric

For development purposes this is the suggested way to package the chaincode. (Note we're going to use a tool that is in the hyperledger-labs)
We're going to start the chaincode separately from the peer, so it's easy to iterate on a debug.  If you want to short cut this section run

```bash
just -f ${WORKSHOP}/dev.justfile debugcc
```
You can skip to the next step 'Iterative Development and Test'.

> If you've written chaincode before, this step may seem a little odd; as there is no code in the chaincode package. It contains just a 'pointer' to where the chaincode will be. This is because we're using a new(ish) feature of Fabric - Chaincode-As-A-Service. 


To run the commands manually:

```bash
export CHAINCODE_SERVER_ADDRESS=0.0.0.0:9999

weft chaincode package caas --path . --label asset-tx-ts --address ${CHAINCODE_SERVER_ADDRESS} --archive asset-tx-ts.tgz --quiet
asset-tx-ts:133f3cdf089ae8e20fdda3e0a98cde3eb15ddbcf319bc83cb919ee28763d6e3e
```

The returned 'chaincode-id' (or package-id) is needed for later
```
export CHAINCODE_ID=asset-tx-ts:133f3cdf089ae8e20fdda3e0a98cde3eb15ddbcf319bc83cb919ee28763d6e3e
```

> IMPORTANT - this chaincode package is merely telling the peer _where_ the chaincode is running; it's not the code. 


We're going to use the peer cli to install the contracts

```
source org1admin.env

peer lifecycle chaincode install asset-tx-ts.tgz
peer lifecycle chaincode approveformyorg --channelID mychannel --name asset-tx -v 0 --package-id $CHAINCODE_ID --sequence 1
peer lifecycle chaincode commit --channelID mychannel --name asset-tx -v 0 --sequence 1

```

(best to keep this window open for later)



## Install and Build

We'll use the example contract already written in `$WORKSHOP/contracts/asset-tx-typescript`

As with any node module this needs to be installed, as as it's typescript built

```
cd contracts/asset-tx-typescript
npm install

npm run build
```

On it's own a smart contract can't do a lot, however an easy way to test the contract has been built ok, is to generate the 'Contract Metatadata'. This is a language agnostic definition of the contracts, and the datatypes the contract returns. It borrows from the OpenAPI used for defining REST APIs.  It is also very useful to share to teams writing client applications so they know the data structures and transaction functions they can call. 
As it's a JSON document, it's ammenable to process to create other resources

The metadata-generate command has been put into the `package.json`
```
npm run metadata
```

Review the `metadata.json` and see the summary of the contract information, the transaction functions, and datatypes. This information can also be captured at runtime and is a good way of testing deployment


## Iterative Development and Test

**All the steps until here are one time only. You can now iterate over the development of your contract**

From a separate shell/window lets start the Smart Contract. Remember that the `CHAINCODE_ID` and the `CHAINCODE_SERVER_ADDRESS` are the only pieces of information needed.

```
export CHAINCODE_SERVER_ADDRESS=0.0.0.0:9999
export CHAINCODE_ID=asset-tx-ts:133f3cdf089ae8e20fdda3e0a98cde3eb15ddbcf319bc83cb919ee28763d6e3e

# or if you ran the short cut above...
# source ${WORKSHOP}/_cfg/uf/org1admin.env

npm run start:server-debug
```

### Run some transactions
Choose a window to run the transactions from; initially we'll use the `peer` cli to run the commands.
Make sure that the peer binary and the config directory are set.  (run the `${WORKKOP}/check.sh script to double check)

Setup the environment context for acting as the Org 1 Administrator.

```
source ${WORKSHOP}/_cfg/uf/org1admin.env
```

The peer cli and issue basic query commands; for example to check the metadata for the contract (if you have jq, it's easier to read if you pipe this into jq)
```
peer chaincode query -C mychannel -n asset-tx -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}'
```

Let's create an asset with ID=001

```
peer chaincode invoke -C mychannel -n asset-tx -c '{"Args":["CreateAsset","{\"ID\":\"001\", \"C
olor\":\"Red\",\"Size\":52,\"Owner\":\"Fred\",\"AppraisedValue\":234234}"]}'
```

And read back that asset

```
peer chaincode query -C mychannel -n asset-tx -c '{"Args":["ReadAsset","001"]}'
{"AppraisedValue":234234,"Color":"Red","ID":"001","Owner":"{\"org\":\"org1MSP\",\"user\":\"Fred\"}","Size":52}
```

## Making a change and re-running the code

If we invoke a query command on a asset that does not exist, for example 002; we get back an error.

```
peer chaincode query -C mychannel -n asset-tx -c '{"Args":["ReadAsset","002"]}'
Error: endorsement failure during query. response: status:500 message:"The asset 002 does not exist"
```

Let's say we want to change that error message to "Sorry, the asset 002 has not been created"

- Stop the running chaincode (CTRL-C!)
- Load the `src/assetTransfer.ts` file into an editor of your choice
- Around line 51, find the error string and make a modification. remembering to save the change
- Rebuild this as it's typscreipt with "npm run build"

You can now restart the contract as before

```
npm run start:server-debug
```


And run the same transaction, and see the updated error code

```
peer chaincode query -C mychannel -n asset-tx -c '{"Args":["ReadAsset","002"]}'
Error: endorsement failure during query. response: status:500 message:"Sorry, asset 002 has not been created"
```

