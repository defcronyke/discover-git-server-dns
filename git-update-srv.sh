#!/bin/bash
# 
# Update SRV records on all detected git servers.
#

gc_dns_git_server_update_srv_records() {
  gc_update_servers=( )
  gc_update_servers+=( "$(./git-srv.sh $@ | grep " 1234 ")" )
  
  gc_update_servers_hostnames=( )
  gc_update_servers_hostnames+=( "$(echo "${gc_update_servers[@]}" | awk '{print $NF}' | sed 's/\.$//')" )

  # echo "${gc_update_servers_hostnames[@]}"

  mkdir -p workdir
  cd workdir

  tasks=( )

  for i in ${gc_update_servers_hostnames[@]}; do
    if [ ! -d "bind-${i}" ]; then
      git clone ${i}:~/git/etc/bind.git "bind-${i}"
      cd "bind-${i}"
      
    else
      cd "bind-${i}"
      git fetch --all
      git pull
    fi

    cat db.git | grep "_git\._tcp\.git\." | sort | uniq | tee db.git.next.tmp
      
    echo "${gc_update_servers[@]}" | tee -a db.git.next.tmp

    cat db.git.next.tmp | sort | uniq | tee db.git.next

    cp -f db.git db.git.bak

    cat db.git | grep -v "_git\._tcp\.git\." | tee db.git
    cat db.git.next | tee -a db.git

    rm db.git.next.tmp
    rm db.git.next

    git add .; git commit -m "Update SRV records."; git push

    cd ..
  done

  cd ..
}

gc_dns_git_server_update_srv_records $@
