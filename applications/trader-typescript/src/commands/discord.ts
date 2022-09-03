/*
 * Copyright contributors to the Hyperledgendary Full Stack Asset Transfer Guide project
 *
 * SPDX-License-Identifier: Apache-2.0
 */
import { ChaincodeEvent, checkpointers, Gateway } from '@hyperledger/fabric-gateway';
import * as path from 'path';
import { CHAINCODE_NAME, CHANNEL_NAME } from '../config';
import { Asset } from '../contract';
import { assertDefined } from '../utils';
import { TextDecoder } from 'util';

const axios = require('axios');
const utf8Decoder = new TextDecoder();

const checkpointFile = path.resolve(process.env.CHECKPOINT_FILE ?? 'checkpoint.json');

const startBlock = BigInt(0);

// [#general](https://discord.gg/gCxFD9m3x5)
// export WEBHOOK_URL='https://discord.com/api/webhooks/1014964202428960828/SxpAdYFzzuk5cmewaNXuAgxoxapIsvqW9O875IUVZqUXw8sHWgdtMD1MA79VHgVpVKzz'

// [#conga-bot](https://discord.gg/MAChZeA3ga)
// export WEBHOOK_URL='https://discord.com/api/webhooks/1015000194368151632/BdZsgB14nE0f6knUHGO0ij138Vqv-1hj_ewhEN05M-C0bJ0oyoa0wBPONRzvyVWN2wqg'

// [#conga-bart-test](https://discord.gg/JBMmpBE3dT)
// export WEBHOOK_URL='https://discord.com/api/webhooks/1015586896711254037/hBSqZE7fvtqRHsdEpy3khs7pJAzQ6dST3ZYJuDO4rdR0KoXltK8SdHuoFPhNvQ7Wm69A'

// [#conga-hyperledger](https://discord.gg/X8avnV3zXE)
// export WEBHOOK_URL="https://discord.com/api/webhooks/1015639259656507392/NXnwEQD9WEezzP9o7tCkUkSUNk-qKUUGxScZvZj0R3VuYwoznRHDF-j6h5My6fIq1dYb"

// Bot username and avatar URL
const username = 'King Conga';
const avatarURL = 'https://avatars.githubusercontent.com/u/49026922?s=200&v=4';

export default async function main(gateway: Gateway): Promise<void> {
    const webhookURL = assertDefined(process.env['WEBHOOK_URL'], () => { return 'WEBHOOK_URL is not defined in the env' });
    const network = gateway.getNetwork(CHANNEL_NAME);
    const checkpointer = await checkpointers.file(checkpointFile);

    console.log(`Connecting to #discord webhook ${webhookURL}`);
    console.log(`Starting event discording from block ${checkpointer.getBlockNumber() ?? startBlock}`);
    console.log('Last processed transaction ID within block:', checkpointer.getTransactionId());

    const events = await network.getChaincodeEvents(CHAINCODE_NAME, {
        checkpoint: checkpointer,
        startBlock, // Used only if there is no checkpoint block number
    });

    try {
        for await (const event of events) {
            await discord(webhookURL, event);

            await checkpointer.checkpointChaincodeEvent(event)

            // Slow down the event iterator to avoid rate limitations imposed by discord.
            // This could be improved to catch the "try again" error from discord and resubmit the event before
            // checkpointing the iterator.
            await new Promise(resolve => setTimeout(resolve, 1000));
        }
    } finally {
        events.close();
    }
}

// Relay a quick message to the discord webhook to indicate the transaction has been processed.
async function discord(webhookURL: string, event: ChaincodeEvent): Promise<void> {

    const asset = parseJson(event.payload);
    console.log(`\n<-- Chaincode event received: ${event.eventName}: `, asset);

    const message = prepareMessage(event, asset);

    deliverMessage(webhookURL, message);
}

// Send an event to a discord webhook.
function deliverMessage(webhookURL: string, message: any): void {
    console.log('--> Sending to discord webhook: ' + webhookURL);
    console.log(JSON.stringify(message));

    axios.post(webhookURL, message)
        .then(function (response: any) {
            // console.log(response);
        })
        .catch(function (error: any) {
            console.log(error);
        });
}

function prepareMessage(event: ChaincodeEvent, asset: Asset): any {
    const owner = ownerNickname(asset);
    const text = format(event, asset, owner);

    return {
        username: username,
        avatar_url: avatarURL,
        content: text,
    }
}

function format(event: ChaincodeEvent, asset: Asset, owner: string): string {
    return `${quote(event.transactionId)} ${italic(event.eventName)}(${bold(asset.ID)}, ${owner})`;
}

function parseJson(jsonBytes: Uint8Array): Asset {
    const json = utf8Decoder.decode(jsonBytes);
    return JSON.parse(json);
}

function quote(s: string): string {
    return `\`${s}\``
}

function italic(s: string): string {
    return `_${s}_`;
}

function bold(s: string) {
     return `**${s}**`;
}

//function snippet(s: string) {
//    return "```" + s + "```";
//}

function ownerNickname(asset: Asset): string {
    const owner:any = JSON.parse(asset.Owner);

    return `${owner.org}, ${owner.user}`;
}


/*
    if (event.eventName == 'CreateAsset') {
        message.embeds = [
            {
                // title: name,
                image: {
                    // an actual conga comic (sometimes png and sometimes jpg)
                    // url: `https://congacomic.github.io/assets/img/blockheight-${offset}.png`
                    url: `https://github.com/jkneubuh/full-stack-asset-transfer-guide/blob/feature/nano-bot/applications/conga-bot/images/${name}.png?raw=true`
                }
            }
        ]
    }

*/