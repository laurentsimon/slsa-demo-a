#!/bin/bash

set -euo pipefail

deploy_policy() {
    local deloyment_name="${1}"
    local policy_name="${2}"
    result=$(kubectl get deploy 2>&1 | grep "${deloyment_name}" || true)
    if [[ "${result}" != "" ]]; then
        # Delete the delpoyment.
        kubectl delete -f k8/"${deloyment_name}".yml
    fi

    result=$(kubectl get configmaps 2>&1 | grep "configuration" || true)
    if [[ "${result}" != "" ]]; then
        # Delete the delpoyment.
        kubectl delete -f kyverno/policy-vsa-configuration.yml
    fi

    # Apply the config map.
    kubectl apply -f kyverno/policy-vsa-configuration.yml

    # Apply the policy.
    kubectl apply -f kyverno/"${policy_name}".yml

    # Apply the deployment.
    kubectl apply -f k8/"${deloyment_name}".yml
}

deploy_policy "echo-server-deployment" "policy-vsa-pubkey"