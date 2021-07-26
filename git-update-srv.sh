#!/bin/bash
# 
# Update SRV records on all detected git servers.
#

gc_dns_git_server_update_srv_records_git() {
  cat db.git | grep "_git\._tcp" | sort | uniq | tee db.git.next.tmp
  
  # if [ "basename $(echo "$PWD")" != "gitcid" ]; then
  cat /etc/bind/db.git | grep "_git\._tcp" | sort | uniq | tee -a db.git.next.tmp
  # fi
    
  for i in "${gc_update_servers[@]}"; do
    echo "_git._tcp  IN      SRV     $i" | tee -a db.git.next.tmp
  done
  
  while read i; do
    echo "$i" | tee -a db.git.next
  done <db.git.next.tmp

  cp -f db.git db.git.bak

  cat db.git | grep -v "_git\._tcp" | tee db.git.tmp
  cat db.git.next | sort | uniq | tee -a db.git.tmp
  mv db.git.tmp db.git

  rm db.git.next.tmp
  rm db.git.next
  rm db.git.tmp

  git add .; git commit -m "Update SRV records."; git push
}

gc_dns_git_server_update_srv_records() {
  gc_update_servers=( )
  gc_update_servers_hostnames=( )

  for i in "$@"; do
    # echo "$i"
    for k in "$(./git-srv.sh "$i")"; do
      gc_update_servers+=( "$(echo "$k" | grep " 1234 ")" )
    done
    # gc_update_servers+=( "$(./git-srv.sh "$i" | grep " 1234 ")" )
    gc_update_servers_hostnames+=( "$i" )
  done

  for i in "${gc_update_servers[@]}"; do
    gc_update_servers_hostnames+=( "$(echo "$i" | awk '{print $NF}' | sed 's/\.$//')" )
  done

  # echo "${gc_update_servers_hostnames[@]}"

  mkdir -p workdir
  cd workdir

  current_dir="$PWD"

  for i in ${gc_update_servers_hostnames[@]}; do
    if [ ! -d "bind-${i}" ]; then
      git clone ${i}:~/git/etc/bind.git "bind-${i}" && \
      cd "bind-${i}" && \
      gc_dns_git_server_update_srv_records_git $@
      
    else
      cd "bind-${i}" || continue
      git reset --hard HEAD
      git fetch --all
      git pull
      gc_dns_git_server_update_srv_records_git $@
    fi

    cd "$current_dir"
  done

  cd ..
}

gc_dns_git_server_update_srv_records $@
