# Deploy a Fabric Network

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)

---

In addition to a graphical interface, [Fabric Operations Console](https://github.com/hyperledger-labs/fabric-operations-console)
provides a set of RESTful service SDKs which can be utilized to realize a network in a declarative
fashion using the Fabric [Blockchain Ansible Collection](https://github.com/IBM-Blockchain/ansible-collection).
With ansible, a Fabric network of CAs, Peers, Orderers, Channels, Chaincode, and Wallets are
realized by applying a series of playbooks to realize the target configuration.


## Ready?

```shell

just check-kube

```

## Build a Fabric Network

The first step is to create the configuration that Ansible will use, then run the Ansible Playbooks

### Define the namespace and storage class that will be used for console

```shell
export WORKSHOP_NAMESPACE="fabricinfra"
# for *IBM Cloud K8S and Openshift* use this storage class
export WORKSHOP_STORAGE_CLASS="ibmc-file-gold"
```


### Configure Ingress controller to the cluster
*IBMCloud IKS Clusters and Kind* 

```shell
just nginx
```

Check the Ingress controllers domain

For IKS:
```shell
export INGRESS_IPADDR=$(kubectl -n ingress-nginx get svc/ingress-nginx-controller -o json | jq -r '.status.loadBalancer.ingress[0].ip')
export WORKSHOP_INGRESS_DOMAIN=$(echo $INGRESS_IPADDR | tr -s '.' '-').nip.io
```

For Kind:
```shell
export WORKSHOP_INGRESS_DOMAIN=localho.st
```

*IBM Cloud Openshift*

The ingress subdomain can be obtained from the Cluster's dashboard, for example

```shell
export WORKSHOP_INGRESS_DOMAIN=theclusterid.eu-gb.containers.appdomain.cloud
```

### Generate Ansible Playbook configuration

```shell
# check the output to ensure the correct domain, storage class and namespace
just ansible-review-config
```

Please check the local `_cfg/operator-console-vars.yaml` file. Ensure that the ingress domain, storage class and namespace are correct.  By default the all the `WORKSHOP_xxx` varirables are used to see the Ansible configuration, but it's worth double checking the files

For example:
```shell
# this MUST be set to either k8s or openshift
target: openshift
# Console name/domain
console_domain: 203-0-113-42.nip.io
console_storage_class: ibmc-file-gold
```

**For Openshift, please ensure that the `type: openshift` is set**

```
target: openshift
```

- Set Kubectl context

A Kubectl context is also requried - the default behaviour is use the current context.


Alternatively your K8S provider may give you a different command to get the K8S cxontext.
For IKS use this command instead
```shell
ibmcloud ks cluster config --cluster <clusterid> --output yaml > _cfg/k8s_context.yaml
```

The `k8s_context.yaml` will be detected by the shell scripts and that will be used


- Run the [00-complete](../../infrastructure/fabric_network_playbooks/00-complete.yml) play:
```shell

# if you are using IKS/KIND 
# do not do this for OpenShift
just ansible-ingress


# Start the operator and Fabric Operations Console
just ansible-operator
just ansible-console

# Construct a network and channel with ansible playbooks
just ansible-network

# The console will be available at the Nginx ingress domain alias:
echo "open https://fabricinfra-hlf-console-console.<WORKSHOP_INGRESS_DOMAIN>/nodes"

```

- Connect to the console URL (accept the self-signed certificate), log in as admin/password,
  and view the network structure in the Operations Console user interface.


---


[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)
