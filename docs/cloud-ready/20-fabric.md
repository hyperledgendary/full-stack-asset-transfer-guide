# Deploy a Fabric Network 

todo: break this into two sections / guides:
- kustomization / k8s API controller
- ansible + console playbooks



## Pre Checks 

- TEST_NETWORK_INGRESS_DOMAIN is set 



## Operator Sample Network 

- git clone fabric-operator and : 

```shell
cd fabric-operator/sample-network

./network up
```



## Post Checks 

```shell
curl --cacert temp/cas/org1-ca/tls-cert.pem https://test-network-org1-ca-ca.$TEST_NETWORK_INGRESS_DOMAIN/cainfo
```





#### Guide

Prev : [Select a Kube](10-kube.md)

Next : [Install Chaincode](30-chaincode.md)

