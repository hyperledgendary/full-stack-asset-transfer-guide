# Deploy a Kubernetes Cluster

[PREV: Setup](00-setup.md) <==> [NEXT: Deploy a Fabric Network](20-fabric.md)

---

## Ready?

```shell

just check-setup 

```

## Kubernetes IN Docker (KIND)

```shell

export WORKSHOP_INGRESS_DOMAIN=localho.st
export WORKSHOP_NAMESPACE=test-network

```

- Create a [kind](https://kind.sigs.k8s.io) cluster, Nginx ingress, and local container registry:
```shell

just kind

# KIND will set the current kube client context in ~/.kube/config 
kubectl cluster-info

```

- Open a new terminal window and observe the target namespace:
```shell

k9s -n $WORKSHOP_NAMESPACE

```


## Trouble? 

- Run KIND on a [multipass VM](11-kube-multipass.md) on your local system
- Run KIND on an [EC2 instance](12-kube-ec2-vm.md) at AWS


## Take it Further: 

- Run the workshop on an [IKS or EKS Cloud Kubernetes cluster](13-kube-public-cloud.md).
- Run the workshop on an AWS VM, using your AWS account and an EC2 [#cloud-config](../../infrastructure/ec2-cloud-config.yaml).

---
[PREV: Setup](00-setup.md) <==> [NEXT: Deploy a Fabric Network](20-fabric.md)

