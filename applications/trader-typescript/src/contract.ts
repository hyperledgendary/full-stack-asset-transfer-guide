/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import { Contract } from '@hyperledger/fabric-gateway';
import { TextDecoder } from 'util';

const utf8Decoder = new TextDecoder();

export interface Asset {
    ID: string;
    Color: string;
    Size: number;
    Owner: string;
    AppraisedValue: number;
}

export type AssetUpdate = Pick<Asset, 'ID'> & Partial<Asset>;

export class AssetTransferBasic {
    readonly #contract: Contract;

    constructor(contract: Contract) {
        this.#contract = contract;
    }

    async createAsset(asset: Asset): Promise<void> {
        await this.#contract.submit('CreateAsset', {
            arguments: [JSON.stringify(asset)],
        });
    }

    async readAsset(id: string): Promise<Asset> {
        const result = await this.#contract.evaluate('ReadAsset', {
            arguments: [id],
        });
        return JSON.parse(utf8Decoder.decode(result)) as Asset;
    }

    async updateAsset(asset: AssetUpdate): Promise<void> {
        await this.#contract.submit('UpdateAsset', {
            arguments: [JSON.stringify(asset)],
        });
    }

    async deleteAsset(id: string): Promise<void> {
        await this.#contract.submit('DeleteAsset', {
            arguments: [id],
        });
    }

    async assetExists(id: string): Promise<boolean> {
        const result = await this.#contract.evaluate('AssetExists', {
            arguments: [id],
        });
        return utf8Decoder.decode(result).toLowerCase() === 'true';
    }

    async transferAsset(id: string, newOwner: string): Promise<string> {
        const result = await this.#contract.submit('TransferAsset', {
            arguments: [id, newOwner],
        });
        return utf8Decoder.decode(result);
    }

    async getAllAssets(): Promise<Asset[]> {
        const result = await this.#contract.evaluate('GetAllAssets');
        if (result.length === 0) {
            return [];
        }

        return JSON.parse(utf8Decoder.decode(result)) as Asset[];
    }
}
