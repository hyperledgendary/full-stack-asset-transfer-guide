/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import * as grpc from '@grpc/grpc-js';
import { connect, Gateway, Identity, Signer, signers } from '@hyperledger/fabric-gateway';
import * as crypto from 'crypto';
import * as fs from 'fs';
import * as path from 'path';
import { defaultClientCertificate, defaultTlsCertificate, locatePrivateKey } from './config';

// User organization MSP ID.
const mspId = process.env.MSP_ID ?? 'Org1MSP';

// Path to user private key file.
const privateKeyPath = process.env.PRIVATE_KEY;

// Path to user certificate file.
const clientCertPath = process.env.CERTIFICATE;

// Path to CA certificate.
const tlsCertPath = process.env.TLS_CERT;

// Gateway endpoint.
const gatewayEndpoint = process.env.ENDPOINT ?? 'localhost:7051';

// Gateway peer SSL host name override.
const hostAlias = process.env.HOST_ALIAS;

export async function newGrpcConnection(): Promise<grpc.Client> {
    const certPath = path.resolve(tlsCertPath ?? defaultTlsCertificate);
    const tlsRootCert = await fs.promises.readFile(certPath);

    if (fs.existsSync(tlsRootCert)){
        const tlsCredentials = grpc.credentials.createSsl(tlsRootCert);
        return new grpc.Client(gatewayEndpoint, tlsCredentials, newGrpcClientOptions());    
    } else {
        return new grpc.Client(gatewayEndpoint, grpc.ChannelCredentials.createInsecure());
    }
}

function newGrpcClientOptions(): grpc.ClientOptions {
    const result: grpc.ClientOptions = {};
    if (hostAlias) {
        result['grpc.ssl_target_name_override'] = hostAlias; // Only required if server TLS cert does not match the endpoint address we use
    }
    return result;
}

export async function newGatewayConnection(client: grpc.Client): Promise<Gateway> {
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
}

async function newIdentity(): Promise<Identity> {
    const certPath = path.resolve(clientCertPath ?? defaultClientCertificate);
    const credentials = await fs.promises.readFile(certPath);

    return { mspId, credentials };
}

async function newSigner(): Promise<Signer> {
    const keyPath = path.resolve(privateKeyPath ?? locatePrivateKey());
    const privateKeyPem = await fs.promises.readFile(keyPath);
    const privateKey = crypto.createPrivateKey(privateKeyPem);

    return signers.newPrivateKeySigner(privateKey);
}
