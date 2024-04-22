#!/bin/bash

# List of tenant IDs to iterate over
# tenants=("72faf3ff-7a3f-4597-b0d9-7b0b201bb23a" "0bb99d84-39d8-4221-9917-59f51dbf106c" "5935a4a6-4b63-47b6-9b5c-42f340be9e7a")
subscriptions=("Solutions-Sandbox" "Engineering-Sandbox")
for subscription in "${subscriptions[@]}"
do
    echo "Switching to subscription $subscription"
    az account set --subscription "$subscription"

    # Get all resource groups in the current tenant
    resource_groups=$(az group list --query '[].name' -o tsv)

    # Loop through each resource group
    for rg in $resource_groups
    do
        echo "Checking resource group $rg in subscription $subscription"
        # Get all AKS clusters in the current resource group
        clusters=$(az aks list --resource-group "$rg" --query '[].name' -o tsv)

        # Loop through each cluster
        for cluster in $clusters
        do
            echo "Adding AKS $cluster from subscription $subscription to kubeconfig"
            # Get the credentials for the AKS cluster and merge them into your kubeconfig
            # add metadata to the context:
            # az aks get-credentials --resource-group "$rg" --name "$cluster" --file ~/.kube/config --overwrite-existing --context "$cluster-aks-$subscription"
            # or just the cluster name:
            az aks get-credentials --resource-group "$rg" --name "$cluster" --file ~/.kube/config --overwrite-existing --context "$cluster"
        done
    done
done