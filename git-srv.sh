#!/bin/bash
# 
# List SRV records on all detected git servers.
#

gc_dns_git_server_list_servers_init() {
  GC_MAX_NUM_SERVERS_TO_TRY=${GC_MAX_NUM_SERVERS_TO_TRY:-100}
  
  trap 'return 1;' INT

  dig +timeout=2 +short +nocomments @$(hostname) _git._tcp.git SRV 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  grep -v -e '^[[:space:]]*$'

  if [ $? -ne 0 ]; then
    n=1

    while [ $n -le $GC_MAX_NUM_SERVERS_TO_TRY ]; do
      dig +timeout=2 +short +nocomments @git${n} _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -v -e '^[[:space:]]*$' && \
        break

      ((n++))
    done
  fi
}

gc_dns_git_server_list_servers_all() {
  gc_found_servers=( )
  gc_found_hostnames=( )

  gc_found_servers+=( "$(gc_dns_git_server_list_servers_init $@ | sort | uniq)" )
  gc_found_hostnames+=( "$(echo "${gc_found_servers[@]}" | awk '{print $NF}' | sed 's/\.$//')" )

  echo "${gc_found_servers[@]}"

  k=0
  for i in ${gc_found_hostnames[@]}; do
    dig +timeout=2 +short +nocomments @$i _git._tcp.git SRV 2>/dev/null | \
    sed 's/;; connection timed out; no servers could be reached//g' | \
    grep -v -e '^[[:space:]]*$'

    ((k++))
  done
}

gc_dns_git_server_list_servers() {
  gc_dns_git_server_list_servers_all $@ | sort | uniq
}

gc_dns_git_server_list_servers $@
