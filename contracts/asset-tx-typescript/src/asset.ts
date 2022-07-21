/*
  SPDX-License-Identifier: Apache-2.0
*/

import { Object, Property } from 'fabric-contract-api';
import { TextDecoder } from 'util';

const utf8Decoder = new TextDecoder();

@Object()
export class Asset {
    static unmarshal(bytes: Uint8Array | string): Asset {
        const json = typeof bytes === 'string' ? bytes : utf8Decoder.decode(bytes);
        try {
            return JSON.parse(json) as Asset;
        } catch (err) {
            console.log('Malformed asset JSON:', json);
            throw err;
        }
    }

    @Property('docType', 'string')
    public docType?: string;

    @Property('ID', 'string')
    public ID = '';

    @Property('Color', 'string')
    public Color = '';

    @Property('Size', 'number')
    public Size = 0;

    @Property('Owner', 'string')
    public Owner = '';

    @Property('AppraisedValue', 'number')
    public AppraisedValue = 0;
}
