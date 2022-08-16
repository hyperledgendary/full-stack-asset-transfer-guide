# Exercise: Run the client application

> **Note:** This exercise requires the Fabric network and chaincode deployed in the [Smart Contract Development](../SmartContractDev/) exercises to be running.

Let's make sure we can successfully run the client application and get some familiarity with how to use it.

In a terminal window, nagivate to the [applications/trader-typescript](../../applications/trader-typescript/) directory. Then complete the following steps:

1. Install dependencies and build the client application.
    ```bash
    npm install
    ```

1. Set environment variables to point to resources required by the application.
    ```bash
    export ENDPOINT=org1peer-api.127-0-0-1.nip.io:8080
    export MSP_ID=org1MSP
    export CERTIFICATE=../../_cfg/uf/_msp/org1/org1admin/msp/admincerts/org1admin.pem
    export PRIVATE_KEY=../../_cfg/uf/_msp/org1/org1admin/msp/keystore/cert_sk
    ```

1. Run the **getAllAssets** command to check the assets that currently exist on the ledger (if any).
    ```bash
    npm start getAllAssets
    ```

1. Run the **transact** command to create (and update / delete) some more random assets.
    ```bash
    npm start transact
    ```

1. Run the **getAllAssets** command again to see the new assets recorded on the ledger.
    ```bash
    npm start getAllAssets
    ```

## Optional steps

Try using the **create**, **read** and **delete** commands to work with specific assets.

The environment variable settings above run as a user from org1. If you want to run as a user from org2, use these environment variables:

```bash
export ENDPOINT=org2peer-api.127-0-0-1.nip.io:8080
export MSP_ID=org2MSP
export CERTIFICATE=../../_cfg/uf/_msp/org2/org2admin/msp/admincerts/org2admin.pem
export PRIVATE_KEY=../../_cfg/uf/_msp/org2/org2admin/msp/keystore/cert_sk
```
