# Full Stack Local 

- k8s: kind on multipass (via just)
- container registry on multipass:5000 
- kubectl on host os 
- fabric binaries on host os 
- gateway client on host os 

- operator sample network (network up && network channel create) 
- chaincode local build; tag; upload; prepare; install 


## Prereqs 


## VM Instance 

```shell
multipass launch \
  --name        fabric-dev \
  --disk        80G \
  --cpus        8 \
  --mem         8G \
  --cloud-init  infrastructure/multipass-cloud-config.yaml

multipass mount $PWD/config fabric-dev:/mnt/config

multipass shell fabric-dev

```

## Kubernetes 

```shell
git clone https://github.com/jkneubuh/full-stack-asset-transfer-guide.git -b feature/rumble
cd ~/full-stack-asset-transfer-guide

export KIND_API_SERVER_ADDRESS=$(hostname -I | cut -d ' ' -f 1)
export CONTAINER_REGISTRY_ADDRESS=0.0.0.0

# Create a Kubernetes cluster in Docker, nginx ingress, and local docker registry:
just -f cloud.justfile kind

# Install fabric-operator CRDs
kubectl apply -k https://github.com/hyperledger-labs/fabric-operator.git/config/crd

# Copy the kube config to the host volume share
cp ~/.kube/config /mnt/config/multipass-kube-config.yaml

# Observe the target Kubernetes namespace
k9s -n test-network

```

## Configure the Kube Client (host OS)

```shell
export MULTIPASS_IP=$(multipass info fabric-dev --format json | jq -r .info.\"fabric-dev\".ipv4[0])
export TEST_NETWORK_INGRESS_DOMAIN=$(echo $MULTIPASS_IP | tr -s '.' '-').nip.io

# Configure kubectl to connect to the API server on the multipass instance
cp config/multipass-kube-config.yaml ~/.kube/config

kubectl cluster-info

```


## Fabric 

- Open a new shell on the host

- check out / cd to a fabric-operator/sample-network 

- Create the network and channel 
```shell



```

## Chaincode 


## Gateway Client 