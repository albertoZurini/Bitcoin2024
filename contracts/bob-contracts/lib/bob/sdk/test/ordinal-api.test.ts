import {
    DefaultOrdinalsClient,
    InscriptionJson,
    OutputJson,
    InscriptionId,
    SatPoint,
} from '../src/ordinal-api';
import { assert, describe, it } from "vitest";

describe("Ordinal API Tests", () => {
    // TODO: change to use ordi
    it("should get inscription from id", async () => {
        const client = new DefaultOrdinalsClient("testnet");
        const inscriptionJson = await client.getInscriptionFromId({
            txid: "74c86592f75716a14a534898913e6077fb5d7650cfc17600868964bbe2b7e512",
            index: 0,
        });

        const expectedInscriptionJson: InscriptionJson<InscriptionId, SatPoint> = {
            address: 'tb1qn50zg73kl8f8wkn8358n4z2drvwraxhl7zdzly',
            charms: [],
            children: [],
            content_length: 868,
            content_type: 'text/javascript',
            fee: 395,
            height: 2537128,
            id: InscriptionId.fromString('74c86592f75716a14a534898913e6077fb5d7650cfc17600868964bbe2b7e512i0'),
            number: 560474,
            next: InscriptionId.fromString('dd90d8222da2a6f3260109b1e4d1a2c341d999fce4707b1d77e49956a51a0305i0'),
            parent: null,
            previous: InscriptionId.fromString('332d3fae125de51de29e97cd9e80aab7c63025d5094944a3dceb117c556c41cci0'),
            rune: null,
            sat: null,
            satpoint: SatPoint.fromString('a4f11b32041419829b56fe456a976efef0c3ba557cf6041918e81e5d3265b884:2:96181932'),
            timestamp: 1699246476,
            value: 156405502,
        };

        assert.deepStrictEqual(expectedInscriptionJson, inscriptionJson);
    });

    it("should get inscriptions", async () => {
        const client = new DefaultOrdinalsClient("testnet");
        const inscriptionsJson = await client.getInscriptions();
        // assert that inscriptionsJson is not null, undefined or empty
        assert.isNotNull(inscriptionsJson);
        assert.isNotEmpty(inscriptionsJson);
    });

    it("should get inscriptions from block", async () => {
        const client = new DefaultOrdinalsClient("testnet");
        const block: number = 2537133;
        const inscriptionsJson = await client.getInscriptionsFromBlock(block);
        const expectedInscriptionsJson = {
            ids: [
                InscriptionId.fromString('4d8e7ad2b410eaa79e3aa703bbe5a314cc89be9a07532bfab09f3c5dffac6348i0'),
                InscriptionId.fromString('d370be1b6bf74677c82226d7a0d65743cbe3846b9216e0ad207a7b03a5230ec3i0')
            ],
            more: false,
            page_index: 0,
        };
        assert.deepStrictEqual(expectedInscriptionsJson, inscriptionsJson);
    });

    it("should get inscriptions from UTXO", async () => {
        const client = new DefaultOrdinalsClient("testnet");
        const outputJson = await client.getInscriptionsFromOutPoint({
            txid: "d370be1b6bf74677c82226d7a0d65743cbe3846b9216e0ad207a7b03a5230ec3",
            vout: 0
        });
        const expectedOutputJson: OutputJson = {
            value: 1967,
            script_pubkey: 'OP_PUSHNUM_1 OP_PUSHBYTES_32 24ad201633789999cbe4251018e796acb22ec5d1a6f8a1873adc6363e04d7e7d',
            address: 'tb1pyjkjq93n0zvenjlyy5gp3euk4jeza3w35mu2rpe6m33k8czd0e7s3ha8st',
            transaction: 'd370be1b6bf74677c82226d7a0d65743cbe3846b9216e0ad207a7b03a5230ec3',
            sat_ranges: null,
            inscriptions: [],
            runes: [],
            indexed: false,
            spent: true
        };
        assert.deepStrictEqual(expectedOutputJson, outputJson);
    });

    it("should get inscriptions from Sat", async () => {
        const client = new DefaultOrdinalsClient("testnet");
        const sat: number = 100;
        const satJson = await client.getInscriptionsFromSat(sat);
        const expectedSatJson = {
            number: 100,
            decimal: '0.100',
            degree: '0°0′0″100‴',
            name: 'nvtdijuwxht',
            block: 0,
            cycle: 0,
            epoch: 0,
            period: 0,
            offset: 100,
            rarity: 'common',
            percentile: '0.0000000000047619047671428594%',
            satpoint: null,
            timestamp: 1296688602,
            inscriptions: []
        };
        assert.deepStrictEqual(expectedSatJson, satJson);
    });

    it("should get inscriptions from start block", async () => {
        const client = new DefaultOrdinalsClient("testnet");
        const startBlock: number = 2537138;
        const inscriptions = await client.getInscriptionsFromStartBlock(startBlock);
        // assert that inscriptions is not null or undefined
        assert.isNotNull(inscriptions);
    });
});
