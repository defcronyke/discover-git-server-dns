#!/bin/bash
# 
# List SRV records on all detected git servers.
#

tasks=( )

gc_dns_git_server_list_servers_cleanup() {
  for i in ${tasks[@]}; do echo ""; echo "Cancelling task: $i"; kill $i 2>/dev/null; done; for i in $(jobs -p); do echo ""; echo "Cancelling task: $i"; kill $i 2>/dev/null; done
}

gc_dns_git_server_list_servers_self() {
  dig +time=1 +tries=3 +short +nocomments @$(hostname) _git._tcp.git SRV 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

  dig +time=1 +tries=3 +short +nocomments _git._tcp.git SRV 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"
  # res4=$?

  # dig +time=1 +tries=3 +short +nocomments @$(hostname) _git._tcp.git SRV 2>/dev/null | \
  # sed 's/;; connection timed out; no servers could be reached//g' | \
  # grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"
  # res5=$?

  # if [ $res5 -eq 0 ]; then
  #   if [ $res4 -ne 0 ]; then
  #     return $res4
  #   else
  #     return $res5
  #   fi
  # fi

  # return $res5
}

gc_dns_git_server_list_servers_guess() {
  dig +time=1 +tries=3 +short +nocomments @git _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

  if [ $# -ge 1 ]; then
    dig +time=1 +tries=3 +short +nocomments @git${1} _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

    dig +time=1 +tries=3 +short +nocomments @ns${1} _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

    # if [ $# -ge $1 ]; then
    n=0
    for i in $@; do
      if [ $n -lt $1 ]; then
        ((n++))
        continue
      fi
      dig +time=1 +tries=3 +short +nocomments @$i _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"
      break
    done
    # fi

    if [ $1 -ge $GC_MAX_NUM_SERVERS_TO_TRY ]; then
      return 12
    fi
  else
    dig +time=1 +tries=3 +short +nocomments @git1 _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

    dig +time=1 +tries=3 +short +nocomments @ns1 _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

      return 12
  fi

  return 0
}

gc_dns_git_server_list_servers_init() {
  GC_MAX_NUM_SERVERS_TO_TRY=${GC_MAX_NUM_SERVERS_TO_TRY:-8}
  # GC_MIN_NUM_SERVERS_TO_TRY=${GC_MIN_NUM_SERVERS_TO_TRY:-2}

  gc_dns_git_server_list_servers_self $@ & tasks+=( "$!" )

  n=1
  # count=0
  while [ $n -le $GC_MAX_NUM_SERVERS_TO_TRY ]; do
    # echo "$n"
    gc_dns_git_server_list_servers_guess $n $@ & tasks+=( "$!" )
    ((n++))
  done

  while [ true ]; do
    for k in ${tasks[@]}; do
      wait $k
      if [ $? -eq 12 ]; then
        return 0
      fi
    done
  done
}

gc_dns_git_server_list_servers_all() {
  gc_found_servers=( )
  gc_found_hostnames=( )

  if [ $# -ge 1 ]; then
    # for i in "$@"; do
    for k in "$(gc_dns_git_server_list_servers_init "$@" | sort | uniq)"; do
      gc_found_servers+=( "$k" )
      gc_found_hostnames+=( "$(echo "$k" | awk '{print $NF}' | sed 's/\.$//')" )
    done

    # dig +time=1 +tries=3 +short +nocomments _git._tcp.git SRV 2>/dev/null | \
    # sed 's/;; connection timed out; no servers could be reached//g' | \
    # grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" && \
    #   gc_found_hostnames+=( "$@" )

    # dig +time=1 +tries=3 +short +nocomments @$i _git._tcp.git SRV 2>/dev/null | \
    # sed 's/;; connection timed out; no servers could be reached//g' | \
    # grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" && \
    #   gc_found_hostnames+=( "$i" )
    # done

  else
    for k in "$(gc_dns_git_server_list_servers_init | sort | uniq)"; do
      gc_found_servers+=( "$k" )
      gc_found_hostnames+=( "$(echo "$k" | awk '{print $NF}' | sed 's/\.$//')" )
    done
  fi

  for i in "${gc_found_servers[@]}"; do
    echo "$i"
    # gc_found_hostnames+=( "$(echo "$i" | awk '{print $NF}' | sed 's/\.$//')" )
  done
}

gc_dns_git_server_list_servers() {
  trap 'gc_dns_git_server_list_servers_cleanup $@; return 2;' INT

  gc_dns_git_server_list_servers_all $@ | sort | uniq | grep -v -e '^[[:space:]]*$'
  list_servers_res=$?

  gc_dns_git_server_list_servers_cleanup $@

  return $list_servers_res
}

gc_dns_git_server_list_servers $@
