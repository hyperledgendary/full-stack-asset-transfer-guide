# Fabric Full Stack Development Workshop

**AIM:** To show a full end-to-end development of a solution on the Hyperledger Fabric Platform

Fabric can be used to represent many types of assets from 'marbles/pineapples/classic cars/monetary products' and track their 
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

**Please ensure you've the [required tools](./SETUP.md) on your local machine**

**If you wish to use a VM on your machine there is a [Vagrant configuration](./docs/vagrant.md)**

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
- [Creating a blank contract](./docs/SmartContractDev/02-Creating-Blank-Contract.md)
- [Detailed Test and Debug](./docs/SmartContractDev//03-Test-And-Debug.md)
- [Deploying to Production](./docs/SmartContractDev/04-Production-Pipelines.md)

## Write Application Code

- [Introuction to Application Developing](./docs/ApplicationDev/00-introduction.md)
- client sdks for both parties working with assets
- how these can be written and debugged

## Deploy to production-grade

- [Introduction to Deploying onto k8s clusters](./docs/k8sProduction/00-Introduction.md)
- [Locally using KIND](./docs/k8sProduction/01-KINDOpenSourcFabricStack.md)

- Create network

## Operate

- Deploy Contracts


