/*
  SPDX-License-Identifier: Apache-2.0
*/

import {Object as DataType, Property} from 'fabric-contract-api';

@DataType()
export class Asset {
    @Property()
    public docType?: string;

    @Property()
    public ID: string;

    @Property()
    public Color: string;

    @Property()
    public Size: number;

    @Property()
    public Owner: string;

    @Property()
    public AppraisedValue: number;
}
