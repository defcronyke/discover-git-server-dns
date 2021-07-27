#!/bin/bash
# 
# Update SRV records on all detected git servers.
#

gc_dns_git_server_update_srv_records_git() {
  cat db.git | grep -P "^_git\._tcp\.*.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+\.$" | sort | uniq | tee db.git.next.tmp
  
  cat /etc/bind/db.git 2>/dev/null | grep -P "^_git\._tcp\.*.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+\.$" | sort | uniq | tee -a db.git.next.tmp

  for i in "$@"; do
    echo "_git._tcp  IN      SRV     5 10 1234 $i." | tee -a db.git.next.tmp
  done
    
  for i in "${gc_update_servers[@]}"; do
    echo "_git._tcp  IN      SRV     $i" | tee -a db.git.next.tmp
  done
  
  while read i; do
    echo "$i" | tee -a db.git.next
  done <db.git.next.tmp

  cp -f db.git db.git.bak

  cat db.git | grep -vP "^_git\._tcp\.*.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+\.$" | tee db.git.tmp

  # current_dir2="$PWD"

  # cd "$current_dir"
    
  # cd "$current_dir2"

  # Add NS records.
  for i in "$@"; do
    cat db.git.tmp | grep -P "^.+[[:space:]]+IN[[:space:]]+NS[[:space:]]+$i.$" >/dev/null || \
    echo "@       IN      NS      $i." | tee -a db.git.tmp
  done
  
  cat db.git.next | grep -P "^_git\._tcp\.*.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+\.$" | sort | uniq | tee -a db.git.tmp
  mv db.git.tmp db.git

  rm db.git.next.tmp
  rm db.git.next
  rm db.git.tmp

  git add .; git commit -m "Update SRV records."; git push

  # Add A records.
  for k in "${gc_update_servers_hostnames[@]}"; do
    # cd "bind-${k}"

    while read n; do
      cat db.git | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | grep -P "$(echo "$n" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" >/dev/null || \
      cat db.git | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | \
      tee -a ../bind-${k}/db.git.tmp
    done <../bind-${k}/db.git

    mv ../bind-${k}/db.git.tmp ../bind-${k}/db.git
    rm ../bind-${k}/db.git.tmp

    git --git-dir="${PWD}/../bind-${k}/.git" --work-tree="${PWD}/../bind-${k}" add .
    git --git-dir="${PWD}/../bind-${k}/.git" --work-tree="${PWD}/../bind-${k}" commit -m "Update peer A records."
    git --git-dir="${PWD}/../bind-${k}/.git" --work-tree="${PWD}/../bind-${k}" push

    while read n; do
      cat ../bind-${k}/db.git | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | grep -P "$(echo "$n" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" >/dev/null || \
      cat ../bind-${k}/db.git | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | \
        tee -a db.git.tmp2
    done <db.git

    mv db.git.tmp2 db.git
    rm db.git.tmp2
    
    # for n in "$(cat db.git | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+")"; do
    # done

    # cd "$current_dir"
  done

  git add .; git commit -m "Update A records."; git push
}

gc_dns_git_server_update_srv_records() {
  gc_update_servers=( )
  gc_update_servers_hostnames=( )

  for i in "$@"; do
    # echo "$i"
    for k in "$(./git-srv.sh "$i")"; do
      gc_update_servers+=( "$(echo "$k" | grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+\.$")" )
    done
    # gc_update_servers+=( "$(./git-srv.sh "$i" | grep " 1234 ")" )

    gc_server_hostname="$(echo "$i" | grep -v -e '^[[:space:]]*$')"

    dig +time=2 +short +nocomments @$gc_server_hostname _git._tcp.git SRV 2>/dev/null | \
    sed 's/;; connection timed out; no servers could be reached//g' | \
    grep -v -e '^[[:space:]]*$'
    if [ $? -eq 0 ]; then
      gc_update_servers_hostnames+=( "$gc_server_hostname" )
    fi
  done

  # for i in "${gc_update_servers[@]}"; do
  #   gc_update_servers_hostnames+=( "$(echo "$i" | awk '{print $NF}' | sed 's/\.$//')" )
  # done

  # echo "${gc_update_servers_hostnames[@]}"

  rm -rf workdir
  mkdir -p workdir
  cd workdir

  current_dir="$PWD"

  for i in "${gc_update_servers_hostnames[@]}"; do
    if [ ! -d "bind-${i}" ]; then
      git clone ${i}:~/git/etc/bind.git "bind-${i}" && \
      cd "bind-${i}" && \

      gc_dns_git_server_update_srv_records_git $gc_update_servers_hostnames
      
    else
      cd "bind-${i}" || continue
      git reset --hard HEAD
      # git fetch --all
      git pull

      gc_dns_git_server_update_srv_records_git $gc_update_servers_hostnames
    fi

    cd "$current_dir"
  done

  cd "$current_dir"/..
}

gc_dns_git_server_update_srv_records $@
gc_dns_git_server_update_srv_records $@
