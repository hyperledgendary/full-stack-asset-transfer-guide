# Creating a blank template

Using 'copier' we can create a sample contract - (this is Typescript, so ensure you have Node 16 installed)

[PREVIOUS - Getting Started](./01-Getting-Started.md) == [NEXT - Test and Debug in detail](./03-Test-And-Debug.md)

--- 

Suggest running this in the `contracts` directory; you can answer the questions how you wish.



```
copier https://github.com/hyperledgendary/fabric-contract-template.git CardContract
No git tags found in template; using HEAD as ref
🎤 Which programming langauge do you want to use
   typescript
🎤 What is the name of the asset type?
   Card
🎤 What is the name of the contract?
   CardMgtContract
🎤 What is the description of the contract?
   Manage Card with MyCardContract
🎤 What is the version of the contract?
   1
🎤 Your project's license
   Apache License 2.0

Copying from template version 0.0.0.post3.dev0+6cc908a
    create  .
    create  contract
    create  contract/docker
    create  contract/docker/docker-entrypoint.sh
    create  contract/src
    create  contract/src/CardMgtContract.spec.ts
    create  contract/src/CardMgtContract.ts
    create  contract/src/index.ts
    create  contract/src/Card.ts
    create  contract/.editorconfig
    create  contract/.gitignore
    create  contract/tsconfig.json
    create  contract/package.json
    create  contract/.npmignore
    create  contract/Dockerfile
    create  contract/tslint.json
```