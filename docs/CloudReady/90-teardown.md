# Teardown 

<== [PREV: Go Bananas](40-bananas.md)

---

## Sample Network 

```shell

just cloud-network-down 

```


## KIND 

```shell

just kind-down

```


## Multipass VM 

```shell

multipass delete fabric-dev
multipass purge

```

## Cloud VM 

- Terminate EC2 / IKS Instances (Workshop systems will be deleted after the event)

