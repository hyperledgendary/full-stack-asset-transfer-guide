# Deploying 


## BLUE 

```shell
# start kind + nginx + DNS localho.st + container registry   
just -f cloud.justfile kind 

just -f k8s.justfile review-config

just -f k8s.justfile operator 
==> error no ofs-ansible:latest image 
```

- OFF THE TRAIL: PINK  
- ofs-ansible (trail from infrastructure/fabric-quickly.sh)
- update fabric-operator to read from ghcr.io/hyperledger-labs/fabric-operator not ibm-blockchain 
```shell
git clone git@github.com:IBM-Blockchain/ansible-collection.git
cd ansible-collection 

docker build -t ofs-ansible . 
```

BLUE: 
