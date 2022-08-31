# Smart Contract Development

In this section we'll introduce the concept of the Smart Contract, and how they Hyperledger Fabric platform handles these contracts. We'll talk about some of the important aspects to keep to keep in mind; these can be different from other types of developent.

This example shows how details of an asset may be stored in the ledger itself, with the Smart Contract controlling the assets lifecycle. It provides transaction functions to 

- Create an asset
- Retrieve (one or all) assets
- Update an asset
- Delete an asset
- Transfer ownership between parties

If you've never used Fabric before, or if you want to dive into the code, please skip to the [getting started](./01-Exercise-Getting-Started.md) come back to this page as a reference later.

Please remember that Hyperledger Fabric is a  Blockchain Ledger and not a Database!

[NEXT - Getting Stared with Code](./01-Exercise-Getting-Started.md)

---
## Design the assets and contracts

An initial and perhaps the most important decision is - "what information needs to be under the ledger's control?".  This is important for several reasons.

    - the ledger is the shared state between organizations, is the information being shared applicable for all organizations to see?
    - for any data updates/creations of that state which organizations need to 'endorse' the changes? is this the same for all possible changes or is it more limited/specific. For example the 'buyer' and 'seller' of an asset
    - how large is the amount of data? the smaller the better! remember this data needs to be transfered around many parties. Would a salted secure hash of say a scanned document work rather than the entire document?
    - though 'rich query' of the state is possible, the ledger isn't optimised in the same way a database is. Can rich queries be performed off the ledger, and the results 'validated' via a smart contract?

For any end-end tutorial there is a trade-off between making the scenario realistic, but not sufficiently complicated. For this tutorial we'll define the data stored on ledger as being a single 'object' with the following fields. This has been kept very simple, but the approach should be familar.

- ID: string unique-identifier
- Color: string representing a colour
- Size: string representing a size
- Owner: string of the identity name of the owner
- Appraised Value: numerical value.

Argueably not all these values need to be on the ledger, for production use case a reference to off-ledger 'oracle' that held the information of the asset's features, which then provides a hash that could be stored in the ledger. 

It is important to take care over the 'key' that will be used, composite keys are possible. These are constructured to form a hierarchial structure. More information in the next section. 

### Keys and Queries

Hyperledger Fabric offers two forms of ledger query. One is 'Rich Query', and this requires the 'state database' to be configured as CouchDB. (as in this tutorial) and requires that information stored in the ledger is in JSON format. CouchDB indices can be provided (and a strongly recommened). The second is a query by key or partial-key. Think of the ledger as being a form of key-value store.

A key string is formed from a list of strings, separated by the `u+0000` nil byte. There must be at least one string in the list. If there is only one string, this is referred to as `simple` key, otherwise it is a `composite` key. A composite key's first string is referred to as the 'type' to suggest that putting some identification of a type here is a good idea, but this is not enforced by any type system etc. 

A powerful way of querying is by using the concept of range queries. These allow you specify a start and end key, and return an iterator of all key-values between those start and end points (inclusively). The keys are order in alphanumeric order.

For simple keys, there are apis such as `getStateByRange(startKey: string, endKey: string)`.

