## Prerequesites

### minikube

Install minikube.

minikube start --kubernetes-version=v1.26.7 (compatible with kyverno v1.10.0)

There was the following message:
/usr/bin/kubectl is version 1.28.2, which may have incompatibilities with Kubernetes 1.26.7.
    ▪ Want kubectl v1.26.7? Try 'minikube kubectl -- get pods -A'

I ran the above command and it installed kubctl v1.26.7.

### cosign

There was a change in cosign v2.2.0 about dsse kind. Kyverno currently only supports the older version.
Error message will be `invalid kind value: "dsse"`.

Insall cosign v2.1.1: `go install github.com/sigstore/cosign/v2/cmd/cosign@v2.1.1`

`alias kubectl="minikube kubectl --"`

## Installation

Check compatibilty with k8 version https://kyverno.io/docs/installation/

kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.10.0/install.yaml

Requires 1.24 < k8 < 1.26

Build the CLI https://kyverno.io/docs/kyverno-cli/#building-the-cli-from-source:

```
git clone https://github.com/kyverno/kyverno
cd kyverno
make build-cli
mv ./cmd/cli/kubectl-kyverno/kubectl-kyverno /usr/local/bin/kyverno
```

They use standard labels https://kubernetes.io/docs/reference/labels-annotations-taints/
The recommended list is https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/

## Policies

From https://kyverno.io/docs/kyverno-policies/: Policies can be defined as cluster-wide resources (using the kind ClusterPolicy) or namespaced resources (using the kind Policy.) 

From https://kyverno.io/docs/applying-policies/:
- Rules in a policy are applied in the order of definition 
- namespaced policies cannot override or modify behaviors described in a cluster-wide policy.

From https://kyverno.io/docs/writing-policies/validate/: For preexisting resources which violate a newly-created policy set to Enforce mode, Kyverno will allow subsequent updates to those resources which continue to violate the policy as a way to ensure no existing resources are impacted. However, should a subsequent update to the violating resource(s) make them compliant, any further updates which would produce a violation are blocked.

Patterns are described in https://kyverno.io/docs/writing-policies/validate/

There is support to sign config file with Sigstore for apply to accept https://kyverno.io/docs/writing-policies/validate/#manifest-validation

Variables enabled references to data in the policy definition, the [admission review request](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#request), and external data sources like ConfigMaps, the Kubernetes API Server, OCI image registries, and even external service calls https://kyverno.io/docs/writing-policies/variables/ and https://kyverno.io/docs/writing-policies/external-data-sources/. More details on admission review in https://kyverno.io/docs/writing-policies/variables/#variables-from-admission-review-requests. We can query running objects, e.g. `kubectl get po busybox -o jsonpath='{.metadata.annotations}'`

Pre-defined variables https://kyverno.io/docs/writing-policies/variables/#pre-defined-variables

Variables for images: https://kyverno.io/docs/writing-policies/variables/#variables-from-container-images

Inline variables https://kyverno.io/docs/writing-policies/variables/#inline-variables

We can use `$(./../../name/bla/resource)` to navigate the definition fields; and comparison operators are supported https://kyverno.io/docs/writing-policies/variables/#variables-from-policy-definitions

Beware when using Helm, we need to wrap variables https://kyverno.io/docs/writing-policies/variables/#variables-in-helm

ConfigMap and server API variables https://kyverno.io/docs/writing-policies/external-data-sources/

By default, Kyverno automatically generates policies for controllers that use the object the original policy applies to, e.g. use pods https://kyverno.io/docs/writing-policies/autogen/. But Kyverno skips generating Pod controller rules whenever the following resources fields/objects are specified in a match or exclude block as these filters may not be applicable to Pod controllers: names, selector, annotations. Use preconditions to always benefit from auto generation.

We can use both all and any operators together, see https://kyverno.io/docs/writing-policies/preconditions/#any-and-all-statements

https://kyverno.io/docs/writing-policies/tips/: The choice between using a pattern statement or a deny statement depends largely on the data you need to consider; pattern works on incoming (new) objects while deny can additionally work on variable data such as the API operation (CREATE, UPDATE, etc.), old object data, and ConfigMap data.

When verifying images, certain keywoards are available https://kyverno.io/docs/writing-policies/verify-images/sigstore/#special-variables

### Apply

https://kyverno.io/docs/kyverno-cli/#apply

WARNING: pods won't be stopped if a new policy is applied to them while they're _already_ running.

We need to installa policy, then updated to the cluster will follow that policy.

### Continuous Integration

https://kyverno.io/docs/testing-policies/#continuous-integration

## Keyless

https://kyverno.io/docs/writing-policies/verify-images/

## Troubleshooting

List installed policies: `kubectl get cpol`

List policy reports: `kubectl get polr`

Info about policy results: `kubectl get polr <policy-name> -o jsonpath='{.results}' | jq`

pod logs, ie what's printed: `kubectl logs <pod-name>`

https://kyverno.io/docs/writing-policies/tips/: `kubectl get kyverno -A`


https://kyverno.io/docs/policy-reports/

kubectl get policyreport -A
kubectl get clusterpolicyreport

kubectl get polr cpol-slsa-keyless -o jsonpath='{.results}' | jq

https://kyverno.io/docs/troubleshooting/

See https://kyverno.io/docs/troubleshooting/#policies-are-partially-applied to show logs:

```
kubectl -n kyverno logs <pod-name>
```

If not enough, use https://kyverno.io/docs/troubleshooting/#policy-definition-not-working

What helped for me:

```
kubectl get pods -A
kubectl -n kyverno logs -f kyverno-admission-controller-797db4757c-lt5gf (different terminal)
kubectl apply -f kyverno/policy-keyless.yml
```

## Testing

https://kyverno.io/docs/kyverno-cli/ allows testing policies outside the cluster.

Was not able to use that properly. I'd like a debug log to see why a policy fails. Is it format validation or the policy evaluation itself?

## Notes

Default namespaces https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/#initial-namespaces

Init containers https://kubernetes.io/docs/concepts/workloads/pods/init-containers/

Ephemeral containers https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/
