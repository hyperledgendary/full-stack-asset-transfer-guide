# full-stack-asset-transfer-guide

## Scenario

- Asset transfer, based on the secured assest transfer scenario.
- Token based settlement of the final amount
- Organizations: 
    - Regulator (as endorsing org)
    - Regulator (as ordering org)
    - Bank/Finance Company (two of)

- (could be the letters of credit with actually transferring the funds? )

## Parts of the system

- Chaincode for the private asset transfer
- Client Application using Gateway to send in the transactions
    - tempted to suggest that the regulator has a basic CLI based 
    - the two banks can have a very simple UI if possible to demonstrate the REST API

- Tokens..... yes

## Orchestration of System to provision

- Stand up KIND k8s w/ Operator & Console
- Hit with Ansible script to create the organizations and identities
    - Run in tekton? it is very simple
    - running in the K8S builder



## Suggested steps

