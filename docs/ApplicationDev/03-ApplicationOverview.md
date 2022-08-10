# Application overview

This topic describes key parts of the client application and how it uses the Fabric Gateway client API to interact with the network. This knowledge will allow you to extend the application in subsequent topics.

## Connect to the Gateway service

Connection to the Gateway service is driven by the **runCommand()** function in [app.ts](../../applications/trader-typescript/src/app.ts). This calls to two other functions to perform the two tasks required before the client application can trasact with the Fabric network:

1. **Create gRPC connection to Gateway endpoint** - this is done in the **newGrpcConnection()** function in [connect.ts](../../applications/trader-typescript/src/connect.ts):
    ```typescript
    const tlsCredentials = grpc.credentials.createSsl(tlsRootCert);
    return new grpc.Client(gatewayEndpoint, tlsCredentials, newGrpcClientOptions());
    ```
    The gRPC client connection is established using the [gRPC API](https://grpc.io/docs/) and is managed by the client application. The application can use the same gRPC connection to transact on behalf of many client identities.

1. **Create Gateway connection** - this is done in the **newGatewayConnection()** function in [connect.ts](../../applications/trader-typescript/src/connect.ts):
    ```typescript
    return connect({
        client,
        identity: await newIdentity(),
        signer: await newSigner(),
        // Default timeouts for different gRPC calls
        evaluateOptions: () => {
            return { deadline: Date.now() + 5000 }; // 5 seconds
        },
        endorseOptions: () => {
            return { deadline: Date.now() + 15000 }; // 15 seconds
        },
        submitOptions: () => {
            return { deadline: Date.now() + 5000 }; // 5 seconds
        },
        commitStatusOptions: () => {
            return { deadline: Date.now() + 60000 }; // 1 minute
        },
    });
    ```
    The **Gateway** connection is established by calling the [connect()](https://hyperledger.github.io/fabric-gateway/main/api/node/functions/connect.html) factory function with a client identity (user's X.509 certificate) and signing implementation (user's private key). It allows a specific user to interact with a Fabric network using the previously created gRPC connection. Optional configuration can also be supplied, and it is strongly recommended to include default timeouts for operations.

## Application CLI commands

All the CLI command implementations are located within the [command](../../applications/trader-typescript/src/commands/) directory. Commands are exposed to [app.ts](../../applications/trader-typescript/src/app.ts) by [command/index.ts](../../applications/trader-typescript/src/commands/index.ts).

When invoked, the command is passed the **Gateway** instance it should use to interact with the Fabric network. To do useful work, command implementations typically performs these steps:

1. **Get Network** - this represents a network of Fabric nodes belonging to a specific Fabric channel:
    ```typescript
    const network = gateway.getNetwork(channelName);
    ```

1. **Get Contract** - this represents a specific smart contract deployed in the **Network**:
    ```typescript
    const contract = network.getContract(chaincodeName);
    ```

1. **Create smart contract adapter** - this provides a view of the smart contract and its transaction functions in form that is easy to use for the client application business logic:
    ```typescript
    const smartContract = new AssetTransfer(contract);
    ```

1. **Invoke transaction functions** - for example:
    - Create an asset in [commands/create.ts](../../applications/trader-typescript/src/commands/create.ts)
        ```typescript
        await smartContract.createAsset({
            ID: assetId,
            Owner: owner,
            Color: color,
            Size: 1,
            AppraisedValue: 1,
        });
        ```
    - Read all assets in [commands/getAllAssets.ts](../../applications/trader-typescript/src/commands/getAllAssets.ts)
        ```typescript
        const assets = await smartContract.getAllAssets();
        ```

## Gateway API calls

TODO

The Fabric Gateway client API
 in [contract.ts](../../applications/trader-typescript/src/contract.ts)
    - Submit: createAsset()
    - Evaluate: getAllAssets()
    - Retry: submitWithRetry()
    - Mention fine-grained flow (see API docs)

