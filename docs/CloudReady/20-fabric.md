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

### Build a network with the [Ansible Blockchain Collection](https://github.com/IBM-Blockchain/ansible-collection)

```shell

# Start the operator and Fabric Operations Console
just operator
just console 

# Construct a network and channel with ansible playbooks
just ansible-sample-network

```


### Build a network with the [Fabric Operations Console](https://github.com/hyperledger-labs/fabric-operations-console)  

- Launch the [fabric-operator](https://github.com/hyperledger-labs/fabric-operator) and console 
```shell

# Start the operator and Fabric Operations Console
just operator
just console 

# The console will be available at the Nginx ingress domain alias: 
echo "open https://$WORKSHOP_NAMESPACE-hlf-console-console.$WORKSHOP_INGRESS_DOMAIN/" 

```

- Open the console (self-signed cert), log in as `admin : password`, and change the admin password.  

- [Build a network](https://cloud.ibm.com/docs/blockchain?topic=blockchain-ibp-console-build-network)


---

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)
