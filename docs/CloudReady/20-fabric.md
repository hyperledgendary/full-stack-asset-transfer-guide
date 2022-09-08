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

## Peer logs

To watch the peer logs throughout the workshop, we'll need to identify the pod name for one of the peers, let's find the pod name for org1-peer1.
You can either use the [k9s utility](https://k9scli.io/topics/install/) to see the pods, or kubectl. Let's use kubectl here and set the default namespace to `test-network` so that we don't have to pass the namespace (`-n`) to each kubectl command:

```shell
kubectl config set-context --current --namespace=test-network
kubectl get pods
```

You'll see the org1-peer1 pod with a name like `org1-peer1-79df64f8d8-7m9mt`, your pod name will be different!

We can then tail the org1-peer1 log in a terminal window so that we can see proof that chaincodes get deployed, blocks get created, etc:

```shell
kubectl logs -f org1-peer1-79df64f8d8-7m9mt peer
```

## Troubleshooting

```shell

# While running "just cloud-network and/or just cloud-channel":
tail -f infrastructure/sample-network/network-debug.log

```


# Take it Further:  

- Deploy the [Fabric Operations Console](21-fabric-operations-console.md)
- Build a network with the [Ansible Blockchain Collection](22-fabric-ansible-collection.md)


---

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)
