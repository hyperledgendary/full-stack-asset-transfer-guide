#!/bin/bash
#
# Copyright contributors to the Hyperledgendary Full Stack Asset Transfer project
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
# 	  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -eo pipefail
set -x

function kind_with_nginx() {
  local cluster_name=$1

  delete_cluster $cluster_name

  create_cluster $cluster_name

  start_nginx

  apply_coredns_override

  launch_docker_registry
}


#
# Delete a kind cluster if it exists
#
function delete_cluster() {
  local cluster_name=$1

  kind delete cluster --name $cluster_name
}


#
# Create a local KIND cluster
#
function create_cluster() {
  local cluster_name=$1
  local reg_port=5000
  local reg_name=kind-registry

  local reg_name=kind-registry
  local reg_port=5000

  cat << EOF | kind create cluster --name $cluster_name --config=-
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

# create a cluster with the local registry enabled in containerd
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_name}:${reg_port}"]
EOF

  #
  # Work around a bug in KIND where DNS is not always resolved correctly on machines with IPv6
  #
  for node in $(kind get nodes);
  do
      docker exec "$node" sysctl net.ipv4.conf.all.route_localnet=1;
  done
}


#
# Install an Nginx ingress controller bound to port 80 and 443.
# ssl_passthrough mode is enabled for TLS termination at the Fabric node enpdoints.
#
function start_nginx() {
  kubectl apply -k https://github.com/hyperledger-labs/fabric-operator.git/config/ingress/kind

  sleep 10

  kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=2m
}


#
# Override Core DNS with a wildcard matcher for the "*.localho.st" domain, binding to the
# IP address of the Nginx ingress controller on the kubernetes internal network.  Effectively this
# "steals" the domain name for *.localho.st, directing traffic to the Nginx load balancer, rather
# than to the loopback interface at 127.0.0.1.
#
function apply_coredns_override() {
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
}

function launch_docker_registry() {
  
  # create registry container unless it already exists
  local reg_name=kind-registry
  local reg_port=5000

  running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
  if [ "${running}" != 'true' ]; then
    docker run \
      -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" \
      registry:2
  fi

  # connect the registry to the cluster network
  # (the network may already be connected)
  docker network connect "kind" "${reg_name}" || true

  # Document the local registry
  # https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
  cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

  
}

kind_with_nginx $1