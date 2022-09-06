/*
  SPDX-License-Identifier: Apache-2.0
*/

// export interface Asset {
//     docType?: string;
//     ID: string;
//     Color: string;
//     Size: number;
//     Owner: string;
//     AppraisedValue: number;
// }


import {Object as DataType, Property } from 'fabric-contract-api';

@DataType()
export class Asset {
    @Property('ID', 'string')
        ID ='';

    @Property('Color', 'string')
        Color='';

    @Property('Owner', 'string')
        Owner='';

    @Property('AppraisedValue', 'number')
        AppraisedValue=0;

    @Property('Size', 'number')
        Size=0;
    // eslint-disable-next-line @typescript-eslint/no-empty-function
    public constructor() {}

    static newAsset(state: Partial<Asset> = {}): Asset {
        return {
            ID: Asset.assertHasValue(state.ID, 'Missing ID'),
            Color: state.Color ?? '',
            Size: state.Size ?? 0,
            Owner: Asset.assertHasValue(state.Owner, 'Missing Owner'),
            AppraisedValue: state.AppraisedValue ?? 0,
        };
    }

    static assertHasValue<T>(value: T | undefined | null, message: string): T {
        if (value == undefined || typeof value === 'string' && value.length === 0) {
            throw new Error(message);
        }

        return value;
    }
}
