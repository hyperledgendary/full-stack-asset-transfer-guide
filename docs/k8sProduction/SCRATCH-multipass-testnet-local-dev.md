# Full stack with multipass and the Kubernetes Test Network

This scenario sets up a multipass VM with the kubernetes test network and an insecure docker registry.

Chaincode and application development is done locally on the HOST OS, connecting to the Fabric network 
via Nginx ingress.

![Multipass VM with Kube Test Network](../images/multipass-test-network.png)



## Multipass VM

- scrub everything Fabric / k8s related on host os.

- install multipass
```shell
brew install --cask multipass
```

- create vm :
```shell
multipass       launch \
  --name        fabric-dev \
  --disk        80G \
  --cpus        8 \
  --mem         8G \
  --cloud-init  infrastructure/multipass-cloud-config.yaml
```


## Test Network 

- open MP shell: 
```shell
multipass shell fabric-dev
sudo su - dev
```

- create a KIND cluster and install the test network 
```shell
# until PR #811 lands: 
# git clone https://github.com/hyperledger/fabric-samples.git
git clone https://github.com/jkneubuh/fabric-samples.git -b feature/k8s-builder-v7
```

```shell
cd ~/fabric-samples/test-network-k8s

export TEST_NETWORK_DOMAIN=$(hostname -I  | cut -d ' ' -f 1 | tr -s '.' '-').nip.io 
export TEST_NETWORK_CHAINCODE_BUILDER=k8s
export TEST_NETWORK_STAGE_DOCKER_IMAGES=false
export TEST_NETWORK_LOCAL_REGISTRY_INTERFACE=0.0.0.0
```

```shell
./network kind 
./network cluster init 
./network up
./network channel create 
```

- Exit the multipass shell.  All interaction with the Fabric network will occur via Ingress 
```shell
echo "export TEST_NETWORK_DOMAIN=${TEST_NETWORK_DOMAIN}"
exit
exit
```

