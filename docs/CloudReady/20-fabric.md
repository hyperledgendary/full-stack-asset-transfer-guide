# Deploy a Fabric Network 

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)

---

## Checks 

- todo: write a check.sh for each exercise 
```shell
   [[ -d ${WORKSHOP_PATH} ]] || echo stop1 \
&& [[ -v WORKSHOP_IP      ]] || echo stop2 \

```


## Configure the Fabric Ingress Domain

```shell
WORKSHOP_NAMESPACE=test-network
WORKSHOP_CRYPTO=$WORKSHOP_PATH/_cfg/sample-network 
WORKSHOP_DOMAIN=$(echo $WORKSHOP_IP | tr -s '.' '-').nip.io && echo $WORKSHOP_DOMAIN

```


## Operator Sample Network 

- Open a new shell and connect to the VM
```shell
# todo: ssh authorized_keys -> ubuntu@${WORKSHOP_IP}
# ssh -i $EC2_INSTANCE_KEY ubuntu@$EC2_INSTANCE_IP 
multipass shell fabric-dev 

```

- Install the fabric-operator [Kubernetes Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
```shell
export TEST_NETWORK_PEER_IMAGE=ghcr.io/hyperledger-labs/k8s-fabric-peer
export TEST_NETWORK_PEER_IMAGE_LABEL=v0.7.2

git clone https://github.com/hyperledger-labs/fabric-operator.git
cd ~/fabric-operator/sample-network

kubectl apply -k https://github.com/hyperledger-labs/fabric-operator.git/config/crd

```

```shell
# for EC2 VMs, use the checkip.amazonaws.com URL to determine the public IP of the host: 
# export TEST_NETWORK_INGRESS_DOMAIN=$(curl -s http://checkip.amazonaws.com | cut -d ' ' -f 1 | tr -s '.' '-').nip.io

# for local KIND clusters, use the local loopback resolver domain:
# export TEST_NETWORK_INGRESS_DOMAIN=localho.st

# For multipass VMs: 
export TEST_NETWORK_INGRESS_DOMAIN=$(hostname -I | cut -d ' ' -f 1 | tr -s '.' '-').nip.io

```

- Apply a series of CA, peer, and orderer resources to the Kube API controller
```shell
./network up

```

- Create `mychannel`
```shell
./network channel create 

```

- Extract the network crypto material
```shell
# todo: use ssh + tar to extract crypto assets from the multipass vm.  Do NOT use a volume share.
#
# Note: if running on an EC2 instance, use ssh to extract the contents of the network crypto 
# assets to the local file system: 
#
# 1. exit the ssh / shell session to the EC2 instance
# 2. execute the following command block on the HOST os:
# 
#    rm -rf $WORKSHOP_PATH/_cfg/sample-network
#    mkdir -p $WORKSHOP_CRYPTO
#    ssh -i $EC2_INSTANCE_KEY ubuntu@$EC2_INSTANCE_IP tar cf - -C fabric-operator/sample-network/temp . | tar xvf - -C $WORKSHOP_CRYPTO
# 
# 3. Do NOT execute the following rm/mkdir/cp commands:

# Delete the crypto material from any previous run 
rm -rf ~/full-stack-asset-transfer-guide/_cfg/sample-network

# Copy the crypto material for the newly created network to the host volume share  
mkdir -p ~/full-stack-asset-transfer-guide/_cfg/sample-network 
cp -r temp/* ~/full-stack-asset-transfer-guide/_cfg/sample-network/

```

- Exit the multipass shell.  All further interaction with the network will be run from the host OS. 


## Post Checks 

```shell
curl --cacert $WORKSHOP_CRYPTO/cas/org1-ca/tls-cert.pem https://${WORKSHOP_NAMESPACE}-org1-ca-ca.$WORKSHOP_DOMAIN/cainfo

```


# Take it Further:  

### Build a network with Ansible
- just operator 
- just console 
- just sample-network 

### Build a network with the Fabric Operations Console

- just operator 
- just console 
- open https://fabricinfra-hlf-console-console.$TEST_NETWORK_INGRESS_DOMAIN/    ( admin/password )  

---

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)


