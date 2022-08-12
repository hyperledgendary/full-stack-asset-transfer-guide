# Exercise: Run the client application

Let's make sure we can successfully run the client application and get some familiarity with how to use it.

> For reference, instructions to set up the client application and learn how to run the commands it provides from a terminal window can be found in the application [README](../../applications/trader-typescript/README.md) file.

In a terminal window, nagivate to the [applications/trader-typescript](../../applications/trader-typescript/) directory. Then complete the following steps:

1. Install dependencies and build the client application.
    ```bash
    npm install
    ```

1. Set environment variables to point to resources required by the application.
    ```bash
    export MSP_ID=org1MSP
    export CERTIFICATE=../../_cfg/uf/_msp/org1/org1admin/msp/admincerts/org1admin.pem
    export PRIVATE_KEY=../../_cfg/uf/_msp/org1/org1admin/msp/keystore/cert_sk
    export ENDPOINT=org1peer-api.127-0-0-1.nip.io:8080
    export TLS_CERT=../../_cfg/uf/_msp/org1/org1caadmin/msp/cacerts/ca.pem
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
