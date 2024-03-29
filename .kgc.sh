#!/bin/bash

## This is a function. use it by sourcing it in your shell and calling one of the functions
## source .kgc.sh
## run it without and argument to get the current namespace
## kgc all will run it against all namespaces.
## Currently maintained here:
## <https://github.com/jessegoodier/jesse-zsh-profile/>

# The name kgc is because it is like the alias `kgp` for kubectl get pods
# kgc is to k get containers
# it also prints related errors to help identify the cause of failing containers
# Add to your profile by sourcing this file in your .zshrc or .bashrc
# source ~/.kgc.sh
# unalias kgc 2> /dev/null # < if you have a less useful alias for kgc already, put this before the source line

function kgc {
# k get containers, show failures

# get the namespace from the first argument, otherwise use the current namespace
namespace_arg=$1
issue_counter=0

if [[ -z "$namespace_arg" ]]; then
  namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
else
  namespace=$namespace_arg
fi

declare -a current_failures

namespace_column=0

# Get all pods in the namespace
if [[ $namespace_arg == "all" ]]; then
  pods_json=$(kubectl get pods -o json -A| jq '.items[] | {namespace: .metadata.namespace, name: .metadata.name, status: .status.phase, containers: .status.containerStatuses}')
  namespace_list=($(echo "$pods_json" | jq -r '.namespace'))
  # Figure out the table spacing with namespace
  for namespace_name in "${namespace_list[@]}"; do
    namespace_chars=${#namespace_name}
    if (( namespace_chars > namespace_column )); then
      namespace_column=$namespace_chars
    fi
  done

else
  # pods_json=$(kubectl get pods -n "$namespace" -o json | jq '.items[] | {namespace: .metadata.namespace, name: .metadata.name, status: .status.phase, containers: .status.containerStatuses}')
  pods_json=$(kubectl get pods -n "$namespace" -o json | jq '.items[] | {namespace: .metadata.namespace, name: .metadata.name, status: .status.phase, containers: .status.containerStatuses}')
fi

pod_list=($(echo "$pods_json" | jq -r '.name'))

# Figure out the table spacing
pod_column=4 # needs to be at least as long as the word "Pod"
for pod_name in "${pod_list[@]}"; do
  pod_chars=${#pod_name}
  if (( pod_chars > pod_column )); then
    pod_column=$pod_chars
  fi
done

container_list=($(echo "$pods_json" | jq -r 'select(.containers != null) | .containers[].name'))

container_column=15 # needs to be at least as long as the words "Container Name"
for container_name in "${container_list[@]}"; do
  column_width=${#container_name}
  if (( column_width > container_column )); then
    container_column=$column_width
  fi
done

if [[ ${pod_column} -gt 0 ]]; then
  print_table_header
else
  printf "\033[0;33mNo pods found in %s namespace\033[0m\n" "$namespace"
fi

for pod in "${pod_list[@]}"; do
  num_containers_in_this_pod=$(echo "$pods_json" | jq -r ".| select(.name == \"$pod\") |.containers| length")
  if [[ $namespace_arg == "all" ]]; then
    namespace=$(echo "$pods_json" | jq -r ".| select(.name == \"$pod\") |.namespace")
    ns_col=$namespace
  else
    ns_col=""
  fi

  if [ "$num_containers_in_this_pod" -lt 1 ]; then
    ((issue_counter+=1))
    printf "\033[0;31m%-${namespace_column}s %-${pod_column}s %-${container_column}s %-${status_column}s\033[0m\n" "$ns_col" "$pod" "-" "false ($issue_counter)"
    current_failures+=("$pod" "$namespace")
    continue
  fi

  containers_in_this_pod_json=$(echo "$pods_json" | jq -r ".| select(.name == \"$pod\") |.containers[]")
  containers_in_this_pod_list=($(echo "$containers_in_this_pod_json" | jq -r ".name"))
  for container_name in "${containers_in_this_pod_list[@]}"; do
    container_ready=$(echo "$containers_in_this_pod_json" | jq -r ".| select(.name == \"$container_name\") |.ready")

    if [[ "$container_ready" == "true" ]]; then
      printf "\033[32m%-${namespace_column}s %-${pod_column}s %-${container_column}s %-${status_column}s\n\033[0m" "$ns_col" "$pod" "$container_name" "$container_ready"
    else
      terminated_reason=$(echo "$pods_json" | jq -r ".| select(.name == \"$pod\") |.containers[0].state.terminated.reason")
      if [[ "$terminated_reason" == "Completed" ]]; then
        printf "\033[32m%-${namespace_column}s %-${pod_column}s %-${container_column}s %-${status_column}s\n\033[0m" "$ns_col" "$pod" "$container_name" "$terminated_reason"
      else
        if [[ $(echo "$pods_json" | jq -r ".| select(.name == \"$pod\") .status") == "Pending" ]]; then
          printf "\033[0;33m%-${namespace_column}s %-${pod_column}s %-${container_column}s %-${status_column}s\033[0m\n" "$ns_col" "$pod" "$container_name" "Pending"
        else
          ((issue_counter+=1))
          printf "\033[0;31m%-${namespace_column}s %-${pod_column}s %-${container_column}s %-${status_column}s\033[0m\n" "$ns_col" "$pod" "$container_name" "$terminated_reason ($issue_counter)"
          current_failures+=("$pod" "$namespace")
        fi
      fi
    fi
  done
done

# Print any pods with failing containers
if [[ ${#current_failures[@]} -gt 0 ]]; then
  printf "\nPods with failing containers:\n"
  index=1
  for ((i=1; i<${#current_failures[@]}; i+=2)); do
    pod=${current_failures[i]} 
    namespace=${current_failures[i+1]}
    printf "\033[0;31m%s\033[0m\033[0;36m%s\033[0m\n" "($index)" " Namespace:$namespace - Pod:$pod"
    get_failure_events $pod $namespace
    # printf "\033[0;36m%s\033[0m\n" "$(get_failure_events $pod $namespace)"
    index=$((index+1))
  done
fi

replica_sets=$(kubectl get replicaset -n "$namespace" -o json)
replica_sets_with_unavailable_replicas=($(jq -r '.items[] | select(.status.replicas <.spec.replicas) |.metadata.name' <<< "$replica_sets"))

if [[ ${#replica_sets_with_unavailable_replicas[@]} -gt 0 ]]; then
  printf "\nUnavailable ReplicaSets:\n"
  for replica_set in "${replica_sets_with_unavailable_replicas[@]}"; do
    printf "\033[0;31m%s\033[0m: \033[0;36m%s\033[0m\n" "$replica_set" "$(get_failure_events $replica_set $namespace)"
  done
fi
}

function get_failure_events() {
  # print $1 $2
  kubectl get events -n $2 --sort-by=lastTimestamp --field-selector type!=Normal,involvedObject.name=$1
}

function print_table_header() {
  status_column=10
  if [[ $namespace_arg == "all" ]]; then
    printf "%-${namespace_column}s %-${pod_column}s %-${container_column}s %-${status_column}s\n" "namespace" "Pod" "Container Name" "Ready"
  else
    printf "\033[0;37m%s\033[0m: \033[0;36m%s\033[0m\n" "NAMESPACE" "$namespace"
    printf " %-${pod_column}s %-${container_column}s %-${status_column}s\n" "Pod" "Container Name" "Ready"
  fi
}
