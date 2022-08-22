# Fabric Full Stack Development Workshop

**AIM:** To show a full end-to-end development of a solution on the Hyperledger Fabric Platform

Hyperledger Fabric can be used to represent assets of any kind on a permissioned decentralized ledger, from fungible tokens to non-fungible tokens, including monetary products, marbles, pineapples, classic cars, fine art, and anything else you can imagine.
Fabric can be used to track and update anything about these assets, common examples include asset ownership, exchange, provenance, and lifecycle.

This workshop will demonstrate how a generic asset transfer solution can be modeled and deployed to take advantage of a blockchains qualitites of service.

**OBJECTIVES:**

- Show how an Asset Transfer smart contract can be written to encapsulate business logic
	- Show how the smart contract can be developed iteratively to get correct function in a development context
- Show how client applications can be written using the Gateway functionality
	- Show how the simplification of the Gateway programming model makes connecting applications more streamlined
	- Show how this streamlined approach improves resilience and availability
- Show how the solution can then be deployed to a production-class environment
	- Show how a Hyperledger Fabric network can be created and managed in Kubernetes (K8S) using automation
	- Show how the Fabric Operator and Console can be installed via Ansible playbooks
	- Show how a multi-organization configuration of Fabric can be created

---

**Please ensure you've got the [required tools](./SETUP.md) on your local machine  -- To check, run `./check.sh`**

---

## Before you begin....

Fabric is a multi-server decentralized system with orderer and peer nodes, so it can be quite complex to configure. Even the simplest smart contract needs a running Fabric Infrastructure and one size does not fit all.

There are configurations that can run Fabric either as local binaries, in a single docker container, in multiple containers, or in K8S.
This workshop will show some of the approaches that can be used for developing applications and contracts, and how a production deployment can be achieved.
There are other ways of deploying Fabric produced by the community - these are equally valid and useful. Feel free to try the others, once you understand the basic concepts to find what works best for you.

At a high-level remember that a solution using Fabric has (a) client application to send in transaction requests (b) Fabric infrastructure to service those requests (c) Smart Contract to action the transactions.
The nature of (b) the fabric infrastructure will change depending on your scenario; start simple and build up. The smart contracts and client application's code will remain the same no matter the way Fabric is provisioned.
There will be minor variations in deployment (eg local docker container vs remote K8S cluster) but fundamentally the process is the same.

## Running the workshop

- Ensure you've got the tools you may need installed, or the Vagrant DevImage started
- Clone this repository to a convient location
- We suggest that you open 3 or 4 terminal windows
  - One for running chaincode in dev mode
  - One for running the fabric infrastructure and optionally one for monitoring it
  - One for client applications

- Work through the sections below in order, initially using the supplied scripts and resources
- There are suggested changes highlighted in each section; this lets you experiment with different stages of development.

---
## Scenario

As a real-world example, lets assuming a 'game/trading card'. Each card represents a comic book character, with their attributes such as strength.
These can be passed between people, with some cards having more 'value' due to rarity or having notable attributes.

In token terms, think of these cards as non-fungible tokens. Each card has different attributes and individual cards can't be subdivided.

We'll create a digital representation of these cards on the blockchain ledger. There are a few important aspects of this solution to consider:

- Ledger - The blockchain ledger on each peer maintains the current state of each card (asset), as well as the history of transactions that led to the current state, so that there is no doubt about the assets issuance, provenance, attributes, and ownership.
- Asset transfer smart contract - manage changes to asset state such as the transfer of cards between people
- Organizations - Since this is a permissioned blockchain we'll model the participants as organizations that are authorized to run nodes or transact on the Fabric network.
    - Escrow organization - the original holder of all the cards and runs peers that can endorse their transfer.
    - Regulator organization - runs the ordering service to ensure transactions get ordered into blocks fairly
    - Owner Organizations - 3 organizations that people can belong too. Each owner organization is authorized to run peers and submit transfer transactions for the cards that they own.


## Smart Contract Development

- [Introduction](./docs/SmartContractDev/00-Introduction.md)
- **Exercise**: [Getting Started with a Smart Contract](./docs/SmartContractDev/01-Getting-Started.md)
- **Exercise**: [Adding a new transaction function](./docs/SmartContractDev/02-Adding-tx-function.md)  COMING_SOON
- Reference:
  - [Detailed Test and Debug](./docs/SmartContractDev/03-Test-And-Debug.md)
  - [Smart Contract Resourfces](./docs/SmartContractDev/04-Smart-Contract-Resources.md)
  - [Contract Packaging in depth](./docs/SmartContractDev/05-Contract-packaging-Reference.md)

## Client Application Development

- [Fabric Gateway](docs/ApplicationDev/01-FabricGateway.md)
- **Exercise:** [Run the client application](docs/ApplicationDev/02-Exercise-RunApplication.md)
- [Application overview](docs/ApplicationDev/03-ApplicationOverview.md)
- **Exercise:** [Implement asset transfer](docs/ApplicationDev/04-Exercise-AssetTransfer.md)
- [Chaincode events](docs/ApplicationDev/05-ChaincodeEvents.md)
- **Exercise:** [Use chaincode events](docs/ApplicationDev/06-Exercise-ChaincodeEvents.md)

## Cloud Native Fabric

- [Cloud Ready!](docs/CloudReady/00-setup.md)
- **Exercise:** [Deploy a Kubernetes Cluster](docs/CloudReady/10-kube.md)
- [Fabric Operator](docs/CloudReady/xx-todo.md)
- **Exercise:** [Deploy a Fabric Network](docs/CloudReady/20-fabric.md)
- **Exercise:** [Deploy a Smart Contract](docs/CloudReady/30-chaincode.md)
- **Exercise:** [Deploy a Client Application](docs/CloudReady/40-bananas.md)


## Epilogue

- [Go Bananas](docs/CloudReady/40-bananas.md)
- [Teardown](docs/CloudReady/90-teardown.md)
- [Bring it Home](docs/CloudReady/100-bring-it-home.md) COMING_SOON
