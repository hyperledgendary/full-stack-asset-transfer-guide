/*
 * SPDX-License-Identifier: Apache-2.0
 */

import { Context, Contract, Info, Returns, Transaction } from 'fabric-contract-api';
import stringify from 'json-stringify-deterministic'; // Deterministic JSON.stringify()
import sortKeysRecursive from 'sort-keys-recursive';
import { TextDecoder } from 'util';
import { Asset } from './asset';

const utf8Decoder = new TextDecoder();

function marshal(o: object): Buffer {
    return Buffer.from(toJSON(o));
}

function toJSON(o: object): string {
    // we insert data in alphabetic order using 'json-stringify-deterministic' and 'sort-keys-recursive'
    return stringify(sortKeysRecursive(o));
}

@Info({title: 'AssetTransfer', description: 'Smart contract for trading assets'})
export class AssetTransferContract extends Contract {
    /**
     * CreateAsset issues a new asset to the world state with given details.
     */
    @Transaction()
    public async CreateAsset(ctx: Context, assetData: string): Promise<void> {
        const asset = Asset.unmarshal(assetData);
        const exists = await this.AssetExists(ctx, asset.ID);
        if (exists) {
            throw new Error(`The asset ${asset.ID} already exists`);
        }

        // we insert data in alphabetic order using 'json-stringify-deterministic' and 'sort-keys-recursive'
        const assetBytes = marshal(asset);
        await ctx.stub.putState(asset.ID, assetBytes);
        ctx.stub.setEvent('CreateAsset', assetBytes);
    }

    /**
     * ReadAsset returns an existing asset stored in the world state.
     */
    @Transaction(false)
    public async ReadAsset(ctx: Context, id: string): Promise<string> {
        const assetBytes = await this.#readAsset(ctx, id);
        return utf8Decoder.decode(assetBytes);
    }

    async #readAsset(ctx: Context, id: string): Promise<Uint8Array> {
        const assetBytes = await ctx.stub.getState(id); // get the asset from chaincode state
        if (!assetBytes || assetBytes.length === 0) {
            throw new Error(`The asset ${id} does not exist`);
        }

        return assetBytes;
    }

    /**
     * UpdateAsset updates an existing asset in the world state with provided partial asset data, which must include
     * the asset ID.
     */
    @Transaction()
    public async UpdateAsset(ctx: Context, assetData: string): Promise<void> {
        const assetUpdate = JSON.parse(assetData) as Partial<Asset>;
        if (assetUpdate.ID === undefined) {
            throw new Error('No asset ID specified');
        }

        const existingAssetBytes = await this.#readAsset(ctx, assetUpdate.ID);
        const existingAsset = Asset.unmarshal(existingAssetBytes);

        const updatedAsset = Object.assign(existingAsset, assetUpdate, {
            Owner: existingAsset.Owner, // Must transfer to change owner
        });

        // overwriting original asset with new asset
        const updatedAssetBytes = marshal(updatedAsset);
        await ctx.stub.putState(updatedAsset.ID, updatedAssetBytes);
        ctx.stub.setEvent('UpdateAsset', updatedAssetBytes);
    }

    /**
     * DeleteAsset deletes an asset from the world state.
     */
    @Transaction()
    public async DeleteAsset(ctx: Context, id: string): Promise<void> {
        const assetBytes = await this.#readAsset(ctx, id); // Throws if asset does not exist

        await ctx.stub.deleteState(id);
        ctx.stub.setEvent('DeletaAsset', assetBytes);
    }

    /**
     * AssetExists returns true when asset with the specified ID exists in world state; otherwise false.
     */
    @Transaction(false)
    @Returns('boolean')
    public async AssetExists(ctx: Context, id: string): Promise<boolean> {
        const assetJSON = await ctx.stub.getState(id);
        return assetJSON && assetJSON.length > 0;
    }

    /**
     * TransferAsset updates the owner field of asset with the specified ID in the world state, and returns the old
     * owner.
     */
    @Transaction()
    public async TransferAsset(ctx: Context, id: string, newOwner: string): Promise<string> {
        const assetString = await this.ReadAsset(ctx, id);
        const asset = JSON.parse(assetString) as Asset;

        const oldOwner = asset.Owner;
        asset.Owner = newOwner;

        const assetBytes = marshal(asset);
        await ctx.stub.putState(id, assetBytes);
        ctx.stub.setEvent('TransferAsset', assetBytes);

        return oldOwner;
    }

    /**
     * GetAllAssets returns a list of all assets found in the world state.
     */
    @Transaction(false)
    @Returns('string')
    public async GetAllAssets(ctx: Context): Promise<string> {
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');

        const assets: Asset[] = [];
        for (let result = await iterator.next(); !result.done; result = await iterator.next()) {
            const assetBytes = result.value.value;
            try {
                const asset = Asset.unmarshal(assetBytes);
                assets.push(asset);
            } catch (err) {
                console.log(err);
            }
        }

        return marshal(assets).toString();
    }
}
