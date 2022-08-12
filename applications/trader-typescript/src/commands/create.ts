/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import { Gateway } from '@hyperledger/fabric-gateway';
import { chaincodeName, channelName } from '../config';
import { AssetTransfer } from '../contract';
import { assertAllDefined } from '../utils';

export default async function main(gateway: Gateway, args: string[]): Promise<void> {
    const [assetId, owner, color] = assertAllDefined([args[0], args[1], args[2]], 'Arguments: <assetId> <ownerName> <color>');

    const network = gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeName);

    const smartContract = new AssetTransfer(contract);
    await smartContract.createAsset({
        ID: assetId,
        Owner: owner,
        Color: color,
        Size: 1,
        AppraisedValue: 1,
    });
}
