# Apache-2.0

# Main justfile to run all the scripts
#
# To install 'just' see https://github.com/casey/just#installation


# Ensure all properties are exported as shell env-vars
set export

# set the current directory, and the location of the test dats
CWDIR := justfile_directory()

_default:
  @just --list

bootstrap:
    #!/bin/bash



cluster_name    := "kind"


# Starts a local KIND Kubernetes cluster
# Installs Nginx ingress controller
# Adds a DNS override in kube DNS for *.localho.st -> Nginx LB IP
kind:
    #!/bin/bash
    set -eo pipefail

    set -x


    #
    # Create a local KIND cluster
    #
    cat << EOF | kind create cluster --name {{cluster_name}} --config=-
    ---
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
      - role: control-plane
        kubeadmConfigPatches:
          - |
            kind: InitConfiguration
            nodeRegistration:
              kubeletExtraArgs:
                node-labels: "ingress-ready=true"
        extraPortMappings:
          - containerPort: 80
            hostPort: 80
            protocol: TCP
          - containerPort: 443
            hostPort: 443
            protocol: TCP
    EOF


    #
    # Work around a bug in KIND where DNS is not always resolved correctly on machines with IPv6
    #
    for node in $(kind get nodes);
    do
        docker exec "$node" sysctl net.ipv4.conf.all.route_localnet=1;
    done


    #
    # Install an Nginx ingress controller bound to port 80 and 443.
    # ssl_passthrough mode is enabled for TLS termination at the Fabric node enpdoints.
    #
    kubectl apply -k https://github.com/hyperledger-labs/fabric-operator.git/config/ingress/kind
    sleep 10
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=2m


    #
    # Override Core DNS with a wildcard matcher for the "*.localho.st" domain, binding to the
    # IP address of the Nginx ingress controller on the kubernetes internal network.  Effectively this
    # "steals" the domain name for *.localho.st, directing traffic to the Nginx load balancer, rather
    # than to the loopback interface at 127.0.0.1.
    #
    CLUSTER_IP=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o json | jq -r .spec.clusterIP)

    cat << EOF | kubectl apply -f -
    ---
    kind: ConfigMap
    apiVersion: v1
    metadata:
      name: coredns
      namespace: kube-system
    data:
      Corefile: |
        .:53 {
            errors
            health {
               lameduck 5s
            }
            ready
            rewrite name regex (.*)\.localho\.st host.ingress.internal
            hosts {
              ${CLUSTER_IP} host.ingress.internal
              fallthrough
            }
            kubernetes cluster.local in-addr.arpa ip6.arpa {
               pods insecure
               fallthrough in-addr.arpa ip6.arpa
               ttl 30
            }
            prometheus :9153
            forward . /etc/resolv.conf {
               max_concurrent 1000
            }
            cache 30
            loop
            reload
            loadbalance
        }
    EOF

    kubectl -n kube-system rollout restart deployment/coredns


unkind:
    #!/bin/bash
    kind delete cluster --name {{cluster_name}}


# Installs and configures a sample Fabric Network
network:
    #!/bin/bash
    set -ex -o pipefail

    docker run --rm -u $(id -u) -v ${HOME}/.kube/:/home/ibp-user/.kube/ -v ${CWDIR}/infrastructure/fabric_network_playbooks:/playbooks -v ${CWDIR}/_cfg:/_cfg --network=host ofs-ansible:latest ansible-playbook /playbooks/00-complete.yml        


# Install the operations console
console: operator
    #!/bin/bash
    set -ex -o pipefail

    docker run --rm -v ${HOME}/.kube/:/home/ibp-user/.kube/ -v $(pwd)/infrastructure/operator_console_playbooks:/playbooks --network=host ofs-ansible:latest ansible-playbook /playbooks/01-operator-install.yml    
    docker run --rm -v ${HOME}/.kube/:/home/ibp-user/.kube/ -v $(pwd)/infrastructure/operator_console_playbooks:/playbooks --network=host ofs-ansible:latest ansible-playbook /playbooks/02-console-install.yml

    AUTH=$(curl -X POST https://fabricinfra-hlf-console-console.localho.st:443/ak/api/v2/permissions/keys -u admin:password -k -H 'Content-Type: application/json' -d '{"roles": ["writer", "manager"],"description": "newkey"}')
    KEY=$(echo $AUTH | jq .api_key | tr -d '"')
    SECRET=$(echo $AUTH | jq .api_secret | tr -d '"')

    echo "Writing authentication file for Ansible based IBP (Software) network building"
    cat << EOF > $CWDIR/_cfg/auth-vars.yml
    api_key: $KEY
    api_endpoint: http://fabricinfra-hlf-console-console.localho.st/
    api_authtype: basic
    api_secret: $SECRET
    EOF
    cat ${CWDIR}/_cfg/auth-vars.yml

# Installs just the operator
operator:
    #!/bin/bash
    pushd  ./fabric/operator-network/sample-network
    ./network operator
    popd


