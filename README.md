# Fabric Full Stack Development Workshop

**AIM:** To show a full end-to-end development of a solution on the Hyperledger Fabric Platform

Fabric can be used to represent many types of assets from 'marbles/pineapples/classic cars/monetary products/fine art' and track their 
exchange, provenance and lifecycle.

**OBJECTIVES:** 

- Show how a Asset Transfer solution can be modelled and take advantage of a blockchains qualitites of service.
- Show how a Hyperledger Fabric network can be created via automation in K8S
	- Showing how the Fabric Operator and Console can be installed via Ansible playbooks
	- Show how a multi-organization configuration of Fabric can be created
- Show how for an Asset Transfer solution a Smart Contract can be written to support the business logic
	- Show how this can be developed iteratively to get correct function in a development context
	- Show how this can be then deployed to a production-class environment
- Show how client applications can be written using the Gateway functionality
	- Demonstrate how the simplification of the Gateway makes connecting applications more streamlined
	- Show how this streamlined approach improves resilience and availability
- Show how the tooling around Fabric can be used to improve the experience.

---

**Please ensure you've the [required tools](./SETUP.md) on your local machine  -- To check, run `./check.sh`**

---
		
## Before you begin....

Fabric is a multi-server node distributed system, so it can be quite complex to configure. Even the simplest smart contract needs a running Fabric Infrastructure and one size does not fit all.

There are configurations that can run Fabric either as local binaries, in a single docker container, 
in multiple containers, or in K8S.  This workshop will show some of the approaches that be used for developing applications and contracts, and how a production deployment can be achieved. There are other ways
of deploying Fabric produced by the community - these are equally valid and useful. Feel free to try the others, once you got a graps of the basic concepts to find what works best for you.

At a high-level remember that a solution using Fabric has (a) client application to send in transaction requrests (b) Fabric infrastructure to service those requests (c) Smart Contract to action the transactions.
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
- There are suggested changes highlighted in each section; this lets you expriment with different stages of development.

--- 
## Scenario

As a real-world example, lets assuming a 'game/trading card'. Each card represents a comic book character, with their attributes such as strength.
These can be passed between people, with some cards having more 'value' due to rarity or having notable attibutes.  

In token terms, these cards have aspects of Fungible tokens in that a card for say "Mr Blockchain" is equally exchangable for another "Mr Blockchain card"
But there are limited number of different types of cards, and one card can't be subdivided. So have more in common with non-fungible tokens.

- Asset transfer - move cards between people
- Organizations: 
    - Escrow (as endorsing org) and the original holder of all the cards
    - Regulator (as ordering org) to ensure fair play
    - Owner Organizations
		- 3 organizations that people can belong too
		

## Smart Contract Developing

- [Introduction to Smart Contract Developing](./docs/SmartContractDev/00-Introduction.md)
- [Getting Started with a Smart Contract](./docs/SmartContractDev/01-Getting-Started.md)
- [Creating a Blank Contract](./docs/SmartContractDev/02-Creating-Blank-Contract.md)
  - Here you can fill in the functions based on the Trading Card Scenario
- [Detailed Test and Debug](./docs/SmartContractDev/03-Test-And-Debug.md)
- [Deploying to Production](./docs/SmartContractDev/04-Production-Pipelines.md)

## Write Application Code

- [Introuction to Application Developing](./docs/ApplicationDev/00-introduction.md)
- client sdks for both parties working with assets
- how these can be written and debugged


## Cloud Ready 

- [Setup](docs/CloudReady/00-setup.md)
- [Select a Kube](docs/CloudReady/10-kube.md)
- [Deploy a Fabric Network](docs/CloudReady/20-fabric.md)
- [Install Chaincode](docs/CloudReady/30-chaincode.md)
- [Go Bananas](docs/CloudReady/40-bananas.md)
- [Teardown](docs/CloudReady/90-teardown.md)


## Operate

- Deploy Contracts


