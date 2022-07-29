/*
 * SPDX-License-Identifier: Apache-2.0
 */

import { Context, Contract, Info, Returns, Transaction } from 'fabric-contract-api';
import { KeyEndorsementPolicy } from 'fabric-shim';
import stringify from 'json-stringify-deterministic'; // Deterministic JSON.stringify()
import sortKeysRecursive from 'sort-keys-recursive';
import { TextDecoder } from 'util';
import { Asset, newAsset } from './asset';

const utf8Decoder = new TextDecoder();

function unmarshal(bytes: Uint8Array | string): object {
    const json = typeof bytes === 'string' ? bytes : utf8Decoder.decode(bytes);
    const parsed: unknown = JSON.parse(json);
    if (parsed === null || typeof parsed !== 'object') {
        throw new Error(`Invalid JSON type (${typeof parsed}): ${json}`);
    }

    return parsed;
}

function marshal(o: object): Buffer {
    return Buffer.from(toJSON(o));
}

function toJSON(o: object): string {
    // Insert data in alphabetic order using 'json-stringify-deterministic' and 'sort-keys-recursive'
    return stringify(sortKeysRecursive(o));
}

function newMemberPolicy(...orgs: string[]): KeyEndorsementPolicy {
    const policy = new KeyEndorsementPolicy();
    policy.addOrgs('MEMBER', ...orgs);
    return policy;
}

function hasWritePermission(ctx: Context, owner: string): boolean {
    return owner === ctx.clientIdentity.getID();
}

@Info({title: 'AssetTransfer', description: 'Smart contract for trading assets'})
export class AssetTransferContract extends Contract {
    /**
     * CreateAsset issues a new asset to the world state with given details.
     */
    @Transaction()
    async CreateAsset(ctx: Context, assetJson: string): Promise<void> {
        const state = Object.assign(unmarshal(assetJson), {
            Owner: ctx.clientIdentity.getID(),
        });
        const asset = newAsset(state);

        const exists = await this.AssetExists(ctx, asset.ID);
        if (exists) {
            throw new Error(`The asset ${asset.ID} already exists`);
        }

        const assetBytes = marshal(asset);
        await ctx.stub.putState(asset.ID, assetBytes);

        const policy = newMemberPolicy(ctx.clientIdentity.getMSPID());
        await ctx.stub.setStateValidationParameter(asset.ID, policy.getPolicy());

        ctx.stub.setEvent('CreateAsset', assetBytes);
    }

    /**
     * ReadAsset returns an existing asset stored in the world state.
     */
    @Transaction(false)
    async ReadAsset(ctx: Context, id: string): Promise<string> {
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
    async UpdateAsset(ctx: Context, assetJson: string): Promise<void> {
        const assetUpdate: Partial<Asset> = unmarshal(assetJson);
        if (assetUpdate.ID === undefined) {
            throw new Error('No asset ID specified');
        }

        const existingAssetBytes = await this.#readAsset(ctx, assetUpdate.ID);
        const existingAsset = newAsset(unmarshal(existingAssetBytes));

        if (!hasWritePermission(ctx, existingAsset.Owner)) {
            throw new Error('Only owner can update assets');
        }

        const updatedState = Object.assign(existingAsset, assetUpdate, {
            Owner: existingAsset.Owner, // Must transfer to change owner
        });
        const updatedAsset = newAsset(updatedState);

        // overwriting original asset with new asset
        const updatedAssetBytes = marshal(updatedAsset);
        await ctx.stub.putState(updatedAsset.ID, updatedAssetBytes);

        const policy = newMemberPolicy(ctx.clientIdentity.getMSPID());
        await ctx.stub.setStateValidationParameter(updatedAsset.ID, policy.getPolicy());

        ctx.stub.setEvent('UpdateAsset', updatedAssetBytes);
    }

    /**
     * DeleteAsset deletes an asset from the world state.
     */
    @Transaction()
    async DeleteAsset(ctx: Context, id: string): Promise<void> {
        const assetBytes = await this.#readAsset(ctx, id); // Throws if asset does not exist
        const asset = newAsset(unmarshal(assetBytes));

        if (!hasWritePermission(ctx, asset.Owner)) {
            throw new Error('Only owner can delete assets');
        }

        await ctx.stub.deleteState(id);

        ctx.stub.setEvent('DeletaAsset', assetBytes);
    }

    /**
     * AssetExists returns true when asset with the specified ID exists in world state; otherwise false.
     */
    @Transaction(false)
    @Returns('boolean')
    async AssetExists(ctx: Context, id: string): Promise<boolean> {
        const assetJson = await ctx.stub.getState(id);
        return assetJson?.length > 0;
    }

    /**
     * TransferAsset updates the owner field of asset with the specified ID in the world state.
     */
    @Transaction()
    async TransferAsset(ctx: Context, id: string, newOwner: string, newOwnerOrg: string): Promise<void> {
        const assetString = await this.#readAsset(ctx, id);
        const asset = newAsset(unmarshal(assetString));

        if (!hasWritePermission(ctx, asset.Owner)) {
            throw new Error('Only owner can transfer assets');
        }

        asset.Owner = newOwner;

        const assetBytes = marshal(asset);
        await ctx.stub.putState(id, assetBytes);

        const policy = newMemberPolicy(newOwnerOrg);
        await ctx.stub.setStateValidationParameter(id, policy.getPolicy());

        ctx.stub.setEvent('TransferAsset', assetBytes);
    }

    /**
     * GetAllAssets returns a list of all assets found in the world state.
     */
    @Transaction(false)
    @Returns('string')
    async GetAllAssets(ctx: Context): Promise<string> {
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');

        const assets: Asset[] = [];
        for (let result = await iterator.next(); !result.done; result = await iterator.next()) {
            const assetBytes = result.value.value;
            try {
                const asset = newAsset(unmarshal(assetBytes));
                assets.push(asset);
            } catch (err) {
                console.log(err);
            }
        }

        return marshal(assets).toString();
    }
}