Complex keys provide a richer query mechanism as they offer a range query by partial key. For example if a composite key has the strings `fruit:pineapples:supplier_fred:consignment_xx`  (using a colon here to make it easier to read, as the nil byte isn't easy to read).

It is possible to issue queries with only a partial key, for example you could query all the consignments between keys consignement-000 and consignment-500 for a given supplier `fruit:pineapples:supplier_fred:consigment-000`  `fruit:pineapples:supplier_fred:consigment-500`

To get query all values held my `supplier_fred`   `fruit:pineapples:supplier_fred`

A way of thinking about this is visualize the keys as forming a hieracrhy.

Note that the 'simple' and 'composite' keys are held distinct from each other. Therefore a query on a simple key won't return anything held under a composite key, and conversly a composite key won't return anything held under a simple key. 

## Transaction Functions

Let's look at the separate transaction functions that can be written on the Smart Contract. Each one of these can be invoked from the client application. They can either be invoked in a read-only manner 'evaluate' that access the state held on the peer the client connects to. Alternatively they can 'submitted' to all the peers that are needed to endorse changes to the ledger, a read-write operation on the ledger.

### General Aspects

Each transaction function needs to be marked as such (using language specific conventions). You can also specify if the function is meant to be 'submitted' or 'evaluated'. This is not enforced but is a indication to the user.

Each function will need to consider how it handles data to marshal into the format needed for the ledger. 

Ensure that each function ensures that any initial state is correct. For example before transfering an asset from Alice to Bob, ensure that Alice does own the asset. 

### Creation Functions

Consider in the create function if you want to pass in the indiviual data elements, or a fully formed object. This is largely a matter of personal preference; remember though that any unique identifier must be created outside of the smart contract. Any form of random choice or other non-deterministic process can not be used.

Often there are extra elements of data (such as the submitting organization) that need to be added. 

### Retrieval

It is a good idea to think ahead of the types of retrival operations that are needed. Can the key structure be created to allow for range queries? 

If rich queries are required, aim to make these as simple as possible and include indexes. Also ensure that if you wish to do a rich query that involves the same data as the 'key' that it is included in the JSON structure.

There is an example of get-all type queries. Please consider that over time this could get a very large amount of data with performance cost. 

### Reading-your-own-writes and conflicts

The updates a transaction function makes to the state, aren't actioned immediately; they form a set of changes that must be endorsed and ordered. There are two important consequences of this asynchronous behaviour.

If data under a key is updated, and then queried *in the same function* the returned data will be the *original* value - not the updated value. 

You will see the error 'MVCC Conflicts': this means that two transaction functions have executed at the same time and attempted to updated the same keys. All code *must* be written with the idea of having to compenstate for this. Typically though this is a simple as re-issuing the transaction. 

You can also minimise exposure by careful creation of the keys. Minimise or remove any form of shared key that needs to be udpated. 

## Audit Trails vs Asset Store

An important decision to make is whether the state held on the ledger is representing an 'audit trail' of activity, or the 'source of truth' of the actual assets.  Storing the information about the assets, as shown in the following samples, is conceptualy straightforward keep in mind that this is a distributed database, rather than a database. 

Storing a form of audit trail can work well with the ledger concept. The 'source of truth' here is that a certain action was taken and it's results. For example the ownership of an asset changed. Details of the actual asset are off chain. This does need more infrastructure provided around the ledger, but is worth considering if the primary business reason is for audit purposes. For example tracking the state of a process and how it moved from one state to the next.

To help with integration of other systems it is well worth issuing events from the transaction functions. These events will be available to the client applications when the transaction is finally comitted. These can be very useful in triggering other processes.

## Is it Smart Contract or Chaincode?

Simply both - the terms have been used in Fabric history almost interchangable; Chaincode was original name, but then Smart Contracts is a common a blockchain term. The class/structure that is extended/implemented in code is called `Contract`.

The aim is to standardize on 
- the Smart Contract(s) are classes/structures - the code - that your write in Go/JavaScript/TypeSciript/Java etc. 
- these are then packaged up and run inside a Chaincode-container (chaincode-image / chaincode-runtime depending on exactly the format of the packaging)
- the chaincode definition is more that just the Smart Contract code, as it includes things such as the couchdb indexes, and the endorsement policy

There still is some 'play' in the usage; but hopefully this is clearer.

## Packaging

In v1 and still supported as 'the old lifecycle' in v2, the CDS package format was used. The v2 'new lifecycle' should be used now - with standard `tar.gz` format. Using `tar` and `gzip` are standard techniques with standard tools. Therefore the main issue becomes what goes into those files and when/how are they used.

