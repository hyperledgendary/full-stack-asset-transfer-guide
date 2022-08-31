import { Contract } from "@hyperledger/fabric-gateway";
import { Request, Response } from "express";
const utf8Decoder = new TextDecoder();
import { Connection } from "./connection";
export class AssetRouter {
    public routes(app): void {
        app.route('/list')
            .get(async (req: Request, res: Response) => {
                const resultBytes = Connection.contract.evaluateTransaction('GetAllAssets');
                const resultJson = utf8Decoder.decode(await resultBytes);
                const result = JSON.parse(resultJson);
                res.status(200).send(result);
            })
        app.route('/create')
            .post((req: Request, res: Response) => {
                console.log(req.body)
                var json = JSON.stringify({
                    ID: Date.now() + "",
                    Owner: req.body.owner,
                    Color: req.body.color,
                    Size: req.body.size,
                    AppraisedValue: req.body.AppraisedValue,
                })
                console.log('json is ' + json);
                Connection.contract.submitTransaction('CreateAsset', json);
                // this.createAsset(Connection.contract)
                res.status(200).send("Success");
            })
        app.route('/transfer')
            .post(async (req: Request, res: Response) => {
                console.log(req.body)

                console.log('\n--> Async Submit Transaction: TransferAsset, updates existing asset owner');

                const commit = Connection.contract.submitAsync('TransferAsset', {
                    arguments: [req.body.assetId, 'Saptha'],
                });
                const oldOwner = utf8Decoder.decode((await commit).getResult());

                console.log(`*** Successfully submitted transaction to transfer ownership from ${oldOwner} to Saptha`);
                console.log('*** Waiting for transaction commit');

                const status = await (await commit).getStatus();
                if (!status.successful) {
                    throw new Error(`Transaction ${status.transactionId} failed to commit with status code ${status.code}`);
                }
                console.log('*** Transaction committed successfully');
                // this.createAsset(Connection.contract)
                res.status(200).send(status);
            })
            app.route('/updateNonExistentAsset')
            .post(async (req: Request, res: Response) => {
                try {
                    await Connection.contract.submitTransaction(
                        'UpdateAsset',
                        'asset70',
                        'blue',
                        '5',
                        'Tomoko',
                        '300',
                    );
                    console.log('******** FAILED to return an error');
                } catch (error) {
                    console.log('*** Successfully caught the error: \n', error);
                }
                res.status(200).send("Success");
            })
        app.route('/update')
            .post((req: Request, res: Response) => {
                this.createAsset(Connection.contract)
                res.status(200).send({});
            })
        app.route('/get/:id')
            .get(async (req: Request, res: Response) => {
                let id = req.params.id;
                console.log('\n--> Evaluate Transaction: ReadAsset, function returns asset attributes');

                const resultBytes = Connection.contract.evaluateTransaction('ReadAsset', id);

                const resultJson = utf8Decoder.decode(await resultBytes);
                const result = JSON.parse(resultJson);
                console.log('*** Result:', result);
                res.status(200).send(result);
            })
    }
    private createAsset(contract: Contract) {
        console.log('\n--> Submit Transaction: CreateAsset, creates new asset with ID, Color, Size, Owner and AppraisedValue arguments');
        var json = JSON.stringify({
            ID: "2",
            Owner: "owner",
            Color: "color",
            Size: 1,
            AppraisedValue: 1,
        })
        contract.submitTransaction('CreateAsset', json);

        console.log('*** Transaction committed successfully');
    }
}
