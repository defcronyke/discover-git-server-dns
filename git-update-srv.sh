#!/usr/bin/env bash
# 
# Update SRV records on all detected git servers.
#

gc_dns_git_server_update_srv_records_git() {

  git pull origin master

  rm db.git.srv 2>/dev/null
  
  echo " | DEBUG |"
  echo " | DEBUG | ... ADD SRV RECORDS ..."
  echo " | DEBUG |"

  cat db.git | grep -P "^_git\._tcp\.?.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+\.?$" | sort | uniq | \
  tee -a db.git.srv

  echo " | DEBUG |"
  echo " | DEBUG | ... END ADD SRV RECORDS ..."
  echo " | DEBUG |"

  echo " | DEBUG |"
  echo " | DEBUG | ... ADD NS RECORDS ..."
  echo " | DEBUG |"

  cat db.git | grep -P "^@[[:space:]]+IN[[:space:]]+NS[[:space:]]+.+\.?$" | sort | uniq | \
  tee -a db.git.ns

  echo " | DEBUG |"
  echo " | DEBUG | ... END ADD NS RECORDS ..."
  echo " | DEBUG |"

  echo " | DEBUG |"
  echo " | DEBUG | ... ADD SOA RECORD ..."
  echo " | DEBUG |"

  cat db.git | head -n 11 | \
  tee -a db.git.soa

  echo " | DEBUG |"
  echo " | DEBUG | ... END ADD SOA RECORD ..."
  echo " | DEBUG |"


  git add .; git commit -m "Add zone file fragments."; git push -u origin master

  if [ $? -ne 0 ]; then
    git pull origin master
    git add .; git commit -m "Add zone file fragments: Second try."; git push -u origin master

    if [ $? -ne 0 ]; then
      git reset --hard HEAD
      git revert --no-edit HEAD~1
      git push -u origin master

      if [ $? -ne 0 ]; then
        git reset --hard HEAD
        git revert --no-edit HEAD~1
        git push -u origin master
      fi
    fi
  fi

  mkdir -p ${HOME}/.ssh
  chmod 700 ${HOME}/.ssh
  
  current_dir2="$PWD"

  for k in $@; do
    # cd "$current_dir2"

    if [ -z "$k" ]; then
      echo ".. SKIPPING BECAUSE BLANK: $k"
      continue
    fi


    # TODO: !! MAYBE WE SHOULD SKIP OURSELVES LIKE BELOW, TO AVOID INFINITE LOOP?

    # if [ "$k" == "$(hostname)" ]; then
    #   echo "!!!!!  | ! SKIPPING BECAUSE SELF ! |  !!!!!!!"
    #   continue
    # fi

    # ssh-keygen -F "$k" || ssh-keyscan "$k" >>${HOME}/.ssh/known_hosts

    # cd ..

    # if [ ! -d "bind-${k}" ]; then
    #   git clone ${k}:~/git/etc/bind.git bind-${k} && \
    #   cd "bind-${k}"
    #   if [ $? -ne 0 ]; then
    #     echo ""
    #     echo "ERROR: Failed cloning repo: ${k}:~/git/etc/bind.git"
    #     echo ""
    #     continue
    #   fi
    # else
    #   cd "bind-${k}" || continue
    #   git reset --hard HEAD
    #   git pull origin master
    #   if [ $? -ne 0 ]; then
    #     echo ""
    #     echo "ERROR: Failed pulling repo: ${k}:~/git/etc/bind.git"
    #     echo ""
    #   fi
    # fi

    # git remote add upstream ~/git/etc/bind.git || \
    # git remote set-url upstream ~/git/etc/bind.git

    # git remote add git ~/git/etc/bind.git || \
    # git remote set-url git ~/git/etc/bind.git

    git remote add $k ${k}:~/git/etc/bind.git || \
    git remote set-url $k ${k}:~/git/etc/bind.git

    git fetch --all

    git pull $k master; git push -u origin master

    if [ $? -ne 0 ]; then
      git reset --hard HEAD
      git revert --no-edit HEAD~1
      git push -u origin master

      if [ $? -ne 0 ]; then
        git reset --hard HEAD
        git revert --no-edit HEAD~1
        git push -u origin master
      fi
    fi

    git add .
    git commit -m "Update peer records."
    git push -u origin master

  done

  git add .; git commit -m "Update records END."; git push -u origin master

  return 0
}

