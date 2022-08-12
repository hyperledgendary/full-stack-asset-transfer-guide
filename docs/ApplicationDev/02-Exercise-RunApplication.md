# Exercise: Run the client application

Let's make sure we can successfully run the client application and get some familiarity with how to use it.

> For reference, instructions to set up the client application and learn how to run the commands it provides from a terminal window can be found in the application [README](../../applications/trader-typescript/README.md) file.

In a terminal window, nagivate to the [applications/trader-typescript](../../applications/trader-typescript/) directory. Then complete the following steps:

1. Install dependencies and build the client application.
    ```bash
    npm install
    ```

1. Set environment variables to point to resources required by the application.
    > TODO: Populate with suitable values resulting from the smart contract part of the workshop.
    ```bash
    export MSP_ID=Org1MSP
    export CERTIFICATE=
    export PRIVATE_KEY=
    export ENDPOINT=
    export TLS_CERT=
    export HOST_ALIAS=
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
