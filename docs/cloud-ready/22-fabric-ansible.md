# Deploying 


## BLUE 

```shell
# start kind + nginx + DNS localho.st + container registry   
just -f cloud.justfile kind 

just -f k8s.justfile review-config

just -f k8s.justfile operator 
==> error no ofs-ansible:latest image 
```

- OFF THE TRAIL: PINK  
- ofs-ansible (trail from infrastructure/fabric-quickly.sh)
- update fabric-operator to read from ghcr.io/hyperledger-labs/fabric-operator not ibm-blockchain 
```shell
git clone git@github.com:IBM-Blockchain/ansible-collection.git
cd ansible-collection 

docker build -t ofs-ansible . 
```

BLUE: 
```shell
# start the operator in fabricinfra namespace 
just -f k8s.justfile operator 

# start the console 
just -f k8s.justfile console 
```

+ cat /Users/jkneubuh/github.com/jkneubuh/full-stack-asset-transfer-guide/_cfg/auth-vars.yml
  api_key: k88mTSErJ2iGWvwu
  api_endpoint: http://fabricinfra-hlf-console-console.localho.st/
  api_authtype: basic
  api_secret: gxWjjWKugX3Q4nWBI9ENSu7vVQHtefK_


BLUE: 
```shell
# Create the sample network with ansible 
just -f k8s.justfile sample-network 
```

CONSOLE IS UPDATED ! 












## Notes for follow-up 

- ansible PR 616 ? 
- ansible PR 617 (labs not ibm-blockchain operator) 
- ansible installs operator CRDs.  Not required by just cloud setup. 
- rename hlf-console to fabric-console
- use https:// not http: for console access 
- console CRD can be configured to bypass initial password login
- Talos Linux 
- Update k8s builder to labs v0.7.2 (is hyperledgendary 0.6.0)
- HOW TO UPDATE CONSOLE WITH ADMIN USER IN WALLET ? (~00:15:00 in vid)  
- 


## Notes for Shout Out 

- ansible setup is slow but predictable / repeatable / declarative 
- org2 is added AFTER the initial channel construction.  !!! 
- each "table" at the workshop could be an org.  An exercise could be to add the org / table dynamically? 