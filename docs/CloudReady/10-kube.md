# Deploy a Kubernetes Cluster

[PREV: Setup](00-setup.md) <==> [NEXT: Deploy a Fabric Network](20-fabric.md)

---

## Provision a Virtual Machine

```shell
multipass launch \
  --name        fabric-dev \
  --disk        80G \
  --cpus        8 \
  --mem         8G \
  --cloud-init  infrastructure/multipass-cloud-config.yaml

multipass mount $PWD fabric-dev:/home/ubuntu/full-stack-asset-transfer-guide

WORKSHOP_IP=$(multipass info fabric-dev --format json | jq -r .info.\"fabric-dev\".ipv4[0])

```


## Start a KIND Cluster

- Open a new shell and connect to the VM 
```shell
# todo ssh authorized_keys -> ubuntu@${WORKSHOP_IP} not multipass shell 
multipass shell fabric-dev
```

```shell
cd ~/full-stack-asset-transfer-guide 

# Bind a docker container registry to the VM's external IP  
export CONTAINER_REGISTRY_ADDRESS=0.0.0.0
export CONTAINER_REGISTRY_PORT=5000

# Create a Kubernetes cluster in Docker, configure an Nginx ingress, and docker container registry
just -f k8s.justfile kind 

```

```shell
# Observe the target Kubernetes workspace 
k9s -n test-network

```


## Troubleshooting: 

- look on the back of your conga card.
- ssh to the WORKSHOP_IP on the back of the conga card.
- Set up password-less ssh access to the EC2 instance 
- Use the [ec2 vm instance](11-kube-ec2-vm.md) to provision your KIND cluster


# Take it Further:

- Run k8s directly on your laptop with [KIND](todo.md)  (`export WORKSHOP_DOMAIN=localho.st`)
- Provision an EC2 instance on your AWS account with a [#cloud-config](../../infrastructure/ec2-cloud-config.yaml)
- Connect your kube client to a cloud k8s provider 


---
[PREV: Setup](00-setup.md) <==> [NEXT: Deploy a Fabric Network](20-fabric.md)

