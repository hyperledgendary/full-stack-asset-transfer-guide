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

- Note: if you are not using `localho.st` as the network ingress domain, after running `ansible-review-config`
  target below, edit the local `_cfg/operator-console-vars.yaml` file and set the ingress domain to
  `${WORKSHOP_INGRESS_DOMAIN}` before starting the console or configuring the network.

For example:
```shell
# Console name/domain
console_name: hlf-console
console: hlf-console
console_domain: 203-0-113-42.nip.io
```


- Run the [00-complete](../../infrastructure/fabric_network_playbooks/00-complete.yml) play:
```shell

export WORKSHOP_NAMESPACE=fabricinfra

# Generate default ansible playbook properties in _cfg/
just ansible-review-config

# Start the operator and Fabric Operations Console
just ansible-operator
just ansible-console

# Construct a network and channel with ansible playbooks
just ansible-network

# The console will be available at the Nginx ingress domain alias:
echo "open https://fabricinfra-hlf-console-console.localho.st/nodes"

```

- Connect to the console URL (accept the self-signed certificate), log in as admin/password,
  and view the network structure in the Operations Console user interface.


---

[PREV: Deploy a Kube](10-kube.md) <==> [NEXT: Install Chaincode](30-chaincode.md)
