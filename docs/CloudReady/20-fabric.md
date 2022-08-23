# Deploy a Fabric Network

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)

---

## Ready?

```shell

just check-kube

```

## Operator Sample Network

- Install the fabric-operator [Kubernetes Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
```shell

kubectl apply -k https://github.com/hyperledger-labs/fabric-operator.git/config/crd

```

- Apply a series of CA, peer, and orderer resources directly to the Kube API controller
```shell

just cloud-network

```

- Create a Fabric channel
```shell

just cloud-channel

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
  https://$WORKSHOP_NAMESPACE-org1-ca-ca.$WORKSHOP_INGRESS_DOMAIN/cainfo \
  | jq

```

## Troubleshooting

```shell

# While running "just network":
tail -f infrastructure/sample-network/network-debug.log

```


# Take it Further:  

### Build a network with the [Ansible Blockchain Collection](https://github.com/IBM-Blockchain/ansible-collection)

- Run the [00-complete](../../infrastructure/fabric_network_playbooks/00-complete.yml) play:
```shell

export WORKSHOP_NAMESPACE=fabricinfra

# Generate default ansible playbook properties in _cfg/
just ansible-review-config

# Start the operator and Fabric Operations Console
just ansible-operator
just ansible-console

# Construct a network and channel with ansible playbooks
just ansible-network

# The console will be available at the Nginx ingress domain alias:
echo "open https://fabricinfra-hlf-console-console.localho.st/nodes"

```

- Connect to the console URL (accept the self-signed certificate), log in as admin/password, 
  and view the network structure in the Operations Console user interface. 


### Build a network with the [Fabric Operations Console](https://github.com/hyperledger-labs/fabric-operations-console)  

- Launch the [fabric-operator](https://github.com/hyperledger-labs/fabric-operator) and console
```shell

export WORKSHOP_NAMESPACE=fabricinfra

# Generate default ansible playbook properties in _cfg/
just ansible-review-config

# Start the operator and Fabric Operations Console
just ansible-operator
just ansible-console

# The console will be available at the Nginx ingress domain alias:
echo "open https://fabricinfra-hlf-console-console.localho.st/"

```

- Open the console (accept the self-signed cert), log in as `admin : password`, and change the admin password.  

- [Build a network](https://cloud.ibm.com/docs/blockchain?topic=blockchain-ibp-console-build-network)


---

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)
