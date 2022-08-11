# Beta Ansible Playbooks

The v2.0.0-beta Ansible Collection for Hyperledger Fabric is required. This isn't yet being published.
So it must be built to get support for the Fabric Operator and Fabric console

```
git clone https://github.com/IBM-Blockchain/ansible-collection.git  
cd ansible-collection

# to extract a PR eg 616, use these commands
#git fetch origin pull/616/head:latest
#git checkout latest


docker build -t ofs-ansible .

```

You can also build the collection locally.

```
cd ansible-collection
poetry shell
just local
```