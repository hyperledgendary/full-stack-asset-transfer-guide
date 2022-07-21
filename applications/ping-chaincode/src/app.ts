/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import { connect, Contract, Identity, Signer, signers } from '@hyperledger/fabric-gateway';
import * as crypto from 'crypto';
import { promises as fs } from 'fs';
import * as path from 'path';
import { TextDecoder } from 'util';
import { ConnectionHelper } from './fabric-connection-profile';
import JSONIDAdapter from './jsonid-adapter';

import { dump } from 'js-yaml';

const channelName = envOrDefault('CHANNEL_NAME', 'mychannel');
const chaincodeName = envOrDefault('CHAINCODE_NAME', 'conga-nft-contract');
const mspId = envOrDefault('MSP_ID', 'Org1MSP');

const connectionProfile = envOrDefault('CONN_PROFILE','');
const identityFile = envOrDefault('ID_FILE','')
const identityDir = envOrDefault('ID_DIR','')
// Path to crypto materials.
const cryptoPath = envOrDefault('CRYPTO_PATH', path.resolve(__dirname, '..', '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'org1.example.com'));

// Path to user private key directory.
const keyDirectoryPath = envOrDefault('KEY_DIRECTORY_PATH', path.resolve(cryptoPath, 'users', 'User1@org1.example.com', 'msp', 'keystore'));

// Path to user certificate.
const certPath = envOrDefault('CERT_PATH', path.resolve(cryptoPath, 'users', 'User1@org1.example.com', 'msp', 'signcerts', 'cert.pem'));

// Path to peer tls certificate.
const tlsCertPath = envOrDefault('TLS_CERT_PATH', path.resolve(cryptoPath, 'peers', 'peer0.org1.example.com', 'tls', 'ca.crt'));

// Gateway peer endpoint.
const peerEndpoint = envOrDefault('PEER_ENDPOINT', 'localhost:7051');

// Gateway peer SSL host name override.
const peerHostAlias = envOrDefault('PEER_HOST_ALIAS', 'peer0.org1.example.com');

const utf8Decoder = new TextDecoder();
const assetId = `asset${Date.now()}`;



async function main(): Promise<void> {

    const cp = await ConnectionHelper.loadProfile(connectionProfile);
    console.log(cp);

    // The gRPC client connection should be shared by all Gateway connections to this endpoint.
    const client = await ConnectionHelper.newGrpcConnection(cp);
    console.log("Created GRPC Connection")

    const jsonAdapter: JSONIDAdapter = new JSONIDAdapter(path.resolve(identityDir),'Org1MSP');
    const identity = await jsonAdapter.getIdentity(identityFile);
    const signer = await jsonAdapter.getSigner(identityFile);

    console.log("Loaded Identity")
    const gateway = connect({
        client,
        identity,
        signer,
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

    try {
        // Get a network instance representing the channel where the smart contract is deployed.
        const network = gateway.getNetwork(channelName);

        // Get the smart contract from the network.
        const contract = network.getContract(chaincodeName);

        // Return all the current assets on the ledger.
        await ping(contract);

    } finally {
        gateway.close();
        client.close();
    }
}

main().catch(error => {
    console.error('******** FAILED to run the application:', error);
    process.exitCode = 1;
});

/**
 * Evaluate a transaction to query ledger state.
 */
async function ping(contract: Contract): Promise<void> {
    console.log('\n--> Evaluate Transaction: Get Contract Metdata from :  org.hyperledger.fabric:GetMetadata');

    const resultBytes = await contract.evaluateTransaction('org.hyperledger.fabric:GetMetadata');

    const resultJson = utf8Decoder.decode(resultBytes);
    const result = JSON.parse(resultJson);
    console.log('*** Result:');
    console.log(dump(result));
}


/**
 * envOrDefault() will return the value of an environment variable, or a default value if the variable is undefined.
 */
function envOrDefault(key: string, defaultValue: string): string {
    return process.env[key] || defaultValue;
}
