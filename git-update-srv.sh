#!/bin/bash
# 
# Update SRV records on all detected git servers.
#

gc_dns_git_server_update_srv_records_git() {
  cat db.git | grep "_git\._tcp\.git\." | sort | uniq | tee db.git.next.tmp
    
  echo "${gc_update_servers[@]}" | tee -a db.git.next.tmp


  while read i; do
    echo "_git._tcp  IN      SRV     $i" | tee -a db.git.next
  done <db.git.next.tmp

  cp -f db.git db.git.bak

  cat db.git | grep -v "_git\._tcp\.git\." | tee db.git.tmp
  cat db.git.next | sort | uniq | tee -a db.git.tmp
  mv db.git.tmp db.git

  rm db.git.next.tmp
  rm db.git.next
  rm db.git.tmp

  git add .; git commit -m "Update SRV records."; git push
}

gc_dns_git_server_update_srv_records() {
  gc_update_servers=( )
  gc_update_servers+=( "$(./git-srv.sh $@ | grep " 1234 ")" )
  
  gc_update_servers_hostnames=( )
  gc_update_servers_hostnames+=( "$(echo "${gc_update_servers[@]}" | awk '{print $NF}' | sed 's/\.$//')" )

  echo "${gc_update_servers_hostnames[@]}"

  mkdir -p workdir
  cd workdir

  tasks=( )

  current_dir="$PWD"

  for i in ${gc_update_servers_hostnames[@]}; do
    if [ ! -d "bind-${i}" ]; then
      git clone ${i}:~/git/etc/bind.git "bind-${i}" && \
      cd "bind-${i}" && \
      gc_dns_git_server_update_srv_records_git $@
      
    else
      cd "bind-${i}" || continue
      git fetch --all
      git pull
      gc_dns_git_server_update_srv_records_git $@
    fi

    cd "$current_dir"
  done

  cd ..
}

gc_dns_git_server_update_srv_records $@
