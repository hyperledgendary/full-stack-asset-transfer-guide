/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import { Gateway } from '@hyperledger/fabric-gateway';
import { chaincodeName, channelName } from './connect';
import { AssetTransfer } from './contract';
import { assertDefined } from './utils';

export default async function main(gateway: Gateway, args: string[]): Promise<void> {
    const assetId = assertDefined(args[0], 'Missing asset ID');
    const newOwner = assertDefined(args[1], 'Missing new owner name');
    const newOwnerOrg = assertDefined(args[2], 'Missing new owner MSP ID');

    const network = gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeName);

    const smartContract = new AssetTransfer(contract);
    await smartContract.transferAsset(assetId, newOwner, newOwnerOrg);
}
