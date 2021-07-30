#!/usr/bin/env bash
# 
# List SRV records on all detected git servers.
#

tasks=( )

tasks_srv=( )

gc_dns_git_server_list_servers_cleanup() {
  for i in ${tasks[@]}; do echo ""; echo "Cancelling task: $i"; kill $i 2>/dev/null; done; for i in ${tasks_srv[@]}; do echo ""; echo "Cancelling task: $i"; kill $i 2>/dev/null; done; for i in $(jobs -p); do echo ""; echo "Cancelling task: $i"; kill $i 2>/dev/null; done
}

gc_dns_git_server_list_servers_self() {
  dig +time=1 +tries=1 +short +nocomments @$(hostname) _git._tcp.git SRV 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

  dig +time=1 +tries=1 +short +nocomments _git._tcp.git SRV 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

  dig +time=1 +tries=1 +short +nocomments @$(ip route ls | head -n 1 | sed 's/^\(.*via\s\)\(.*\)$/\2/g' | awk '{print $1}') _git._tcp.git SRV 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"
}

gc_dns_git_server_list_servers_guess() {
  # Check default Raspberry Pi OS hostname first "raspberrypi".
  dig +time=1 +tries=1 +short +nocomments @raspberrypi _git._tcp.git SRV 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

  dig +time=1 +tries=1 +short +nocomments @ns _git._tcp.git SRV 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"
  
  dig +time=1 +tries=1 +short +nocomments @git _git._tcp.git SRV 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

  if [ $# -ge 1 ]; then
    dig +time=1 +tries=1 +short +nocomments @ns${1} _git._tcp.git SRV 2>/dev/null | \
    sed 's/;; connection timed out; no servers could be reached//g' | \
    grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

    dig +time=1 +tries=1 +short +nocomments @git${1} _git._tcp.git SRV 2>/dev/null | \
    sed 's/;; connection timed out; no servers could be reached//g' | \
    grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

    # if [ $# -ge $1 ]; then
    n=0
    for i in $@; do
      if [ $n -lt $1 ]; then
        ((n++))
        continue
      fi
      dig +time=1 +tries=1 +short +nocomments @$i _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"
      break
    done
    # fi

    if [ $1 -ge $GC_MAX_NUM_SERVERS_TO_TRY_SRV ]; then
      return 12
    fi
  else
    dig +time=1 +tries=1 +short +nocomments @ns1 _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"
    
    dig +time=1 +tries=1 +short +nocomments @git1 _git._tcp.git SRV 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$"

      return 12
  fi

  return 0
}





gc_dns_git_server_list_servers_self_ns() {
  dig +time=1 +tries=1 +short +nocomments @$(hostname) git NS 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  sed 's/\.$//'

  dig +time=1 +tries=1 +short +nocomments git NS 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  sed 's/\.$//'

  dig +time=1 +tries=1 +short +nocomments @$(ip route ls | head -n 1 | sed 's/^\(.*via\s\)\(.*\)$/\2/g' | awk '{print $1}') git NS 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  sed 's/\.$//'
}

gc_dns_git_server_list_servers_guess_ns() {
  # Check default Raspberry Pi OS hostname first "raspberrypi".
  dig +time=1 +tries=1 +short +nocomments @raspberrypi git NS 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  sed 's/\.$//'

  dig +time=1 +tries=1 +short +nocomments @ns git NS 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  sed 's/\.$//'
  
  dig +time=1 +tries=1 +short +nocomments @git git NS 2>/dev/null | \
  sed 's/;; connection timed out; no servers could be reached//g' | \
  sed 's/\.$//'

  if [ $# -ge 1 ]; then
    dig +time=1 +tries=1 +short +nocomments @ns${1} git NS 2>/dev/null | \
    sed 's/;; connection timed out; no servers could be reached//g' | \
    sed 's/\.$//'

    dig +time=1 +tries=1 +short +nocomments @git${1} git NS 2>/dev/null | \
    sed 's/;; connection timed out; no servers could be reached//g' | \
    sed 's/\.$//'

    # if [ $# -ge $1 ]; then
    n=0
    for i in $@; do
      if [ $n -lt $1 ]; then
        ((n++))
        continue
      fi

      dig +time=1 +tries=1 +short +nocomments @$i git NS 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      sed 's/\.$//'

      break
    done
    # fi

    if [ $1 -ge $GC_MAX_NUM_SERVERS_TO_TRY ]; then
      return 12
    fi
  else
    dig +time=1 +tries=1 +short +nocomments @ns1 git NS 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      sed 's/\.$//'
    
    dig +time=1 +tries=1 +short +nocomments @git1 git NS 2>/dev/null | \
      sed 's/;; connection timed out; no servers could be reached//g' | \
      sed 's/\.$//'

      return 12
  fi

  return 0
}





gc_dns_git_server_list_servers_init() {
  GC_MAX_NUM_SERVERS_TO_TRY=${GC_MAX_NUM_SERVERS_TO_TRY:-3}

  gc_dns_git_server_list_servers_self_ns $@ & tasks+=( "$!" )

  # gc_dns_git_server_list_servers_self $@ & tasks+=( "$!" )

  n=1
  while [ $n -le $GC_MAX_NUM_SERVERS_TO_TRY ]; do

    gc_dns_git_server_list_servers_guess_ns $n $@ & tasks+=( "$!" )

    # gc_dns_git_server_list_servers_guess $n $@ & tasks+=( "$!" )
  
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



gc_dns_git_server_list_servers_init_srv() {
  GC_MAX_NUM_SERVERS_TO_TRY_SRV=${GC_MAX_NUM_SERVERS_TO_TRY_SRV:-3}

  # gc_dns_git_server_list_servers_self_ns $@ & tasks+=( "$!" )

  gc_dns_git_server_list_servers_self $@ & tasks_srv+=( "$!" )

  n=1
  while [ $n -le $GC_MAX_NUM_SERVERS_TO_TRY_SRV ]; do

    # gc_dns_git_server_list_servers_guess_ns $n $@ & tasks+=( "$!" )

    gc_dns_git_server_list_servers_guess $n $@ & tasks_srv+=( "$!" )
  
    ((n++))
  done

  while [ true ]; do
    for k in ${tasks_srv[@]}; do
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

    # dig +time=1 +tries=1 +short +nocomments _git._tcp.git SRV 2>/dev/null | \
    # sed 's/;; connection timed out; no servers could be reached//g' | \
    # grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" && \
    #   gc_found_hostnames+=( "$@" )

    # dig +time=1 +tries=1 +short +nocomments @$i _git._tcp.git SRV 2>/dev/null | \
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



gc_dns_git_server_list_servers_srv() {
  gc_found_servers_srv=( )
  gc_found_hostnames_srv=( )

  if [ $# -ge 1 ]; then
    # for i in "$@"; do
    for k in "$(gc_dns_git_server_list_servers_init_srv "$@" | sort | uniq)"; do
      gc_found_servers_srv+=( "$k" )
      gc_found_hostnames_srv+=( "$(echo "$k" | awk '{print $NF}' | sed 's/\.$//')" )
    done

    # dig +time=1 +tries=1 +short +nocomments _git._tcp.git SRV 2>/dev/null | \
    # sed 's/;; connection timed out; no servers could be reached//g' | \
    # grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" && \
    #   gc_found_hostnames+=( "$@" )

    # dig +time=1 +tries=1 +short +nocomments @$i _git._tcp.git SRV 2>/dev/null | \
    # sed 's/;; connection timed out; no servers could be reached//g' | \
    # grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" && \
    #   gc_found_hostnames+=( "$i" )
    # done

  else
    for k in "$(gc_dns_git_server_list_servers_init_srv | sort | uniq)"; do
      gc_found_servers_srv+=( "$k" )
      gc_found_hostnames_srv+=( "$(echo "$k" | awk '{print $NF}' | sed 's/\.$//')" )
    done
  fi

  for i in "${gc_found_servers_srv[@]}"; do
    echo "$i"
    # gc_found_hostnames+=( "$(echo "$i" | awk '{print $NF}' | sed 's/\.$//')" )
  done
}



# gc_dns_git_server_list_servers() {
#   trap 'gc_dns_git_server_list_servers_cleanup $@; return 2;' INT

#   gc_found_nameservers=( )
  
#   for i in $(gc_dns_git_server_list_servers_all $@ | sort | uniq | grep -v -e '^[[:space:]]*$'); do
#     gc_found_nameservers+=( "$i" )
#   done
  
#   # list_servers_res=$?


#   gc_dns_git_server_list_servers_srv ${gc_found_nameservers[@]} | sort | uniq | grep -v -e '^[[:space:]]*$'
#   list_servers_res=$?


#   gc_dns_git_server_list_servers_cleanup $@

#   return $list_servers_res
# }



gc_dns_git_server_list_servers() {
  trap 'gc_dns_git_server_list_servers_cleanup $@; return 2;' INT

  gc_found_nameservers=( )
  
  # for i in $(gc_dns_git_server_list_servers_all $@ | sort | uniq | grep -v -e '^[[:space:]]*$'); do
  #   gc_found_nameservers+=( "$i" )
  # done
  
  # list_servers_res=$?


  gc_dns_git_server_list_servers_srv $@ | sort | uniq | grep -v -e '^[[:space:]]*$'
  list_servers_res=$?


  gc_dns_git_server_list_servers_cleanup $@

  unset GC_MAX_NUM_SERVERS_TO_TRY_SRV
  unset GC_MAX_NUM_SERVERS_TO_TRY

  return $list_servers_res
}




gc_dns_git_server_list_servers $@
