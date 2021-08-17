#!/usr/bin/env bash
# 
# Update SRV records on all detected git servers.
#

gc_dns_git_server_update_srv_records_git() {

  git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" reset --hard HEAD

  git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" pull --no-edit origin master

  # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" pull --no-edit origin master


  current_bind_dir="$PWD"

  cd ../bind


  # cp -rf db.git db.git.bak

  # rm db.git.soa 2>/dev/null
  # rm db.git.ns 2>/dev/null
  # rm db.git.a 2>/dev/null
  # rm db.git.srv 2>/dev/null
  

  echo " | DEBUG |"
  echo " | DEBUG | ... ADD SOA RECORD ..."
  echo " | DEBUG |"

  cat db.git | head -n 11 | \
  tee db.git.soa.next

  echo " | DEBUG |"
  echo " | DEBUG | ... END ADD SOA RECORD ..."
  echo " | DEBUG |"
  

  echo " | DEBUG |"
  echo " | DEBUG | ... ADD NS RECORDS ..."
  echo " | DEBUG |"

  cat ${current_bind_dir}/db.git | grep -P "^@[[:space:]]+IN[[:space:]]+NS[[:space:]]+.+\.?$" | sort | uniq | \
  tee ${current_bind_dir}/db.git.ns.next

  # cat db.git | grep -P "^@[[:space:]]+IN[[:space:]]+NS[[:space:]]+.+\.?$" | sort | uniq | \
  # tee -a ${current_bind_dir}/db.git.ns.next

  # if [ -f ${current_bind_dir}/db.git.ns.old ]; then
  #   cat ${current_bind_dir}/db.git.ns.old | sort | uniq | \
  #   tee -a ${current_bind_dir}/db.git.ns.next
  # fi

  # cp -rf ${current_bind_dir}/db.git.ns.next ${current_bind_dir}/db.git.ns.old

  echo " | DEBUG |"
  echo " | DEBUG | ... END ADD NS RECORDS ..."
  echo " | DEBUG |"


  echo " | DEBUG |"
  echo " | DEBUG | ... ADD A RECORDS ..."
  echo " | DEBUG |"

  # sed -i "s/^\$(hostname)\.?\s*IN\s*A\s*.*\.?$//g" db.git
  # sed -i "s/^\${1}\.?\s*IN\s*A\s*.*\.?$//g" ${current_bind_dir}/db.git
  # sed -i "s/^@\s*IN\s*A\s*.*\.?$//g" db.git

  # Remove old self hostname from zone file.
  sed -i "s/^@\s*IN\s*A\s*.*\.?$//g" ${current_bind_dir}/db.git
  
  cat ${current_bind_dir}/db.git | grep -P "^.+\.?[[:space:]]+IN[[:space:]]+A[[:space:]]+.+\.?$" | sort | uniq | \
  tee ${current_bind_dir}/db.git.a.next

  # cat db.git | grep -P "^.+\.?[[:space:]]+IN[[:space:]]+A[[:space:]]+.+\.?$" | sort | uniq | \
  # tee -a ${current_bind_dir}/db.git.a.next

  # if [ -f ${current_bind_dir}/db.git.a.old ]; then
  #   # Remove old self hostname from zone file.
  #   sed -i "s/^\$(hostname)\.?\s*IN\s*A\s*.*\.?$//g" ${current_bind_dir}/db.git.a.old

  #   cat ${current_bind_dir}/db.git.a.old | sort | uniq | \
  #   tee -a ${current_bind_dir}/db.git.a.next
  # fi

  # # Add current peer hostname to zone file.
  # # echo "@       IN      A      $(ip a | grep `ip route ls | head -n 1 | awk '{print $5}'` | grep inet | awk '{print $2}' | sed 's/\/.*//g')" | sudo tee -a ${current_bind_dir}/db.git.a.next
  # echo "${1}.       IN      A       $(ip a | grep `ip route ls | head -n 1 | awk '{print $5}'` | grep inet | awk '{print $2}' | sed 's/\/.*//g')" | sudo tee -a ${current_bind_dir}/db.git.a.next
  # echo "${1}       IN      A       $(ip a | grep `ip route ls | head -n 1 | awk '{print $5}'` | grep inet | awk '{print $2}' | sed 's/\/.*//g')" | sudo tee -a ${current_bind_dir}/db.git.a.next
  
  # cp -rf ${current_bind_dir}/db.git.a.next ${current_bind_dir}/db.git.a.old

  echo " | DEBUG |"
  echo " | DEBUG | ... END ADD A RECORDS ..."
  echo " | DEBUG |"  


  echo " | DEBUG |"
  echo " | DEBUG | ... ADD SRV RECORDS ..."
  echo " | DEBUG |"

  cat ${current_bind_dir}/db.git | grep -P "^_git\._tcp\.?.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+\.?$" | sort | uniq | \
  tee ${current_bind_dir}/db.git.srv.next

  # cat db.git | grep -P "^_git\._tcp\.?.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+\.?$" | sort | uniq | \
  # tee -a ${current_bind_dir}/db.git.srv.next

  # if [ -f ${current_bind_dir}/db.git.ns.old ]; then
  #   cat ${current_bind_dir}/db.git.srv.old | sort | uniq | \
  #   tee -a ${current_bind_dir}/db.git.srv.next
  # fi
  
  # cp -rf ${current_bind_dir}/db.git.srv.next ${current_bind_dir}/db.git.srv.old

  echo " | DEBUG |"
  echo " | DEBUG | ... END ADD SRV RECORDS ..."
  echo " | DEBUG |"


  # # cat db.git.soa.next | tee db.git.next

  # sort db.git.ns.next ${current_bind_dir}/db.git.ns.next -u | tee -a db.git.next
  # # cp -ur db.git.ns.next db.git.ns

  # sort db.git.a.next ${current_bind_dir}/db.git.a.next -u | tee -a db.git.next
  # # cp -ur db.git.a.next db.git.a

  # sort db.git.srv.next ${current_bind_dir}/db.git.srv.next -u | tee -a db.git.next
  # # cp -ur db.git.srv.next db.git.srv


  # cp -rf db.git db.git.bak

  # cp -rf db.git.next db.git



  cd "${current_bind_dir}"


  # echo " | DEBUG |"
  # echo " | DEBUG | ... MAKING NEW ZONE FILE ..."
  # echo " | DEBUG |"

  # # cat db.git.soa | \
  # # tee db.git.next

  # # cat db.git.ns | \
  # # tee -a db.git.next

  # # cat db.git.a | \
  # # tee -a db.git.next

  # # cat db.git.srv | \
  # # tee -a db.git.next

  # echo " | DEBUG |"
  # echo " | DEBUG | ... END MAKING NEW ZONE FILE ..."
  # echo " | DEBUG |"


  # mkdir -p ${HOME}/.ssh
  # chmod 700 ${HOME}/.ssh



  # cd ..

  # current_workdir="$PWD"

  # if [ ! -d "bind" ]; then
  #   git clone ~/git/etc/bind.git
  # else
  #   cd bind
  #   git pull --no-edit origin master
  #   cd ..
  # fi
  

  # cd "bind-${1}"

  # sort ../bind/db.git.ns db.git.ns -u | tee db.git.ns.next
  # cp -ur db.git.ns.next db.git.ns
  # cp -ur db.git.ns.next ../bind/db.git.ns

  # sort ../bind/db.git.a db.git.a -u | tee db.git.a.next
  # cp -ur db.git.a.next db.git.a
  # cp -ur db.git.a.next ../bind/db.git.a

  # sort ../bind/db.git.srv db.git.srv -u | tee db.git.srv.next
  # cp -ur db.git.srv.next db.git.srv
  # cp -ur db.git.srv.next ../bind/db.git.srv

  # cp -rf db.git db.git.bak
  # cp -rf ../bind/db.git ../bind/db.git.bak



  # cat db.git.soa | tee db.git.next

  # cat db.git.ns | tee -a db.git.next
  # cat db.git.a | tee -a db.git.next
  # cat db.git.srv | tee -a db.git.next

  # cp -rf db.git.next db.git
  # cp -rf db.git.next ../bind/db.git




  # cd ../bind


  # git add db.git.soa; \
  # git commit -m "Update SOA file."

  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git.soa; \
  #   git commit -m "Update SOA file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi


  # git add db.git.ns; \
  # git commit -m "Update NS file."
  
  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git.ns; \
  #   git commit -m "Update NS file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi



  # git add db.git.a; \
  # git commit -m "Update A file."

  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git.a; \
  #   git commit -m "Update A file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi


  # git add db.git.srv; \
  # git commit -m "Update SRV file."

  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git.srv; \
  #   git commit -m "Update SRV file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi



  # git add db.git; \
  # git commit -m "Update ZONE file."



  # git pull --no-edit origin master


  # git push -u origin master


  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git; \
  #   git commit -m "Update ZONE file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi



  # cd ../"bind-${1}"



  # git add db.git.soa; \
  # git commit -m "Update SOA file."

  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git.soa; \
  #   git commit -m "Update SOA file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi


  # git add db.git.ns; \
  # git commit -m "Update NS file."

  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git.ns; \
  #   git commit -m "Update NS file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi



  # git add db.git.a; \
  # git commit -m "Update A file."

  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git.a; \
  #   git commit -m "Update A file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi


  # git add db.git.srv; \
  # git commit -m "Update SRV file."

  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git.srv; \
  #   git commit -m "Update SRV file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi



  # git add db.git; \
  # git commit -m "Update ZONE file."




  # git pull --no-edit origin master

  # git push -u origin master




  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git; \
  #   git commit -m "Update ZONE file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi




  



  
  
  # current_dir2="$PWD"

  # for k in $@; do
    # cd "$current_dir2"

  # if [ -z "$k" ]; then
  #   echo ".. SKIPPING BECAUSE BLANK: $k"
  #   continue
  # fi


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

  # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" remote add upstream ~/git/etc/bind.git || \
  # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" remote set-url upstream ~/git/etc/bind.git

  # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" fetch --all

  # # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" pull $k master; \
  # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" push -u origin master

  # if [ $? -ne 0 ]; then
  #   git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" reset --hard HEAD
  #   git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" revert --no-edit HEAD~1
  #   git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" reset --hard HEAD
  #     git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" revert --no-edit HEAD~1
  #     git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" push -u origin master
  #   fi
  # fi

  # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" add .
  # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" commit -m "Update peer records."
  # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" push -u origin master

  # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" push upstream master

  # # done

  # # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" add .; \
  # # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" commit -m "Update records END."; \
  # # git --git-dir="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}/.git" --work-tree="${HOME}/git-server/discover-git-server-dns/workdir/bind-${1}" push -u origin master

  return 0
}