gc_dns_git_server_update_srv_records() {
  gc_update_servers=( )
  gc_update_servers_hostnames=( )
  GITCID_DIR=${GITCID_DIR:-"${PWD}/.gc/"}

  git pull origin master

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
    dig +time=1 +tries=3 +short +nocomments @$i _git._tcp SRV 2>/dev/null | \
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

  # rm -rf workdir
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
      echo "INFO: Triggering GitCid update, because maybe it's needed..."
      echo ""

      cd ..

      rm .gc/.gc-last-update-check.txt

      git pull origin master

      source <(curl -sL https://tinyurl.com/gitcid) -e

      echo ""
      echo "INFO: No ssh config for user found. Trying Raspberry Pi auto-config..."
      echo ""

      .gc/.gc-util/provision-git-server-rpi.sh "$gc_ssh_host"

      cd workdir

      # gitcid_install_new_git_server_rpi_auto_provision "$gc_ssh_host"

      # gc_ssh_username="$USER"
    fi

    # TODO: DO WE NEED THIS HERE? OR THE SAME ONE ABOVE IS A BETTER PLACE FOR IT?
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
    # ssh-keygen -F "$i" || ssh-keyscan "$i" >> "${HOME}/.ssh/known_hosts"

    touch "${HOME}/.ssh/known_hosts"
    chmod 600 "${HOME}/.ssh/known_hosts"

    touch "${HOME}/.ssh/config"
    chmod 600 "${HOME}/.ssh/config"

    touch "${HOME}/.ssh/authorized_keys"
    chmod 600 "${HOME}/.ssh/authorized_keys"

    sed -i "/^${i}\s.*$/d" "${HOME}/.ssh/known_hosts"; \
    sed -i '/^$/d' "${HOME}/.ssh/known_hosts"


    echo ""
    echo "Adding peer git-server key to local ssh config: \"${HOME}/.ssh/git-server.key\" >> \"${HOME}/.ssh/config\""
    cat "${HOME}/.ssh/config" | grep -P "^Host $i" >/dev/null || printf "%b\n" "\nHost ${i}\n\tHostName ${i}\n\tUser ${gc_ssh_username}\n\tIdentityFile ~/.ssh/git-server.key\n\tIdentitiesOnly yes\n\tConnectTimeout 5\n\tConnectionAttempts 3\n" | tee -a "${HOME}/.ssh/config" >/dev/null
    echo ""
    echo "Added peer key to local \"${HOME}/.ssh/config\" for host: ${gc_ssh_username}@${i}"


    echo ""
    echo "Verifying peer host: $i"
    echo ""

    ssh-keygen -F "$i" || ssh-keyscan "$i" | tee -a "${HOME}/.ssh/known_hosts" >/dev/null


    # TODO: DO WE NEED THIS?
    # mkdir -p "${HOME}/.ssh"
    # chmod 700 "${HOME}/.ssh"
    # ssh-keygen -F "${gc_ssh_username}@${gc_ssh_host}" || ssh-keyscan "${gc_ssh_username}@${gc_ssh_host}" >> "${HOME}/.ssh/known_hosts"

    # TODO: OR DO WE NEED THIS INSTEAD?
    # mkdir -p "${HOME}/.ssh"
    # chmod 700 "${HOME}/.ssh"
    # ssh-keygen -F "${gc_ssh_host}" || ssh-keyscan "${gc_ssh_host}" >> "${HOME}/.ssh/known_hosts"

    if [ ! -d "bind-${i}" ]; then
      git clone ${i}:~/git/etc/bind.git "bind-${i}" && \
      cd "bind-${i}" || continue
      gc_dns_git_server_update_srv_records_git "$i"
      gc_dns_git_server_update_srv_records_git "${gc_update_servers_hostnames[@]}"
      
    else
      cd "bind-${i}" || continue
      git reset --hard HEAD
      git fetch --all
      git pull origin master

      gc_dns_git_server_update_srv_records_git "$i"
      gc_dns_git_server_update_srv_records_git "${gc_update_servers_hostnames[@]}"
      # gc_dns_git_server_update_srv_records_git $gc_update_servers_hostnames
    fi

    # cd "$current_dir"
  done

  cd "$current_dir"/..

  return 0
}

gc_dns_git_server_update_srv_records $@
# gc_dns_git_server_update_srv_records $@
