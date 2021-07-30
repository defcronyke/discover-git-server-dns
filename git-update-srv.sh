#!/usr/bin/env bash
# 
# Update SRV records on all detected git servers.
#

gc_dns_git_server_update_srv_records_git() {
  git pull origin master

  cp -f db.git db.git.next.tmp2
  # cp -f /etc/bind/db.git db.git.next.tmp3

  rm db.git.next.tmp

  cat db.git.next.tmp2 | grep -P "^_git\._tcp.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+$" | sort | uniq | \
  tee -a db.git.next.tmp

  rm db.git.next.tmp2
  
  # cat db.git.next.tmp3 | grep -P "^_git\._tcp.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+[[:space:]]+.+$" | sort | uniq | \
  # tee -a db.git.next.tmp

  # rm db.git.next.tmp3

  for i in "$@"; do
    echo "_git._tcp  IN      SRV     5 10 1234 $i" | \
    tee -a db.git.next.tmp
  done
    
  for i in "${gc_update_servers[@]}"; do
    echo "_git._tcp  IN      SRV     $(echo "$i" | sed 's/\.$//')" | \
    tee -a db.git.next.tmp
  done
  
  # while read i; do
  #   echo "$i" | tee -a db.git.next
  # done <db.git.next.tmp

  # cp -f db.git db.git.bak

  cat db.git.next.tmp2 | grep -vP "^_git\._tcp.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" | \
  tee -a db.git.tmp

  # current_dir2="$PWD"

  # cd "$current_dir"
    
  # cd "$current_dir2"

  cp -f db.git.tmp db.git.tmp2

  # Add NS records.
  for i in "$@"; do
    cat db.git.tmp2 | grep -P "^.+[[:space:]]+IN[[:space:]]+NS[[:space:]]+$i.*$" || \
    echo "@       IN      NS      $i" | tee -a db.git.tmp
  done

  cp -f db.git.tmp db.git.tmp2

  for i in ${gc_update_servers_hostnames[@]}; do
    # parsed_server="$(echo "$i" | awk '{print }')"
    cat db.git.tmp2 | grep -P "^.+[[:space:]]+IN[[:space:]]+NS[[:space:]]+$i.*$" || \
    echo "@       IN      NS      $i" | tee -a db.git.tmp
  done

  rm db.git.tmp2

  
  cat db.git.next | grep -P "^_git\._tcp.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" | sort | uniq | \
  tee -a db.git.tmp
  
  cp -f db.git.tmp db.git

  # mv db.git.tmp db.git

  rm db.git.next.tmp
  rm db.git.next
  # rm db.git.tmp

  git add .; git commit -m "Update NS and SRV records."; git push -u origin master

  # git add .; git commit -m "Update NS and SRV records."; git pull origin master; git push -u origin master

  # git add .; git commit -m "Update SRV records."; git push

  current_dir2="$PWD"
  



  git pull origin master

  # Add A records.
  # for j in "$@"; do
  for k in ${gc_update_servers_hostnames[@]}; do
    mkdir -p ${HOME}/.ssh
    chmod 700 ${HOME}/.ssh
    # ssh-keygen -F "$k" || ssh-keyscan "$k" >>${HOME}/.ssh/known_hosts

    if [ "$k" == "$(hostname)" ]; then
      continue
    fi

    # cd "bind-${k}"
    cd ..

    if [ ! -d "bind-${k}" ]; then
      git clone ${k}:~/git/etc/bind.git bind-${k} && \
      cd "bind-${k}"
      if [ $? -ne 0 ]; then
        echo ""
        echo "ERROR: Failed cloning repo: ${k}:~/git/etc/bind.git"
        echo ""
        cd "$current_dir2"
        continue
      fi
    else
      cd "bind-${k}" || continue
      git reset --hard HEAD
      git pull origin master
      if [ $? -ne 0 ]; then
        echo ""
        echo "ERROR: Failed pulling repo: ${k}:~/git/etc/bind.git"
        echo ""
        # cd "$current_dir2"
        # continue
      fi
    fi

    cp -f db.git db.git.tmp

    while read n; do
      cat "${current_dir2}/db.git" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | grep -P "^$n$" || \
      cat "${current_dir2}/db.git" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | grep -P "^$n$" | \
      tee -a db.git.tmp
      # tee -a ../bind-${k}/db.git.tmp
    done <db.git

    # cp -f db.git.tmp db.git 

    # cat "${current_dir2}/db.git" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | grep -P "$(echo "`hostname`" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" >/dev/null || \
    # cat "${current_dir2}/db.git" | grep -P "$(echo "`hostname`" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" | \
    # tee -a db.git.tmp

    # cat db.git | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | grep -P "$(echo "`hostname`" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" >/dev/null || \
    # cat db.git | grep -P "$(echo "`hostname`" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" | \
    # tee -a db.git.tmp

    cp -f db.git db.git.bak

    cp -f db.git.tmp db.git
    # mv db.git.tmp db.git

    # cat ${current_dir2}/db.git | grep -P "^`hostname`.*[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" >/dev/null || \
    
    # cat db.git.tmp | grep -P "^`hostname`.*[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | sed "s/^.+\([[:space:]]+IN[[:space:]]+A[[:space:]]+.+\)$/`hostname`\.\1/g" | \
    # tee -a db.git

    # cat ../bind-${k}/db.git.tmp | sed "s/^@/$(hostname)/g" | tee -a ../bind-${k}/db.git


    # mv ../bind-${k}/db.git.tmp ../bind-${k}/db.git
    
    
    # rm db.git.tmp

    git add .
    git commit -m "Update peer A records."
    # git pull origin master
    git push -u origin master

    cd "$current_dir2"
  done



  # for k in ${gc_update_servers_hostnames[@]}; do
  #   cd "$current_dir2"

  #   git reset --hard HEAD
  #   git pull origin master
  #   if [ $? -ne 0 ]; then
  #     echo ""
  #     echo "ERROR: Failed pulling repo: ~/git/etc/bind.git"
  #     echo ""
  #     # cd "$current_dir2"
  #     # continue
  #   fi

  #   cd ..

  #   cd "bind-${k}" || continue
  #   git reset --hard HEAD
  #   git pull origin master
  #   if [ $? -ne 0 ]; then
  #     echo ""
  #     echo "ERROR: Failed pulling repo: ${k}:~/git/etc/bind.git"
  #     echo ""
  #     # cd "$current_dir2"
  #     # continue
  #   fi

  #   cd "$current_dir2"


  #   while read n; do
  #     cat ./bind-${k}/db.git | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | grep -P "$(echo "$n" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" >/dev/null || \
  #     cat ./bind-${k}/db.git | grep -P "$(echo "$n" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" | \
  #     tee -a db.git.tmp
  #     # tee -a ../bind-${k}/db.git.tmp
  #   done <db.git

  #   cat ./bind-${k}/db.git | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | grep -P "$(echo "`hostname`" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" >/dev/null || \
  #   cat ./bind-${k}/db.git | grep -P "$(echo "`hostname`" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" | \
  #   tee -a db.git.tmp

  #   cat db.git | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | grep -P "$(echo "`hostname`" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" >/dev/null || \
  #   cat db.git | grep -P "$(echo "`hostname`" | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" | \
  #   tee -a db.git.tmp

  #   cp -f db.git db.git.bak

  #   mv db.git.tmp db.git


  #   # while read n; do
  #   #   cat ../bind-${k}/db.git | grep -P "^@[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | grep -P "$(echo "$n" | grep -P "^@[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$")" >/dev/null || \
  #   #   cat ../bind-${k}/db.git | grep -P "^@[[:space:]]+IN[[:space:]]+A[[:space:]]+.+$" | \
  #   #   tee -a db.git.tmp2
  #   # done <db.git

  #   # cat db.git | grep -P "$(cat db.git.tmp2 | sed "s/^@/$k/g")" >/dev/null || \
  #   # cat db.git.tmp2 | sed "s/^@/$k\./g" | tee -a db.git

  #   # mv db.git.tmp2 db.git
  #   rm db.git.tmp

  #   git add .; git commit -m "Update A records."; git pull origin master; git push -u origin master
    
  #   # for n in "$(cat db.git | grep -P "^.+[[:space:]]+IN[[:space:]]+A[[:space:]]+.+")"; do
  #   # done

  #   # cd "$current_dir"
  # done
  # done

  git add .; git commit -m "Update A records END."; git push -u origin master
  # git add .; git commit -m "Update A records END."; git pull origin master; git push -u origin master
}

