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


# Main justfile to run all the scripts
#
# To install 'just' see https://github.com/casey/just#installation


# Ensure all properties are exported as shell env-vars
set export

# set the current directory, and the location of the test dats
CWDIR := justfile_directory()

_default:
  @just -f {{justfile()}}  --list

bootstrap:
    #!/bin/bash


cluster_name := "kind"

# Starts a local KIND Kubernetes cluster
# Installs Nginx ingress controller
# Adds a DNS override in kube DNS for *.localho.st -> Nginx LB IP
kind:
    infrastructure/kind_with_nginx.sh {{cluster_name}}
    ls -lart ~/.kube/config
    chmod o+r ~/.kube/config

unkind:
    #!/bin/bash
    kind delete cluster --name {{cluster_name}}
    docker kill kind-registry
    docker rm kind-registry