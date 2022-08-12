# Notes on Packaging

Packaging up the Smart Contracts into a chaincode package, is a central part of deploying a 'business process' to Hyperledger Fabric.  Over the releases there has been a lot of flux in the way this is done, and how the lifecycle of the chaincode container.

## Is it Smart Contract or Chaincode?

Simply both - the terms have been used in Fabric history almost interchangable; Chaincode was original name, but then Smart Contracts is a common a blockchain term. The class/structure that is extended/implemented in code is called `Contract`.

The aim is to standardize on 
- the Smart Contract(s) are classes/structures - the code - that your write in Go/JavaScript/TypeSciript/Java etc. 
- these are then packaged up and run inside a Chaincode-container (chaincode-image / chaincode-runtime depending on exactly the format of the packaging)
- the chaincode definition is more that just the Smart Contract code, as it includes things such as the couchdb indexes, and the endorsement policy

There still is some 'play' in the usage; but hopefully this is clearer.

## Packaging

In v1 and still supported as 'the old lifecycle' in v2, the CDS package format was used. The v2 'new lifecycle' should be used now - with standard `tar.gz` format. Using `tar` and `gzip` are standard techniques with standard tools. Therefore the main issue becomes what goes into those files and when/how are they used.


