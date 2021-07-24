#!/bin/bash

# If your GitWeb servers take extra time 
# to respond, you can increase this value
# from the default of 10 seconds detection
# timeout.
GC_LOCAL_SERVER_DETECT_TIMEOUT=${GC_LOCAL_SERVER_DETECT_TIMEOUT:-10}

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

# for i in ${GC_NEW_GIT_SERVERS[@]}; do
#   echo "$i"
# done

for i in "`./git-srv.sh`"; do
	GC_ACTIVE_GIT_SERVERS+=( "$(echo "$i" | sed 's/\.$//g' | awk '{print "http://"$NF":"$(NF-1)}' 2>/dev/null)" )
done

echo "$(for i in ${GC_ACTIVE_GIT_SERVERS[@]}; do echo "$i"; done)" | sort | uniq
