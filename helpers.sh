# k8s shell helpers — source this file, don't execute it

# Print current cluster and namespace
curtns() {
    local ns cluster
    ns=$(kubectl config view --minify --output 'jsonpath={..namespace}')
    cluster=$(kubectl config view --minify --output 'jsonpath={..contexts[0].context.cluster}' | cut -d "/" -f2)
    echo "$cluster | $ns"
}

# Set the namespace for the current context
setns() {
    if [[ -z "${1:-}" ]]; then
        echo "Usage: setns <namespace>"
        return 1
    fi
    kubectl config set-context --current --namespace="$1"
}
