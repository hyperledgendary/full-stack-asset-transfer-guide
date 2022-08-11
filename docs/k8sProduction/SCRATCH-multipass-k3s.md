# Set up a multipass VM and run k3s 

## Set up VM 

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


## K3s with containerd 





## Configure Kube Client 