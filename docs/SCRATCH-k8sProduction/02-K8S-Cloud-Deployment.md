## Kubernetes Cloud Deployments

Use the sample approach of running playbooks as was done with Kind, with other K8S Clusters; Though there are variations

In summary - this is running these two ansible playbooks; PLEASE have the latest and greatest Ansible collections clone and built *first*
Suggest that you copy the two playbooks and vars file to a temporary directory; remembering to update the link in the playbooks to the varaibles file

- Creation of the operator: `ansible-playbook ./infrastructure/01-operator-install.yml`
```
- name: Deploy Opensource custom resource definitions and operator
  hosts: localhost
  vars_files:
    - /_cfg/operator-console-vars.yml
  vars:
    state: present
    wait_timeout: 3600
  roles:
    - ibm.blockchain_platform.fabric_operator_crds
```


- Creation of the console:  `ansible-playbook ./infrastructure/02-console-install.yml`
---
- name: Deploy Opensource Console
  hosts: localhost
  vars_files:
    - /_cfg/operator-console-vars.yml
  vars:
    state: present
    wait_timeout: 3600
  roles:
    - ibm.blockchain_platform.fabric_console


- Update the `./infrastructure/configuration/operator-console-vars.yml` as per the notes below
### IKS

1) In the operator-console-vars.yml update the following:

```
storage_class: ibmc_file_gold
```

2) Then create the operator

3) We need to set the `CONSOLE_DOMAIN` 

```
export INGRESS_IPADDR=$(kubectl -n ingress-nginx get svc/ingress-nginx-controller -o json | jq -r '.status.loadBalancer.ingress[0].ip')
export CONSOLE_DOMAIN=fabricinfra-hlf-console-console.$(echo $INGRESS_IPADDR | tr -s '.' '-')
echo $CONSOLE_DOMAIN
```

Note - I've no idea why the ingress subdomain indicated by the IKS dashboard doesn't work.. it used to....

Then update the `console_domain` in the `operator-console-vars.yml` to the value of `CONSOLE_DOMAIN`

4) start the console