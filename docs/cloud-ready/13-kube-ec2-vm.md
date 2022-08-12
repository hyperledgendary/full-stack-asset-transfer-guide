# Kubernetes on an EC2 VM Instance

[PREV: Setup](00-setup.md) <==> [NEXT: Deploy a Fabric Network](20-fabric.md) ^^^ [UP: Select a Kube](10-kube.md)

---

# Blocking Issues 

- KIND will not bind to the public IP address of the image, which is a different IP than the NIC. 
- Option: Bind KIND to 0.0.0.0:8888 and then ssh tunnel via localhost:8888 to the API controller.
- Option: k3s 
- Option: run kubectl on VM, not host os. 


## Provision a VM

- Log in to AWS 
- Use `t2.xlarge` profile (4 CPU / 8 GRAM)
- open ports 80 (nginx), 443 (nginx), 5000 (registry), and 8888 (k8s)
- copy/paste `infrastructure/ec2-cloud-config.yaml` as the instance user-data
- Create an ssh key pair for remote login.  Save locally as `~/Downloads/ec2-key.pem`
- After the instance is up, identify the PUBLIC IPV4 address.  This will be used extensively for all access to the cluster:
```shell
export EC2_INSTANCE_IP=107.20.49.98
export EC2_INSTANCE_KEY=~/Downloads/ec2-key.pem
```

- Open an SSH shell to the VM instance: 
```shell
ssh -i $EC2_INSTANCE_KEY ubuntu@${EC2_INSTANCE_IP}
```


## Cluster Setup

```shell
git clone https://github.com/jkneubuh/full-stack-asset-transfer-guide.git -b feature/rumble
cd ~/full-stack-asset-transfer-guide 

# todo: will not work.  public IP != routeable IP 
#export KIND_API_SERVER_ADDRESS=$(curl -s http://checkip.amazonaws.com)
export CONTAINER_REGISTRY_ADDRESS=0.0.0.0

just -f cloud.justfile kind

```

```shell
# Observe the target kube namespace
k9s -n test-network

```


### Configure kubectl

Start a new shell on the host OS: 

```shell
# Backup any existing .kube/config 
cp ~/.kube/config ~/dot-kube-config.bak 

# Point kubectl at the remote k8s API controller
scp -i $EC2_INSTANCE_KEY ubuntu@$EC2_INSTANCE_IP:~/.kube/config ~/.kube/config 

# Check kubectl for access
kubectl cluster-info


```


### Ingress domain: 


```shell
export TEST_NETWORK_INGRESS_DOMAIN=$(echo $EC2_INSTANCE_IP | cut -d ' ' -f 1 | tr -s '.' '-').nip.io

export | grep TEST_NETWORK_INGRESS_DOMAIN

```