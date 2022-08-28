# Deploy a Fabric Network

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)

---

[Fabric-operator](https://github.com/hyperledger-labs/fabric-operator) extends the core Kubernetes API with a set of
[custom resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) suitable for
describing the nodes of a Hyperledger Fabric Network.  With the operator, a set of [CA](../../infrastructure/sample-network/config/cas),
[peer](../../infrastructure/sample-network/config/peers), and [orderer](../../infrastructure/sample-network/config/orderers)
resources are applied to the Kube API controller.  In turn, the operator reflects the network as a series of `Pod`,
`Deployment`, `Service`, and `Ingress` resources in the target namespace.

After the nodes in the Fabric network have been started, the fabric `peer` and CLI binaries are used to connect to the
network via Ingress, preparing a channel for smart contracts and application development. 

![Fabric Operator](../images/CloudReady/20-fabric.png)


## Ready?

```shell

just check-kube

```

## Sample Network

- Install the fabric-operator [Kubernetes Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
```shell

kubectl apply -k https://github.com/hyperledger-labs/fabric-operator.git/config/crd

```

- Apply a series of [CA](../../infrastructure/sample-network/config/cas), [peer](../../infrastructure/sample-network/config/peers),
  and [orderer](../../infrastructure/sample-network/config/orderers) resources directly to the Kube API controller.  In
  turn, fabric-operator will reconcile a network of Kubernetes `Pods`, `Deployments`, `Services`, and `Ingress` to
  reflect the target network structure.
```shell

just cloud-network

```

- Create a Fabric channel:
```shell

just cloud-channel

```

- Set the location for the network's TLS certificates, channel MSP, and user enrollments:
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


# Take it Home:  

- Deploy the [Fabric Operations Console](21-fabric-operations-console.md)
- Build a network with the [Ansible Blockchain Collection](22-fabric-ansible-collection.md)


---

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)
