# Ansible Test Network 

[PREV: Select a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md) ^^^ [UP: Deploy Fabric](20-fabric.md)

---

# Deploying 


## BLUE 

```shell
# start kind + nginx + DNS localho.st + container registry   
just -f cloud.justfile kind 

# review the config.  Check _cfg/ for localho.st in console_domain -> should be $TEST_NETWORK_INGRESS_DOMAIN 
just -f k8s.justfile review-config

# start the operator in fabricinfra namespace 
just -f k8s.justfile operator 

# start the console 
just -f k8s.justfile console 
```

```shell
# Create the sample network with ansible 
just -f k8s.justfile sample-network 

```

- NOTE!!!  CONSOLE IS UPDATED ! 
```shell
open https://${TEST_NETWORK_NS}-hlf-console-console.${TEST_NETWORK_INGRESS_DOMAIN}

``` 



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