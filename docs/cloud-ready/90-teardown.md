# Teardown 

<== [PREV: Go Bananas](40-bananas.md)

---

## Kind 

```shell
kind delete cluster 
docker kill kind-registry
docker rm kind-registry

```


## Multipass VM 

```shell
multipass delete fabric-dev
multipass purge

```

## Cloud VM 

- Terminate EC2 / IKS Instances (Workshop systems will be deleted after the event)

