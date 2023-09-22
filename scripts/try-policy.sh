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

    result=$(kubectl get configmaps 2>&1 | grep "organization" || true)
    if [[ "${result}" != "" ]]; then
        # Delete the delpoyment.
        kubectl delete -f kyverno/policy-vsa-configuration.yml
    fi

    result=$(kubectl get configmaps 2>&1 | grep "team" || true)
    if [[ "${result}" != "" ]]; then
        # Delete the delpoyment.
        kubectl delete -f kyverno/policy-vsa-repository1.yml
    fi

    # Apply the org config map.
    kubectl apply -f kyverno/policy-vsa-configuration.yml

     # Apply the repo config map.
    kubectl apply -f kyverno/policy-vsa-repository1.yml

    # Apply the policy.
    kubectl apply -f kyverno/"${policy_name}".yml

    # Apply the deployment.
    kubectl apply -f k8/"${deloyment_name}".yml
}

deploy_policy "echo-server-deployment" "policy-vsa-pubkey"