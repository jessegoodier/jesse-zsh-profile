#!/bin/bash

# PROFILE="EngineeringDeveloper"
# PROFILE="EngineeringAdmin"
# Get all AWS regions
regions=$(aws ec2 describe-regions --region us-east-2 --profile "$PROFILE" --query 'Regions[].RegionName' --output text)

# Loop through each region
for region in $regions
do
    echo "Checking region $region"
    # Get all EKS cluster names in the current region
    clusters=$(aws eks list-clusters --profile "$PROFILE" --region "$region" --query 'clusters' --output text)

    # Loop through each cluster
    for cluster in $clusters
    do
        # Update the kubeconfig file for each cluster with an alias that is just the cluster name
        if [[ "$PROFILE" == "EngineeringDeveloper" ]]; then
            aws eks update-kubeconfig --profile "$PROFILE" --region "$region" --name "$cluster" --alias "$cluster-eks"
        else
            aws eks update-kubeconfig --profile "$PROFILE" --region "$region" --name "$cluster" --alias "$cluster-$PROFILE"
        fi

    done
done
