# Kubernetes on a Multipass VM 

## Prerequisites 

- multipass 
- kubectl 
- k9s

## Provision a Multipass VM

```shell
multipass launch \
  --name        fabric-dev \
  --disk        80G \
  --cpus        8 \
  --mem         8G \
  --cloud-init  infrastructure/multipass-cloud-config.yaml

multipass mount $PWD/config fabric-dev:/mnt/config

```

## Cluster Setup 

```shell
multipass shell fabric-dev
sudo su - dev 
```

todo: 
- override TEST_NETWORK_INGRESS_DOMAIN 
- set multipass IP 
- override kind config to expose api controller on a public interface: 
```yaml
networking: 
  apiServerAddress: ${multipass_ip}
  apiServerPort: 6000
```
- copy ~dev/.kube/config out to host OS.  This will allow kubectl to run on the host OS, connecting to the k8s API controller exposed on the VM
- reg port 0.0.0.0


```shell
git clone https://github.com/jkneubuh/full-stack-asset-transfer-guide.git -b feature/puff
cd ~/full-stack-asset-transfer-guide 

# export TEST_NETWORK_INGRESS_DOMAIN=$(hostname -I  | cut -d ' ' -f 1 | tr -s '.' '-').nip.io

# Create a Kubernetes cluster in Docker, nginx ingress, and local docker registry:
just -f cloud.justfile kind

# install fabric-operator custom resource definitions 
kubectl apply -k https://github.com/hyperledger-labs/fabric-operator.git/config/crd

```

```shell
k9s -n test-network 
```


## Connect to the Kube API Controller 



### Guide 

Up : [Select a Kube](10-kube.md)

Prev : [Setup](00-setup.md)

Next : [Deploy a Fabric Network](20-fabric.md)