gc_dns_git_server_update_srv_records() {
  GITCID_DIR=${GITCID_DIR:-"${PWD}/.gc/"}
  
  gc_update_servers="$("${HOME}/git-server/discover-git-server-dns/git-srv.sh" $@ $(hostname) git1 git2)"

  echo ""
  echo "GIT SERVERS:"
  echo ""
  echo "$gc_update_servers"
  echo ""

  # gc_update_servers_hostnames_args=( $@ )

  gc_update_servers_hostnames=( )
  
  for i in "${gc_update_servers[@]}"; do
    gc_update_servers_hostnames+=( "$(echo "$i" | awk '{print $NF}' | sed 's/\.$//')" )
  done

  # echo ""
  # echo "GIT SERVER HOSTNAMES ARGS:"
  # echo ""
  # echo "$gc_update_servers_hostnames_args"
  # echo ""

  echo ""
  echo "GIT SERVER HOSTNAMES:"
  echo ""
  echo "$gc_update_servers_hostnames"
  echo ""

  # git pull --no-edit origin master

  # if [ -f "git-srv.sh" ]; then
  #   while IFS= read -r k; do
  #     gc_update_servers+=( "$(echo "$k" | grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" | sed 's/\.$//' | sed 's/\.git$//')" )
  #     # gc_update_servers+=( "$(echo "$k" | grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$")" )
  #   done <<< "$(./git-srv.sh)"
  # elif [ -f "${HOME}/git-server/discover-git-server-dns/git-srv.sh" ]; then
  #   while IFS= read -r k; do
  #     gc_update_servers+=( "$(echo "$k" | grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" | sed 's/\.$//' | sed 's/\.git$//')" )
  #   done <<< "$($HOME/git-server/discover-git-server-dns/git-srv.sh)"
  # fi

  # for i in $@; do
  #   # echo "$i"
  #   if [ -f "git-srv.sh" ]; then
  #     while IFS= read -r k; do
  #       gc_update_servers+=( "$(echo "$k" | grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" | sed 's/\.$//' | sed 's/\.git$//')" )
  #     done <<< "$(./git-srv.sh "$i")"
  #   elif [ -f "$HOME/git-server/discover-git-server-dns/git-srv.sh" ]; then
  #     while IFS= read -r k; do
  #       gc_update_servers+=( "$(echo "$k" | grep -P "^.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+$" | sed 's/\.$//' | sed 's/\.git$//')" )
  #     done <<< "$($HOME/git-server/discover-git-server-dns/git-srv.sh "$i")"
  #   fi
  #   # gc_update_servers+=( "$(./git-srv.sh "$i" | grep " 1234 ")" )

  #   # gc_server_hostname="$(echo "$i" | grep -v -e '^[[:space:]]*$')"

  #   # dig +time=2 +tries=1 +short +nocomments @$gc_server_hostname _git._tcp.git SRV 2>/dev/null | \
  #   dig +time=1 +tries=3 +short +nocomments @$i _git._tcp SRV 2>/dev/null | \
  #   sed 's/;; connection timed out; no servers could be reached//g' | \
  #   grep -v -e '^[[:space:]]*$'
  #   if [ $? -eq 0 ]; then
  #     gc_update_servers_hostnames+=( "$i" )
  #     # gc_update_servers_hostnames+=( "$gc_server_hostname" )
  #   fi
  # done

  # for i in "${gc_update_servers[@]}"; do
  #   gc_update_servers_hostnames+=( "$(echo "$i" | awk '{print $NF}' | sed 's/\.$//' | sed 's/\.git$//')" )
  # done

  # echo "${gc_update_servers_hostnames[@]}"
  mkdir -p "${HOME}/.ssh"
  chmod 700 "${HOME}/.ssh"

  # rm -rf workdir
  mkdir -p workdir
  cd workdir

  current_dir="${HOME}/git-server/discover-git-server-dns/workdir"


  cd "${current_dir}"


  if [ ! -d "${current_dir}/bind" ]; then
    git clone ${HOME}/git/etc/bind.git "${current_dir}/bind"
    cd "${current_dir}/bind"
    # gc_dns_git_server_update_srv_records_git "$i"
    # gc_dns_git_server_update_srv_records_git "${gc_update_servers_hostnames[@]}"
      
  else
    cd "${current_dir}/bind"
    git --git-dir="${current_dir}/bind/.git" --work-tree="${current_dir}/bind" reset --hard HEAD
    # git fetch --all
    git --git-dir="${current_dir}/bind/.git" --work-tree="${current_dir}/bind" pull --no-edit origin master


    # gc_dns_git_server_update_srv_records_git "$i"
    # gc_dns_git_server_update_srv_records_git "${gc_update_servers_hostnames[@]}"
    # gc_dns_git_server_update_srv_records_git $gc_update_servers_hostnames
  fi

  # source <(curl -sL https://tinyurl.com/gitcid) -e

  cd "${current_dir}"



  for i in ${gc_update_servers_hostnames[@]}; do
    cd "$current_dir"

    if [ "$i" == "$(hostname)" ]; then
      continue
    fi
    
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

      cd ${current_dir}/..

      rm "${current_dir}/../.gc/.gc-last-update-check.txt"

      git --git-dir="${current_dir}/../.git" --work-tree="${current_dir}/.." pull --no-edit origin master

      source <(curl -sL https://tinyurl.com/gitcid) -e

      echo ""
      echo "INFO: No ssh config for user found. Trying Raspberry Pi auto-config..."
      echo ""

      ${current_dir}/../.gc/.gc-util/provision-git-server-rpi.sh "$gc_ssh_host"

      cd "$current_dir"

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
    
    ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "$i"

    ssh-keygen -F "$i" || ssh-keyscan "$i" | tee -a "${HOME}/.ssh/known_hosts" >/dev/null


    # TODO: DO WE NEED THIS?
    # mkdir -p "${HOME}/.ssh"
    # chmod 700 "${HOME}/.ssh"
    # ssh-keygen -F "${gc_ssh_username}@${gc_ssh_host}" || ssh-keyscan "${gc_ssh_username}@${gc_ssh_host}" >> "${HOME}/.ssh/known_hosts"

    # TODO: OR DO WE NEED THIS INSTEAD?
    # mkdir -p "${HOME}/.ssh"
    # chmod 700 "${HOME}/.ssh"
    # ssh-keygen -F "${gc_ssh_host}" || ssh-keyscan "${gc_ssh_host}" >> "${HOME}/.ssh/known_hosts"

    if [ ! -d "${current_dir}/bind-${i}" ]; then
      git clone ${i}:${HOME}/git/etc/bind.git "${current_dir}/bind-${i}" && \
      cd "${current_dir}/bind-${i}" || continue
      gc_dns_git_server_update_srv_records_git "$i"
      # gc_dns_git_server_update_srv_records_git "${gc_update_servers_hostnames[@]}"
      
    else
      cd "${current_dir}/bind-${i}" || continue
      git --git-dir="${current_dir}/bind-${i}/.git" --work-tree="${current_dir}/bind-${i}" reset --hard HEAD
      # git fetch --all
      git --git-dir="${current_dir}/bind-${i}/.git" --work-tree="${current_dir}/bind-${i}" pull --no-edit origin master

      gc_dns_git_server_update_srv_records_git "$i"
      # gc_dns_git_server_update_srv_records_git "${gc_update_servers_hostnames[@]}"
      # gc_dns_git_server_update_srv_records_git $gc_update_servers_hostnames
    fi

    
    # source <(curl -sL https://tinyurl.com/gitcid) -e


    # cd "$current_dir"
  done





  rm "${current_dir}/bind/db.git.ns.next" 2>/dev/null
  rm "${current_dir}/bind/db.git.a.next" 2>/dev/null
  rm "${current_dir}/bind/db.git.srv.next" 2>/dev/null


  


  cd "${current_dir}/bind"


  echo " | DEBUG |"
  echo " | DEBUG | ... ADD SOA RECORD ..."
  echo " | DEBUG |"

  cat ${current_dir}/bind/db.git | head -n 11 | \
  tee ${current_dir}/bind/db.git.soa.next

  echo " | DEBUG |"
  echo " | DEBUG | ... END ADD SOA RECORD ..."
  echo " | DEBUG |"
  

  echo " | DEBUG |"
  echo " | DEBUG | ... ADD NS RECORDS ..."
  echo " | DEBUG |"

  cat ${current_dir}/bind/db.git | grep -P "^@[[:space:]]+IN[[:space:]]+NS[[:space:]]+.+\.?$" | sort | uniq | \
  tee ${current_dir}/bind/db.git.ns.next

  # if [ -f db.git.ns.old ]; then
  #   cat db.git.ns.old | sort | uniq | \
  #   tee -a db.git.ns.next
  # fi

  # cp -rf db.git.ns.next db.git.ns.old

  echo " | DEBUG |"
  echo " | DEBUG | ... END ADD NS RECORDS ..."
  echo " | DEBUG |"


  echo " | DEBUG |"
  echo " | DEBUG | ... ADD A RECORDS ..."
  echo " | DEBUG |"

  # Remove old self hostname from zone file.
  sed -i "s/^\$(hostname)\.?\s*IN\s*A\s*.*\.?$//g" ${current_dir}/bind/db.git
  sed -i "s/^@\s*IN\s*A\s*.*\.?$//g" ${current_dir}/bind/db.git

  cat ${current_dir}/bind/db.git | grep -P "^.+\.?[[:space:]]+IN[[:space:]]+A[[:space:]]+.+\.?$" | sort | uniq | \
  tee ${current_dir}/bind/db.git.a.next

  # if [ -f db.git.a.old ]; then
  #   # Remove old self hostname from zone file.
  #   sed -i "s/^\$(hostname)\.?\s*IN\s*A\s*.*\.?$//g" db.git.a.old
  #   sed -i "s/^@\s*IN\s*A\s*.*\.?$//g" db.git.a.old

  #   cat db.git.a.old | sort | uniq | \
  #   tee -a db.git.a.next
  # fi

  # Add current self hostname to zone file.
  echo "@       IN      A      $(ip a | grep `ip route ls | head -n 1 | awk '{print $5}'` | grep inet | awk '{print $2}' | sed 's/\/.*//g')" | \
  sudo tee -a ${current_dir}/bind/db.git.a.next
  
  echo "$(hostname).       IN      A       $(ip a | grep `ip route ls | head -n 1 | awk '{print $5}'` | grep inet | awk '{print $2}' | sed 's/\/.*//g')" | \
  sudo tee -a ${current_dir}/bind/db.git.a.next
  
  echo "$(hostname)       IN      A       $(ip a | grep `ip route ls | head -n 1 | awk '{print $5}'` | grep inet | awk '{print $2}' | sed 's/\/.*//g')" | \
  sudo tee -a ${current_dir}/bind/db.git.a.next
  
  # cp -rf db.git.a.next db.git.a.old

  echo " | DEBUG |"
  echo " | DEBUG | ... END ADD A RECORDS ..."
  echo " | DEBUG |"  


  echo " | DEBUG |"
  echo " | DEBUG | ... ADD SRV RECORDS ..."
  echo " | DEBUG |"

  cat ${current_dir}/bind/db.git | grep -P "^_git\._tcp\.?.*[[:space:]]+IN[[:space:]]+SRV[[:space:]]+.+[[:space:]]+.+[[:space:]]+1234[[:space:]]+.+\.?$" | sort | uniq | \
  tee ${current_dir}/bind/db.git.srv.next

  # if [ -f db.git.ns.old ]; then
  #   cat db.git.srv.old | sort | uniq | \
  #   tee -a db.git.srv.next
  # fi
  
  # cp -rf db.git.srv.next db.git.srv.old

  echo " | DEBUG |"
  echo " | DEBUG | ... END ADD SRV RECORDS ..."
  echo " | DEBUG |"



  for i in ${gc_update_servers_hostnames[@]}; do
    cd "${current_dir}/bind"

    if [ "$i" == "$(hostname)" ]; then
      continue
    fi


    echo ""
    echo "Adding zone to file if necessary: /etc/bind/named.conf.local"
    echo ""

    cat "${current_dir}/bind/named.conf.local" | grep "zone \"${i}\"" >/dev/null
    if [ $? -ne 0 ]; then
      printf '%b\n' "zone \"${i}\" {\n\
  type master;\n\
  file \"/etc/bind/db.git\";\n\
};" | \
      sudo tee -a "${current_dir}/bind/named.conf.local"
    fi


    cat "${current_dir}/bind-${i}/db.git.ns.next" | \
    tee -a ${current_dir}/bind/db.git.ns.next

    cat "${current_dir}/bind-${i}/db.git.a.next" | sort | uniq | \
    tee -a ${current_dir}/bind/db.git.a.next

    cat "${current_dir}/bind-${i}/db.git.srv.next" | sort | uniq | \
    tee -a ${current_dir}/bind/db.git.srv.next
  done

  cd "${current_dir}/bind"

  cat ${current_dir}/bind/db.git.soa.next | \
  tee ${current_dir}/bind/db.git.next

  cat ${current_dir}/bind/db.git.ns.next | \
  tee -a ${current_dir}/bind/db.git.next

  cat ${current_dir}/bind/db.git.a.next | sort | uniq | \
  tee -a ${current_dir}/bind/db.git.next

  cat ${current_dir}/bind/db.git.srv.next | sort | uniq | \
  tee -a ${current_dir}/bind/db.git.next

  cp -rf ${current_dir}/bind/db.git ${current_dir}/bind/db.git.bak

  cp -rf ${current_dir}/bind/db.git.next ${current_dir}/bind/db.git

  git --git-dir="${current_dir}/bind/.git" --work-tree="${current_dir}/bind" add .

  git --git-dir="${current_dir}/bind/.git" --work-tree="${current_dir}/bind" commit -m "Update bind zone files."

  git --git-dir="${current_dir}/bind/.git" --work-tree="${current_dir}/bind" push -u origin master



  
  # cp -rf bind/db.git bind/db.git.bak
  # # cd bind


  # rm bind/db.git.ns.next
  # rm bind/db.git.a.next
  # rm bind/db.git.srv.next
  # rm bind/db.git.next

  # cd bind

  # git pull --no-edit origin master

  # cd ..


  # cat bind/db.git.soa | tee bind/db.git.next


  # for i in ${gc_update_servers_hostnames[@]}; do
  #   cd "$current_dir"

  #   if [ "$i" == "$(hostname)" ]; then
  #     continue
  #   fi



  #   if [ ! -d "bind-${i}" ]; then
  #     git clone ${i}:~/git/etc/bind.git "bind-${i}" && \
  #     cd "bind-${i}" || continue
  #     # gc_dns_git_server_update_srv_records_git "$i"
  #     # gc_dns_git_server_update_srv_records_git "${gc_update_servers_hostnames[@]}"
      
  #   else
  #     cd "bind-${i}" || continue
  #     git reset --hard HEAD
  #     git fetch --all
  #     git pull --no-edit origin master

  #     # gc_dns_git_server_update_srv_records_git "$i"
  #     # gc_dns_git_server_update_srv_records_git "${gc_update_servers_hostnames[@]}"
  #     # gc_dns_git_server_update_srv_records_git $gc_update_servers_hostnames
  #   fi

  #   cd "$current_dir"
  
  #   cd bind



  #   sort db.git.ns ../bind-${i}/db.git.ns -u | tee -a db.git.ns.next
  #   cp -ur db.git.ns.next db.git.ns

  #   sort db.git.a ../bind-${i}/db.git.a -u | tee -a db.git.a.next
  #   cp -ur db.git.a.next db.git.a

  #   sort db.git.srv ../bind-${i}/db.git.srv -u | tee -a db.git.srv.next
  #   cp -ur db.git.srv.next db.git.srv

  # done

  # cd "$current_dir"
  # cd bind


  # cat db.git.ns | tee -a db.git.next

  # cat db.git.a | tee -a db.git.next

  # cat db.git.srv | tee -a db.git.next
  


  # cp -ur db.git.next db.git





  # git add .
  # git commit -m "Full zone file update."
  # # git pull --no-edit origin master
  # git push -u origin master
  



  # for i in ${gc_update_servers_hostnames[@]}; do
  #   cd "$current_dir"

  #   if [ "$i" == "$(hostname)" ]; then
  #     continue
  #   fi

  #   cd bind-${i}/

  #   git pull --no-edit origin master

  #   cd ../bind

  #   cp -ur db.git.ns ../bind-${i}/db.git.ns
  #   cp -ur db.git.a ../bind-${i}/db.git.a
  #   cp -ur db.git.srv ../bind-${i}/db.git.srv
  #   cp -ur db.git ../bind-${i}/db.git

  #   cd ../bind-${i}/

  #   git add .
  #   git commit -m "Full zone file update."
  #   # git pull --no-edit origin master
  #   git push -u origin master

  # done

  # cd "$current_dir"

  # if [ ! -d "bind" ]; then
  #   git clone ~/git/etc/bind.git
  #   cd bind
  # else
  #   cd bind
  #   git pull --no-edit origin master
  #   # cd "$current_workdir"
  # fi



  # cd bind


  # cp -rf db.git db.git.bak
  

  # sort db.git.ns ../bind-*/db.git.ns -u | tee db.git.ns.next
  # cp -ur db.git.ns.next db.git.ns

  # sort db.git.a ../bind-*/db.git.a -u | tee db.git.a.next
  # cp -ur db.git.a.next db.git.a

  # sort db.git.srv ../bind-*/db.git.srv -u | tee db.git.srv.next
  # cp -ur db.git.srv.next db.git.srv


  # cat db.git.soa | tee db.git.next

  # cat db.git.ns | tee -a db.git.next

  # cat db.git.a | tee -a db.git.next

  # cat db.git.srv | tee -a db.git.next


  # cp -ur db.git.next db.git



  # git add db.git.soa; \
  # git commit -m "Update SOA file."; \
  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git.soa; \
  #   git commit -m "Update SOA file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi


  # git add db.git.ns; \
  # git commit -m "Update NS file."; \
  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git.ns; \
  #   git commit -m "Update NS file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi



  # git add db.git.a; \
  # git commit -m "Update A file."; \
  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git.a; \
  #   git commit -m "Update A file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi


  # git add db.git.srv; \
  # git commit -m "Update SRV file."; \
  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git.srv; \
  #   git commit -m "Update SRV file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi



  # git add db.git; \
  # git commit -m "Update ZONE file."; \
  # git push -u origin master

  # if [ $? -ne 0 ]; then
  #   git pull --no-edit origin master
  #   git add db.git; \
  #   git commit -m "Update ZONE file, second try."; \
  #   git push -u origin master

  #   if [ $? -ne 0 ]; then
  #     git reset --hard HEAD
  #     git revert --no-edit HEAD~1
  #     git push -u origin master

  #     if [ $? -ne 0 ]; then
  #       git reset --hard HEAD
  #       git revert --no-edit HEAD~1
  #       git push -u origin master
  #     fi
  #   fi
  # fi


  sudo systemctl reload bind9 || \
  sudo systemctl reload named


  # sudo systemctl restart bind9 || \
  # sudo systemctl restart named

  # cat db.git.soa | tee db.git.next

  cd ${current_dir}/..

  return 0
}

gc_dns_git_server_update_srv_records $@

# # Run this a second time to cause the DNS records 
# # to propagate to the other git servers.
# gc_dns_git_server_update_srv_records $@
