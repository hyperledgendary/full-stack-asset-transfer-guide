#!/usr/bin/env bash

SUCCESS="✅"
WARN="⚠️ "
EXIT=0

if ! command -v jq &> /dev/null
then
    echo "${WARN} Please install jq: https://stedolan.github.io/jq/download/"
    EXIT=1
else
    echo "${SUCCESS} jq found: $(jq --version)"
fi

if ! command -v kubectl &> /dev/null
then
    echo "${WARN} Please install kubectl: https://kubernetes.io/docs/tasks/tools/#kubectl"
    EXIT=1
else
    echo "${SUCCESS} kubectl found:"
    echo "$(kubectl version --client -oyaml)"
fi

exit $EXIT