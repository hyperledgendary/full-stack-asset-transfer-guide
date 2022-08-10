# Kubernetes in Docker 

## Prerequisites 

- docker 
- just 
- kubectl
- kind
- k9s


## Cluster set up  

todo: set up KIND from just file? or from operator sample network?

```shell
export TEST_NETWORK_INGRESS_DOMAIN=localho.st
```

```shell
just -f cloud.justfile kind 
```


## Checks: 

- kubectl -> k8s 
```shell
kubectl cluster-info 
```

- Ingress domain is set 

- Ingress is ... ingressing: 
```shell
curl localho.st
```

```shell
curl --insecure https://localho.st
```

- Container registry is running: 
```shell
docker run hello-world 
docker tag hello-world localho.st:5000/hello-world 
docker push localho.st:5000/hello-world
```


Up : [Select a Kube](10-kube.md)

Prev : [Setup](00-setup.md)

Next : [Deploy a Fabric Network](20-fabric.md)

