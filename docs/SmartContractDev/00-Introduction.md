# Smart Contract Development

This example shows how details of an asset may be stored in the ledger itself, with the Smart Contract controlling the assets lifecycle. It provides transaction functions to 

- Create
- Retrieve (on or all)
- Update 
- Delete
- Transfer between parites

This document shows the design process before writing any code.

---

### [Get started with coding the example!](./01-Details.md)

---

## Design the assets and contracts

We'll define the asset as being a single 'object' with the following fields

- ID: string unque-identifier
- Color: string representing a colour
- Size: string representing a size
- Owner: string of the identity name of the owner
- Appraised Value: numerical value.

This has been kept very simple, but the approach should be familar with other development, specifically Database design.
It is important to take care over the 'key' that will be used, composite keys are possible.


### Create

### Get

### Get all

### 


## Important considerations

### Composite Keys and hierarchy query

### MVCC Conflicts

### Is data storage on the ledger bad or good?