gc_dns_git_server_update_srv_records() {
  gc_update_servers=( )
  gc_update_servers_hostnames=( )
  GITCID_DIR=${GITCID_DIR:-"${PWD}/.gc/"}

  if [ -f "git-srv.sh" ]; then
    while IFS= read -r k; do
      gc_update_servers+=( "$(echo "$k" | grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" | sed 's/\.$//' | sed 's/\.git$//')" )
      # gc_update_servers+=( "$(echo "$k" | grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$")" )
    done <<< "$(./git-srv.sh)"
  elif [ -f "$HOME/git-server/discover-git-server-dns/git-srv.sh" ]; then
    while IFS= read -r k; do
      gc_update_servers+=( "$(echo "$k" | grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" | sed 's/\.$//' | sed 's/\.git$//')" )
    done <<< "$($HOME/git-server/discover-git-server-dns/git-srv.sh)"
  fi

  for i in $@; do
    # echo "$i"
    if [ -f "git-srv.sh" ]; then
      while IFS= read -r k; do
        gc_update_servers+=( "$(echo "$k" | grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" | sed 's/\.$//' | sed 's/\.git$//')" )
      done <<< "$(./git-srv.sh "$i")"
    elif [ -f "$HOME/git-server/discover-git-server-dns/git-srv.sh" ]; then
      while IFS= read -r k; do
        gc_update_servers+=( "$(echo "$k" | grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" | sed 's/\.$//' | sed 's/\.git$//')" )
      done <<< "$($HOME/git-server/discover-git-server-dns/git-srv.sh "$i")"
    fi
    # gc_update_servers+=( "$(./git-srv.sh "$i" | grep " 1234 ")" )

    # gc_server_hostname="$(echo "$i" | grep -v -e '^[[:space:]]*$')"

    # dig +time=2 +tries=1 +short +nocomments @$gc_server_hostname _git._tcp.git SRV 2>/dev/null | \
    dig +time=2 +tries=1 +short +nocomments @$i _git._tcp.git SRV 2>/dev/null | \
    sed 's/;; connection timed out; no servers could be reached//g' | \
    grep -v -e '^[[:space:]]*$'
    if [ $? -eq 0 ]; then
      gc_update_servers_hostnames+=( "$i" )
      # gc_update_servers_hostnames+=( "$gc_server_hostname" )
    fi
  done

  for i in "${gc_update_servers[@]}"; do
    gc_update_servers_hostnames+=( "$(echo "$i" | awk '{print $NF}' | sed 's/\.$//' | sed 's/\.git$//')" )
  done

  # echo "${gc_update_servers_hostnames[@]}"

  rm -rf workdir
  mkdir -p workdir
  cd workdir

  current_dir="$PWD"

  for i in ${gc_update_servers_hostnames[@]}; do
    cd "$current_dir"

    if [ "$i" == "$(hostname)" ]; then
      continue
    fi
    
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
    # ssh-keygen -F "$i" || ssh-keyscan "$i" >> "${HOME}/.ssh/known_hosts"

    gc_ssh_host="$(echo "$i" | cut -d@ -f2)"

    echo "$i" | grep "@" >/dev/null
    if [ $? -eq 0 ]; then
      gc_ssh_username="$(echo "$i" | cut -d@ -f1)"
    else
      gc_ssh_username="$(cat "${HOME}/.ssh/config" | grep -A2 -P "^Host ${gc_ssh_host}$" | tail -n1 | awk '{print $NF}')"
    fi

    if [ -z "$gc_ssh_username" ]; then
      echo ""
      echo "INFO: No ssh config for user found. Trying Raspberry Pi auto-config..."
      echo ""

      ${GITCID_DIR}.gc-util/provision-git-server-rpi.sh "$gc_ssh_host"

      # gitcid_install_new_git_server_rpi_auto_provision "$gc_ssh_host"

      # gc_ssh_username="$USER"
    fi

    # TODO: DO WE NEED THIS HERE? OR THE SAME ONE ABOVE IS A BETTER PLACE FOR IT?
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
    # ssh-keygen -F "$i" || ssh-keyscan "$i" >> "${HOME}/.ssh/known_hosts"

    # TODO: DO WE NEED THIS?
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
    # ssh-keygen -F "${gc_ssh_username}@${gc_ssh_host}" || ssh-keyscan "${gc_ssh_username}@${gc_ssh_host}" >> "${HOME}/.ssh/known_hosts"

    # TODO: OR DO WE NEED THIS INSTEAD?
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
    # ssh-keygen -F "${gc_ssh_host}" || ssh-keyscan "${gc_ssh_host}" >> "${HOME}/.ssh/known_hosts"

    if [ ! -d "bind-${i}" ]; then
      git clone ${i}:~/git/etc/bind.git "bind-${i}" && \
      cd "bind-${i}" || continue
      gc_dns_git_server_update_srv_records_git "$i"
      gc_dns_git_server_update_srv_records_git "${gc_update_servers_hostnames[@]}"
      
    else
      cd "bind-${i}" || continue
      git reset --hard HEAD
      # git fetch --all
      git pull origin master

      gc_dns_git_server_update_srv_records_git "$i"
      # gc_dns_git_server_update_srv_records_git $gc_update_servers_hostnames
    fi

    # cd "$current_dir"
  done

  cd "$current_dir"/..
}

gc_dns_git_server_update_srv_records $@
# gc_dns_git_server_update_srv_records $@
