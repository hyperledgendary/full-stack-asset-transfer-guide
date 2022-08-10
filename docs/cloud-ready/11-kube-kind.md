# Kubernetes in Docker 

## Prerequisites 

- docker 
- just 
- kubectl
- kind
- k9s


## Cluster set up  

```shell
export TEST_NETWORK_INGRESS_DOMAIN=localho.st
```

Create a Kubernetes cluster in Docker, nginx ingress, and local docker registry:
```shell
just -f cloud.justfile kind 
```

Install fabric-operator CRDs:
```shell
kubectl apply -k https://github.com/hyperledger-labs/fabric-operator.git/config/crd
```


## Checks: 

kubectl -> k8s 
```shell
kubectl cluster-info 
```

Ingress domain is set 

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


Up : [Select a Kube](10-kube.md)

Prev : [Setup](00-setup.md)

Next : [Deploy a Fabric Network](20-fabric.md)

