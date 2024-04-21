#!/bin/bash

# Get all contexts

cp ~/.kube/config ./kubeconfig
KUBECONFIG=./kubeconfig

contexts=$(kubectl config get-contexts -o name)

# Loop through each context
for context in $contexts; do
    echo "Context: $context"
    kubectl config use-context $context

    # Check if the context is working
    if kubectl get pods &> /dev/null; then
        echo "Context $context is working"
    else
        echo "Context $context is not working"
        kubectl config delete-context $context
        echo "--------------Context $context has been removed------------------"
    fi

    echo ""
done
unset KUBECONFIG

k-remove-bad-contexts() { # remove dead contexts
cp ~/.kube/config ./kubeconfig-"`date +"%d-%m-%Y-%H-%M-%S"`"
contexts=$(kubectl config get-contexts -o name)

# Loop through each context
for context in $contexts; do
    echo "Context: $context"
    kubectl config use-context $context

    # Check if the context is working
    if kubectl get pods &> /dev/null; then
        echo "Context $context is working"
    else
        echo "Context $context is not working"
        kubectl config delete-context $context
        echo "--------------Context $context has been removed------------------"
    fi

    echo ""
done
}
