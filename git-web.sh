#!/usr/bin/env bash

# If your GitWeb servers take extra time 
# to respond, you can increase this value
# from the default n seconds detection
# timeout.

discover_git_server_dns_git_web() {
  GC_LOCAL_SERVER_DETECT_TIMEOUT=${GC_LOCAL_SERVER_DETECT_TIMEOUT:-6}

  GC_NEW_GIT_SERVERS_TEST=( )
  GC_NEW_GIT_SERVERS=( )
  GC_ACTIVE_GIT_SERVERS=( )

  for i in $@; do
    gc_new_git_server_hostname="$(echo "$i" | cut -d: -f1 | cut -d@ -f2)"
    cat "$HOME/.ssh/config" 2>/dev/null | grep "$gc_new_git_server_hostname" | grep -i hostname >/dev/null 2>&1 && gc_new_git_server_hostname="$(cat "$HOME/.ssh/config" 2>/dev/null | grep "$gc_new_git_server_hostname" | grep -i hostname | xargs 2>/dev/null | awk '{print $2}' 2>/dev/null)"

    GC_NEW_GIT_SERVERS_TEST+=( "$(printf 'http://%s:1234\n' "$gc_new_git_server_hostname")" )
  done

  for i in ${GC_NEW_GIT_SERVERS_TEST[@]}; do
    curl -m $GC_LOCAL_SERVER_DETECT_TIMEOUT "$i" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      GC_NEW_GIT_SERVERS+=( "$i" )
      GC_ACTIVE_GIT_SERVERS+=( "$i" )
    fi
  done

  gc_servers=( )

  for i in "$(./git-srv.sh)"; do
    # echo "$i"
    if [ ! -z "$i" ]; then
      gc_servers+=( "$(echo "$i" | grep -P "[[:space:]]+1234[[:space:]]+" | sed 's/\.$//' | awk '{print "http://"$NF":"$(NF-1)}' 2>/dev/null | sed 's/^\(.*:\/\/.*\)\..*\(:.*\)$/\1\2/')" )
    fi

    for j in ${gc_servers[@]}; do
      # echo "$j"
      curl -m $GC_LOCAL_SERVER_DETECT_TIMEOUT "$j" >/dev/null 2>&1
      if [ $? -eq 0 ]; then
        GC_ACTIVE_GIT_SERVERS+=( "$j" )
      fi
    done
  done

  echo "$(for i in ${GC_ACTIVE_GIT_SERVERS[@]}; do echo "$i"; done)" | grep -v -e "^[[:space:]]*$" | sort | uniq
}

discover_git_server_dns_git_web
