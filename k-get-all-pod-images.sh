#!/bin/bash

# Get all contexts
contexts=$(kubectl config get-contexts -o name)

# Loop through each context
for context in $contexts; do
    echo "Context: $context"
    kubectl config use-context $context

    namespaces=$(kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

    # Loop through each namespace and print the image name of each pod
    for namespace in $namespaces; do

        # Get all pods in the current namespace
        pods=$(kubectl get pods -n $namespace -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

        # Loop through each pod and print its image name
        for pod in $pods; do
            image=$(kubectl get pod $pod -n $namespace -o jsonpath='{.spec.containers[*].image}')
            echo "Context: $context, Namespace: $namespace, Pod: $pod, Image: $image"
        done

    done
done

