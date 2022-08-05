/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import { Gateway } from '@hyperledger/fabric-gateway';
import create from './create';
import deleteCommand from './delete';
import getAllAssets from './getAllAssets';
import listen from './listen';
import transact from './transact';
import transfer from './transfer';

const commands: Record<string, (gateway: Gateway, args: string[]) => Promise<void>> = {
    create,
    delete: deleteCommand,
    getAllAssets,
    listen,
    transact,
    transfer,
};

export default commands;
