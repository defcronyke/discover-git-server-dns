#!/bin/bash

GC_NEW_GIT_SERVERS_TEST=( )
GC_NEW_GIT_SERVERS=( )

for i in $@; do
  gc_new_git_server_hostname="$(echo "$i" | cut -d: -f1 | cut -d@ -f2)"
  cat "$HOME/.ssh/config" 2>/dev/null | grep "$gc_new_git_server_hostname" | grep -i hostname >/dev/null 2>&1 && gc_new_git_server_hostname="$(cat "$HOME/.ssh/config" 2>/dev/null | grep "$gc_new_git_server_hostname" | grep -i hostname | xargs 2>/dev/null | awk '{print $2}' 2>/dev/null)"

  GC_NEW_GIT_SERVERS_TEST+=( "$(printf 'http://%s:1234\n' "$gc_new_git_server_hostname")" )
done

for i in ${GC_NEW_GIT_SERVERS_TEST[@]}; do
  curl -m 3 "$i" >/dev/null 2>&1 && \
    GC_NEW_GIT_SERVERS+=( "$i" )
done

for i in ${GC_NEW_GIT_SERVERS[@]}; do
  echo "$i"
done

for i in "`./git-srv.sh`"; do
	echo "$i" | sed 's/\.$//g' | awk '{print "http://"$NF":"$(NF-1)}' 2>/dev/null
done
