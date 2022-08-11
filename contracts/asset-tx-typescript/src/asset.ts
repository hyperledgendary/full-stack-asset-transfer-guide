/*
  SPDX-License-Identifier: Apache-2.0
*/

export interface Asset {
    docType?: string;
    ID: string;
    Color: string;
    Size: number;
    Owner: string;
    AppraisedValue: number;
}

export function newAsset(state: Partial<Asset> = {}): Asset {
    return {
        ID: assertHasValue(state.ID, 'Missing ID'),
        Color: state.Color ?? '',
        Size: state.Size ?? 0,
        Owner: assertHasValue(state.Owner, 'Missing Owner'),
        AppraisedValue: state.AppraisedValue ?? 0,
    };
}

function assertHasValue<T>(value: T | undefined | null, message: string): T {
    if (value == undefined || typeof value === 'string' && value.length === 0) {
        throw new Error(message);
    }

    return value;
}
