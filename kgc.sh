#!/bin/zsh

# quick command to find out what is failing in your namespace.
# like the alias `kgp` for kubectl get pods
# kgc is to k get containers
# it also prints related errors to help fix.
# Add to your zsh profile like:
# https://github.com/jessegoodier/jesse-zsh-profile/blob/main/.zshrc#L39
# or download and source kgc.sh
# this was written for zsh, but you can have AI change it to bash

function kgc {
# k get containers, show failures

# get the namespace from the first argument, otherwise use the current namespace
NAMESPACE=$1

if [[ -z "$NAMESPACE" ]]; then
  NAMESPACE=$(kubectl config view --minify --output 'jsonpath={..namespace}')
fi
printf "\033[0;37m%s\033[0m: \033[0;36m%s\033[0m\n" "NAMESPACE" "$NAMESPACE"

# If CURRENT_FAILURES is not declared or not an array, declare it as an array
if [ -z "${CURRENT_FAILURES+x}" ] || ! declare -p CURRENT_FAILURES 2> /dev/null | grep -q '^declare -a'; then
  declare -a CURRENT_FAILURES
fi

# Get all pods in the namespace
pods=($(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}'))

# Figure out the table spacing
for i in $pods; do
  # Get the length of the current string
  length=${#i}
  # If this length is greater than the max length, update max length
  if (( length > pod_length )); then
    pod_length=$length
  fi
done
container_length=30
status_length=10
# Print table header
printf "%-${pod_length}s %-${container_length}s %-${status_length}s\n" "Pod" "Container Name" "Container Status"

# Loop over pods
for pod in $pods; do

  # Get container statuses for each pod
  pod_container_statuses=($(kubectl get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.status.containerStatuses}'))
  container_list=($(echo "$pod_container_statuses" | jq -r '.[].name'))

  # Loop over container statuses
  for container_name in $container_list; do

    container_status=$(echo "$pod_container_statuses" | jq -r ".[] | select(.name == \"$container_name\") |.state| keys[0]")

    # Print table row
    if [ "$container_status" != "running" ]; then
      printf "\033[0;31m%-${pod_length}s %-${container_length}s %-${status_length}s\033[0m\n" "$pod" "$container_name" "$container_status"
      # Append $pod to the array
      CURRENT_FAILURES+=("$pod")
    else
      printf "\033[32m%-${pod_length}s %-${container_length}s %-${status_length}s\n\033[0m" "$pod" "$container_name" "$container_status"
    fi

  done
done

# Print any pods with failing containers
if [[ ${#CURRENT_FAILURES[@]} -gt 0 ]]; then
  printf "\nPods with failing containers:\n"
  for pod in "${CURRENT_FAILURES[@]}"; do
    printf "\033[0;31m%s\033[0m\n" "$pod:"
    printf "\033[0;36m%s\033[0m\n" "$(get-failure-events-for-resource $pod)"
  done
fi


# Get all ReplicaSets in JSON format
replica_sets=$(kubectl get replicaset -n $NAMESPACE -o json)

# Use jq to filter ReplicaSets where '.status.replicas' (current) is less than '.spec.replicas' (desired)
replica_sets_with_unavailable_replicas=($(jq -r '.items[] | select(.status.replicas <.spec.replicas) |.metadata.name' <<< "$replica_sets"))

# Print any unavailable ReplicaSets
if [[ ${#replica_sets_with_unavailable_replicas[@]} -gt 0 ]]; then
  printf "\nUnavailable ReplicaSets:\n"
  for replica_set in $replica_sets_with_unavailable_replicas; do
    printf "\033[0;31m%s\033[0m: \033[0;36m%s\033[0m\n" "$replica_set" "$(get-failure-events-for-resource $replica_set)"
  done
fi
}
function get-failure-events-for-resource() {
  kubectl get events --sort-by=lastTimestamp --field-selector type!=Normal,involvedObject.name=$1 -ojson|jq -r '.items.[].message'
}