/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
import { ChaincodeEvent, checkpointers, Gateway } from '@hyperledger/fabric-gateway';
import * as path from 'path';
import { CHAINCODE_NAME, CHANNEL_NAME } from '../config';
import { Asset } from '../contract';
//import { printable } from '../utils';
import { TextDecoder } from 'util';

const axios = require('axios');
const utf8Decoder = new TextDecoder();

const checkpointFile = path.resolve(process.env.CHECKPOINT_FILE ?? 'checkpoint.json');

const startBlock = BigInt(0);

// general
// const webhookURL = 'https://discord.com/api/webhooks/1014964202428960828/SxpAdYFzzuk5cmewaNXuAgxoxapIsvqW9O875IUVZqUXw8sHWgdtMD1MA79VHgVpVKzz';

//conga-bot
//const webhookURL = 'https://discord.com/api/webhooks/1015000194368151632/BdZsgB14nE0f6knUHGO0ij138Vqv-1hj_ewhEN05M-C0bJ0oyoa0wBPONRzvyVWN2wqg';

// conga-bot-test
const webhookURL = 'https://discord.com/api/webhooks/1015036514499051571/hGEHfpMrVeRyXnUcEG2ZFCEbCpLHStQMnOC0YaMKv2AkBy8IR-IQfvvP5qlzi6WMR8zv';

const username = 'King Conga';
const avatarURL = 'https://avatars.githubusercontent.com/u/49026922?s=200&v=4';

export default async function main(gateway: Gateway): Promise<void> {
    const network = gateway.getNetwork(CHANNEL_NAME);
    const checkpointer = await checkpointers.file(checkpointFile);

    console.log(`Starting event discording from block ${checkpointer.getBlockNumber() ?? startBlock}`);
    console.log('Last processed transaction ID within block:', checkpointer.getTransactionId());

    const events = await network.getChaincodeEvents(CHAINCODE_NAME, {
        checkpoint: checkpointer,
        startBlock, // Used only if there is no checkpoint block number
    });

    try {
        for await (const event of events) {

            await onEvent(event);

            await checkpointer.checkpointChaincodeEvent(event)

            // sorry. too fast...
            await new Promise(resolve => setTimeout(resolve, 1000));
        }
    } finally {
        events.close();
    }
}

async function onEvent(event: ChaincodeEvent): Promise<void> {

    const payload = parseJson(event.payload);
    console.log(`\n<-- Chaincode event received: ${event.eventName} -`, payload);

    // Will upload an image / preview matching this name in the conga-bot/images folder.
    const name = payload.ID;

    const message:any = {
        username: username,
        avatar_url: avatarURL,
        content: format(event, payload),
    }

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

    console.log('--> Sending to discord webhook: ' + webhookURL);
    console.log(JSON.stringify(message));

    axios.post(webhookURL, message)
        .then(function (response: any) {
            console.log(response);
        })
        .catch(function (error: any) {
            console.log(error);
        });
}

function parseJson(jsonBytes: Uint8Array): Asset {
    const json = utf8Decoder.decode(jsonBytes);
    return JSON.parse(json);
}

function format(event: ChaincodeEvent, payload: Asset): string {
    return bold(event.eventName + `(${payload.ID}):`) + snippet(JSON.stringify(payload, null, "  "));
}

function snippet(s: string) {
    return "```" + s + "```";
}

function bold(s: string) {
     return "**" + s + "**";
}
