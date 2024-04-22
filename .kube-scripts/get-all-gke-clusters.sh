#!/bin/bash

# Get a list of all regions using gcloud
regions=$(gcloud container clusters list --format="[no-heading](location)"|sort -u)

# Loop through each region
for region in $regions; do
    # Get a list of clusters in the current region
    echo "Getting clusters in region $region"
    clusters=$(gcloud container clusters list --zone="$region" --format="value(name)")

    # Loop through each cluster and add it to kubeconfig
    for cluster in $clusters; do
        echo "Adding cluster $cluster in region $region to kubeconfig"
        gcloud container clusters get-credentials "$cluster" --zone="$region"
        # kubectl config rename-context "$(kubectl config current-context)" "$cluster-$region-gke"
        kubectl config rename-context "$(kubectl config current-context)" "$cluster"
    done
done

echo "All clusters from all regions added to kubeconfig!"