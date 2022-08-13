# Teardown 

<== [PREV: Go Bananas](40-bananas.md)

---

## Kind 

```shell
just -f k8s.justfile unkind

```


## Multipass VM 

```shell
multipass delete fabric-dev
multipass purge

```

## Cloud VM 

- Terminate EC2 / IKS Instances (Workshop systems will be deleted after the event)

