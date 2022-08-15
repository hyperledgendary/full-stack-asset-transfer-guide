# Deploy a Fabric Network 

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)

---

## Ready?

- todo: write a check.sh for each exercise 
```shell
   [[ -d ${WORKSHOP_PATH}         ]] || echo stop1 \
&& [[ -v WORKSHOP_INGRESS_DOMAIN  ]] || echo stop2 \
&& [[ -v WORKSHOP_NAMESPACE       ]] || echo stop3 \

```

## Operator Sample Network 

- Install the fabric-operator [Kubernetes Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
```shell

kubectl apply -k https://github.com/hyperledger-labs/fabric-operator.git/config/crd

```

- Apply a series of CA, peer, and orderer resources directly to the Kube API controller
```shell

just network-up

```

- Set the location for the network's TLS certificates, channel MSP, and user enrollments 
```shell

export WORKSHOP_CRYPTO=$WORKSHOP_PATH/infrastructure/sample-network/temp

```


## Post Checks 

```shell

curl \
  -s \
  --cacert $WORKSHOP_CRYPTO/cas/org1-ca/tls-cert.pem \
  https://${WORKSHOP_NAMESPACE}-org1-ca-ca.$WORKSHOP_INGRESS_DOMAIN/cainfo \
  | jq

```


# Take it Further:  

### Build a network with Ansible
- just operator 
- just console 
- just sample-network 

### Build a network with the Fabric Operations Console

- just operator 
- just console 
- open https://fabricinfra-hlf-console-console.$TEST_NETWORK_INGRESS_DOMAIN/    ( admin/password )  

---

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)


