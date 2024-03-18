## This is a function. use it by sourcing it in your shell and calling one of the functions
## source .kgc.zsh
## kgc (namespace)
## kgc all will run it against all namespaces.
## This is the zsh version. see .kgc.bash here for the bash version
## <https://github.com/jessegoodier/jesse-zsh-profile/>

# The name kgc is because it is like the alias `kgp` for kubectl get pods
# kgc is to k get containers
# it also prints related errors to help fix.

# Add to your zsh profile like:
# https://github.com/jessegoodier/jesse-zsh-profile/blob/main/.zshrc#L39

function kgc {
# k get containers, show failures

# get the namespace from the first argument, otherwise use the current namespace
namespace=$1

# if the namespace is "all" run kgc-all function
if [[ $namespace == "all" ]]; then
  kgc-all
  return
fi

if [[ -z "$namespace" ]]; then
  namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
fi
printf "\033[0;37m%s\033[0m: \033[0;36m%s\033[0m\n" "NAMESPACE" "$namespace"

# If current_failures is not declared or not an array, declare it as an array
if [ -z "${current_failures+x}" ] || ! declare -p current_failures 2> /dev/null | grep -q '^declare -a'; then
  declare -a current_failures
fi

# Get all pods in the namespace
# pods=($(kubectl get pods -n "$namespace" -o jsonpath='{.items[*].metadata.name}'))
pods_json=($(kubectl get pods -n "$namespace" -o json | jq '.items[] | {name: .metadata.name, status: .status.phase, containers: .status.containerStatuses}'))
pod_list=($(echo "$pods_json" | jq -r '.name'))

# Figure out the table spacing
pod_column=0
for pod_name in "$pod_list[@]"; do
  # Get the length of the current string
  pod_chars=${#pod_name}
  # If this length is greater than the max length, update max length
  if (( pod_chars > pod_column )); then
    pod_column=$pod_chars
  fi
done

# Array of containers in namespace
container_list=($(echo "$pods_json" | jq -r 'select(.containers != null) | .containers.[].name'))

# Loop over containers to get the column spacing
container_column=0
for container_name in $container_list; do
  # Get the length of the current string
  column_width=${#container_name}
  # If this length is greater than the max length, update max length
  if (( column_width > container_column )); then
    container_column=$column_width
  fi
done

# If we have pods, print the table header, otherwise print a message that there are no pods in the namespace
if [[ ${pod_column} -gt 0 ]]; then
  print_table_header
else
  printf "\033[0;33mNo pods found in $namespace namespace\033[0m\n"
fi

# Loop over pods
for pod in $pod_list; do

  # check if this pod has any containers
    num_containers_in_this_pod=$(echo "$pods_json" | jq -r ".| select(.name == \"$pod\") |.containers| length")

  # If no containers in the pod, print the pod name and status, move to next pod
    if [ "$num_containers_in_this_pod" -lt 1 ]; then
      printf "\033[0;31m%-${pod_column}s %-${container_column}s %-${status_column}s\033[0m\n" "$pod" "-" "false ($(( ${#current_failures[@]} + 1 )))"
      current_failures+=("$pod")
      continue
    fi

  # get a list of containers in the pod
  containers_in_this_pod_json=($(echo "$pods_json" | jq -r ".| select(.name == \"$pod\") |.containers.[]"))
  # echo "containers_in_this_pod: $containers_in_this_pod"
  containers_in_this_pod_list=($(echo "$containers_in_this_pod_json" | jq -r ".name"))
  for container_name in $containers_in_this_pod_list; do

    # get the status of the container
    container_ready=$(echo "$containers_in_this_pod_json" | jq -r ".| select(.name == \"$container_name\") |.ready")

    # Print table row
    if [[ "$container_ready" == "true" ]]; then
      printf "\033[32m%-${pod_column}s %-${container_column}s %-${status_column}s\n\033[0m" "$pod" "$container_name" "$container_ready"
    else
      # check if the pod is Completed, which is green
      terminated_reason=$(echo "$pods_json" | jq -r ".| select(.name == \"$pod\") |.containers[0].state.terminated.reason")
      if [[ "$terminated_reason" == "Completed" ]]; then
        printf "\033[32m%-${pod_column}s %-${container_column}s %-${status_column}s\n\033[0m" "$pod" "$container_name" "$terminated_reason - "
      else
        # check if the pod is pending, make it yellow
        if [[ $(echo "$pods_json" | jq -r ".| select(.name == \"$pod\") .status") == "Pending" ]]; then
          printf "\033[0;33m%-${pod_column}s %-${container_column}s %-${status_column}s\033[0m\n" "$pod" "$container_name" "Pending ($(( ${#current_failures[@]} + 1 )))"
          current_failures+=("$pod")
        else
          # every other status falls here
          printf "\033[0;31m%-${pod_column}s %-${container_column}s %-${status_column}s\033[0m\n" "$pod" "$container_name" "$terminated_reason ($(( ${#current_failures[@]} + 1 )))"
          # Append $pod to the array
          current_failures+=("$pod")
        fi
      fi
    fi
  done
done

# Print any pods with failing containers
if [[ ${#current_failures[@]} -gt 0 ]]; then
  printf "\nPods with failing containers:\n"
  index=1
  for pod in "${current_failures[@]}"; do
    printf "\033[0;31m%s\033[0m\n" "($index) - $pod:"
    printf "\033[0;36m%s\033[0m\n" "$(get_failure_events $pod)"
    index=$((index+1))
  done
fi

# Get all ReplicaSets in JSON format
replica_sets=$(kubectl get replicaset -n $namespace -o json)

# Use jq to filter ReplicaSets where '.status.replicas' (current) is less than '.spec.replicas' (desired)
replica_sets_with_unavailable_replicas=($(jq -r '.items[] | select(.status.replicas <.spec.replicas) |.metadata.name' <<< "$replica_sets"))

# Print any unavailable ReplicaSets
if [[ ${#replica_sets_with_unavailable_replicas[@]} -gt 0 ]]; then
  printf "\nUnavailable ReplicaSets:\n"
  for replica_set in $replica_sets_with_unavailable_replicas; do
    printf "\033[0;31m%s\033[0m: \033[0;36m%s\033[0m\n" "$replica_set" "$(get_failure_events $replica_set)"
  done
fi
}
function get_failure_events() {
  # Short status message:
  # kubectl get events -n $namespace  --sort-by=lastTimestamp --field-selector type!=Normal,involvedObject.name=$1 -ojson|jq -r '.items.[].message'
  # if you want to see the full events list, this will be faster too:
  # kubectl get events -n $namespace --sort-by=lastTimestamp --field-selector type!=Normal
  # Default output:
  kubectl get events -n $namespace --sort-by=lastTimestamp --field-selector type!=Normal,involvedObject.name=$1
}

function print_table_header() {
  status_column=10
  printf "%-${pod_column}s %-${container_column}s %-${status_column}s\n" "Pod" "Container Name" "Ready"
}

function kgc-all() {
  # loop through all namespaces
  printf "\033[0;36m%s\033[0m\n" "Getting containers in all namespaces"
  namespaces=($(kubectl get ns -o jsonpath='{.items[*].metadata.name}'))
  for ns in "$namespaces[@]"; do kgc "$ns"; done
}