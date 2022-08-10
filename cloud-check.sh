#!/usr/bin/env bash

SUCCESS="✅"
WARN="⚠️ "

if ! command -v jq &> /dev/null
then
    echo "${WARN} Please install jq: https://stedolan.github.io/jq/download/"
else
    echo "${SUCCESS} jq found: $(jq --version)"
fi

if ! command -v kubectl &> /dev/null
then
    echo "${WARN} Please install kubectl: https://kubernetes.io/docs/tasks/tools/#kubectl"
else
    echo "${SUCCESS} kubectl found:"
    echo "$(kubectl version --client -oyaml)"
fi
