#!/bin/bash
# 
# List SRV records on all detected git servers.
#

tasks=( )

gc_dns_git_server_list_servers_cleanup() {
  for i in "${tasks[@]}"; do echo "cancelling task: $i"; kill $i; done; for i in $(jobs -p); do echo "cancelling task: $i"; kill $i; done
}

gc_dns_git_server_list_servers_self() {
  dig +time=2 +short +nocomments _git._tcp.git SRV 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  grep -P "^_git\._tcp.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+$"

  dig +time=2 +short +nocomments @$(hostname) _git._tcp.git SRV 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  grep -P "^_git\._tcp.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+$"
}

gc_dns_git_server_list_servers_guess() {
  if [ $# -ge 1 ]; then
    dig +time=2 +short +nocomments @git$1 _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -P "^_git\._tcp.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+$"
  fi
}

gc_dns_git_server_list_servers_init() {
  GC_MAX_NUM_SERVERS_TO_TRY=${GC_MAX_NUM_SERVERS_TO_TRY:-10}

  trap 'gc_dns_git_server_list_servers_cleanup $@; return 2;' INT

  { gc_dns_git_server_list_servers_self $@; return $?; } & tasks+=( "$!" )

  n=1
  while [ $n -le $GC_MAX_NUM_SERVERS_TO_TRY ]; do
    { gc_dns_git_server_list_servers_guess $n $@; return $?; } & tasks+=( "$!" )
    ((n++))
  done

  # while [ true ]; do
  for i in "$(jobs -p)"; do
    # for k in ${tasks[@]}; do
    wait "$i" || \
      return 0
    # done
  done
  # done
}

gc_dns_git_server_list_servers_all() {
  gc_found_servers=( )
  gc_found_hostnames=( )

  if [ $# -ge 1 ]; then
    for i in "$@"; do
      for k in "$(gc_dns_git_server_list_servers_init "$i" | sort | uniq)"; do
        gc_found_servers+=( "$k" )
        gc_found_hostnames+=( "$(echo "$k" | awk '{print $NF}' | sed 's/\.$//')" )
      done

      dig +time=2 +short +nocomments _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -P "^_git\._tcp.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+$" && \
        gc_found_hostnames+=( "$i" )

      dig +time=2 +short +nocomments @$i _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -P "^_git\._tcp.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+$" && \
        gc_found_hostnames+=( "$i" )
    done

  else
    for k in "$(gc_dns_git_server_list_servers_init | sort | uniq)"; do
      gc_found_servers+=( "$k" )
      gc_found_hostnames+=( "$(echo "$k" | awk '{print $NF}' | sed 's/\.$//')" )
    done
  fi

  # for i in "${gc_found_servers[@]}"; do
  #   echo "$i"
  #   gc_found_hostnames+=( "$(echo "$i" | awk '{print $NF}' | sed 's/\.$//')" )
  # done

  # echo "${gc_found_servers[@]}"

  # k=0
  # for i in "${gc_found_hostnames[@]}"; do
  #   dig +timeout=2 +short +nocomments @$i _git._tcp.git SRV 2>/dev/null | \
  #   sed 's/;; connection timed out; no servers could be reached//g' | \
  #   grep -v -e '^[[:space:]]*$'

  #   ((k++))
  # done
}

gc_dns_git_server_list_servers() {
  gc_dns_git_server_list_servers_all $@ | sort | uniq | grep -v -e '^[[:space:]]*$'
  list_servers_res=$?

  gc_dns_git_server_list_servers_cleanup $@

  return $list_servers_res
}

gc_dns_git_server_list_servers $@
