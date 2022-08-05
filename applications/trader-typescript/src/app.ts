/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import { connect } from '@hyperledger/fabric-gateway';
import commands from './commands';
import { newConnectOptions, newGrpcConnection } from './connect';
import { ExpectedError } from './expectedError';

async function main(): Promise<void> {
    const commandName = process.argv[2];
    const args = process.argv.slice(3);

    const command = commands[commandName];
    if (!command) {
        printUsage();
        throw new Error(`Unknown command: ${commandName}`);
    }

    const client = await newGrpcConnection();
    try {
        const connectOptions = await newConnectOptions(client);
        const gateway = connect(connectOptions);
        try {
            await command(gateway, args);
        } finally {
            gateway.close();
        }
    } finally {
        client.close();
    }
}

function printUsage(): void {
    console.log('Arguments: <command> [<arg1> ...]');
    console.log('Available commands:', Object.keys(commands).join(', '));
}

main().catch(error => {
    if (error instanceof ExpectedError) {
        console.log(error);
    } else {
        console.error('\nUnexpected application error:', error);
        process.exitCode = 1;
    }
});
