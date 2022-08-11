# Kubernetes in Docker 

[PREV: Setup](00-setup.md) <==> [NEXT: Deploy a Fabric Network](20-fabric.md) ^^^ [UP: Select a Kube](10-kube.md) 

---

## Prerequisites 

- docker 
- just 
- kubectl
- kind
- k9s


## Cluster set up  

```shell
# Set a wildcard DNS domain to bind *.localho.st -> 127.0.0.1
export TEST_NETWORK_INGRESS_DOMAIN=localho.st

# Create a Kubernetes cluster in Docker, nginx ingress, and local docker registry:
just -f cloud.justfile kind 

# install fabric-operator custom resource definitions 
kubectl apply -k https://github.com/hyperledger-labs/fabric-operator.git/config/crd
```


## Checks: 

```shell
kind get clusters
```

kubectl -> k8s 
```shell
kubectl cluster-info 
```

Ingress is ... ingressing: 
```shell
curl localho.st
```

```shell
curl --insecure https://localho.st
```

Container registry: 
```shell
docker pull hello-world 
docker tag hello-world localho.st:5000/hello-world 
docker push localho.st:5000/hello-world
docker run --rm localho.st:5000/hello-world 
```

- fabric-operator CRDs are available:
```shell
kubectl get crd
```

- Open a new shell and observe the target namespace:
```shell
k9s -n test-network 
```


