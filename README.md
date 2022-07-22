# full-stack-asset-transfer-guide

**AIM:** To show a full end-to-end development of a solution on the Hyperledger Fabric Platform
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
Please ensure you've the [requisite tools installed](./SETUP.md)
---
## Scenario

- Asset transfer, based on the secured assest transfer scenario.
- Token based settlement of the final amount
- Organizations: 
    - Escrow (as endorsing org)
    - Regulator (as ordering org)
    - Bank/Finance Company (two of)


## Smart Contract Developing

- [Introduction to Smart Contract Developing](./docs/SmartContractDev/00-Introduction.md)
- write contract
- test deployment
- iterate on changes to confirm fun ction

## Write Application Code

- [Introuction to Application Developing](./docs/ApplicationDev/00-introduction.md)
- client sdks for both parties working with assets
- how these can be written and debugged

## Deploy to production-grade

- [Introduction to Deploying to k8s clusters](./docs/k8sProduction/00-Introduction.md)
- [Locally using KIND](./docs/k8sProduction/01-KINDOpenSourcFabricStack.md)


- Start KIND
- Add the Operator/Console
- Create network

## Operate

- Deploy Contracts