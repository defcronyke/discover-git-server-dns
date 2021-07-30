#!/usr/bin/env bash
# Install git server bind DNS-based 
# service discovery features.

discover_git_server_dns_install_main() {
  echo ""
  echo "Installing and setting up bind DNS server for service discovery purposes if it wasn't installed yet..."
  echo ""

  sudo apt-get update && \
  sudo apt-get install -y bind9
  # sudo apt-get install -y bind9 nmap

  # Install zone file: /etc/bind/db.git
  echo ""
  echo "Adding or updating zone file: /etc/bind/db.git"
  echo "Using template file: ./db.git.tmpl"
  echo ""

  # sudo ls /etc/bind/db.git >/dev/null 2>&1
  # if [ $? -ne 0 ]; then
  #   echo ""
  #   echo "NOTICE: Installing new DNS zone file: /etc/bind/db.git"
  #   echo ""

  sudo cp -f db.git.tmpl /etc/bind/db.git.orig

  # echo "@       IN      NS      ns1" | sudo tee -a /etc/bind/db.git.orig
  # echo "@       IN      NS      ns2" | sudo tee -a /etc/bind/db.git.orig
  echo "@       IN      NS      {BIND_DB_GIT_HOSTNAME}." | sudo tee -a /etc/bind/db.git.orig
  echo "@       IN      NS      {BIND_DB_GIT_HOSTNAME}" | sudo tee -a /etc/bind/db.git.orig
  echo "@       IN      NS      git." | sudo tee -a /etc/bind/db.git.orig
  echo "@       IN      NS      git" | sudo tee -a /etc/bind/db.git.orig
  echo "@       IN      NS      git1." | sudo tee -a /etc/bind/db.git.orig
  echo "@       IN      NS      ns." | sudo tee -a /etc/bind/db.git.orig
  echo "@       IN      NS      ns" | sudo tee -a /etc/bind/db.git.orig
  echo "@       IN      NS      ns1." | sudo tee -a /etc/bind/db.git.orig
  echo "@       IN      NS      localhost." | sudo tee -a /etc/bind/db.git.orig

  # count=1
  # for i in $(cat /etc/resolv.conf | grep "nameserver" | awk '{print $NF}'); do
  #   if [ "$(hostname)" != "git${count}" ]; then
  #     echo "@       IN      NS      git${count}" | sudo tee -a /etc/bind/db.git.orig
  #   fi

  #   echo "@       IN      NS      ns${count}" | sudo tee -a /etc/bind/db.git.orig

  #   # if [ $count -eq 1 ]; then
  #   #   echo "@       IN      NS      git" | sudo tee -a /etc/bind/db.git.orig
  #   # fi
    
  #   ((count++))
  # done

  # if [ $count -eq 1 ]; then
  #   echo "@       IN      NS      git" | sudo tee -a /etc/bind/db.git.orig
  # fi

  # echo "@       IN      NS      git." | sudo tee -a /etc/bind/db.git.orig
  
  echo "{BIND_DB_GIT_HOSTNAME}.       IN      A       {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig
  echo "{BIND_DB_GIT_HOSTNAME}       IN      A       {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig
  echo "localhost.       IN      A       127.0.0.1" | sudo tee -a /etc/bind/db.git.orig
  
  echo "git.       IN      A      {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig
  echo "git       IN      A      {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig

  echo "ns.       IN      A      {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig
  echo "ns       IN      A      {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig

  echo "ns1.       IN      A      {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig
  echo "ns1       IN      A      {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig
  
  echo "git1.       IN      A      {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig
  echo "git1       IN      A      {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig
  
  echo "@       IN      A      {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig

  # count=1
  # for i in $(cat /etc/resolv.conf | grep "nameserver" | awk '{print $NF}'); do
   

  #   if [ "$(hostname)" != "git${count}" ]; then
  #     echo "git${count}       IN      A      $i" | sudo tee -a /etc/bind/db.git.orig
  #   fi

  #   if [ $count -ne 1 ]; then
  #     echo "ns${count}       IN      A      $i" | sudo tee -a /etc/bind/db.git.orig
  #   fi

  #   # if [ $count -eq 1 ]; then
  #   #   echo "@       IN      A      {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig
  #   # fi
    
  #   ((count++))
  # done

  # if [ $count -eq 1 ]; then
  #   echo "@       IN      A      {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git.orig
  # fi
  
  echo "_git._tcp  IN      SRV     5 10 1234 {BIND_DB_GIT_HOSTNAME}." | sudo tee -a /etc/bind/db.git.orig

  # echo "_git._tcp  IN      SRV     5 10 1234 git" | sudo tee -a /etc/bind/db.git.orig

  # # IPv6 example
  # echo "@       IN      AAAA    ::1" | sudo tee -a /etc/bind/db.git.orig
  
  cat /etc/bind/db.git.orig | \
  sed "s/{BIND_DB_GIT_SERIAL}/$(echo "`date +%Y%m%d`$(echo $RANDOM | tail -c 3)")/g" | \
  sed "s/{BIND_DB_GIT_HOSTNAME}/$(hostname)/g" | \
  sed "s/{BIND_DB_GIT_IP_ADDR}/$(ip a | grep `ip route ls | head -n 1 | awk '{print $5}'` | grep inet | awk '{print $2}' | sed 's/\/.*//g')/g" | \
  sudo tee /etc/bind/db.git

  # else
  #   echo ""
  #   echo "NOTICE: Not installing new DNS zone file because it was already installed: /etc/bind/db.git"
  #   echo ""
  # fi

  # Activate the "db.git" zone file by including it 
  # in bind config file, if it's not activated yet: 
  # /etc/bind/named.conf.local
  echo ""
  echo "Activating \"/etc/bind/db.git\" zone file if necessary,"
  echo "by including it in bind config file: /etc/bind/named.conf.local"
  echo ""

  sudo grep /etc/bind/named.conf.local -e "zone \"$(hostname)\"" >/dev/null
  if [ $? -ne 0 ]; then
    echo ""

    if [ ! -f "/etc/bind/named.conf.local.orig" ]; then
      sudo cp -f /etc/bind/named.conf.local /etc/bind/named.conf.local.orig
    fi

    sudo cp -f /etc/bind/named.conf.local /etc/bind/named.conf.local.bak

    cat named.conf.local.tmpl | \
    sed "s/{BIND_DB_GIT_HOSTNAME}/$(hostname)/g" | \
    sudo tee /etc/bind/named.conf.local

    echo ""
  else
    echo ""
    echo "Zone file \"/etc/bind/db.git\" is already active."
    echo ""
  fi

  dig @"$(hostname)" "$(hostname)" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Enabling systemd service: bind9.service"
    echo ""
    sudo systemctl reenable bind9 2>/dev/null || \
    sudo systemctl reenable named 2>/dev/null || \
    true

    sudo systemctl restart bind9 2>/dev/null || \
    sudo systemctl restart named 2>/dev/null || \
    true

    sudo systemctl daemon-reload

    # sudo systemctl enable systemd-resolved; \
    # sudo systemctl restart systemd-resolved || \
    # true

    # sudo systemctl enable bind9-resolvconf; \
    # sudo systemctl restart bind9-resolvconf || \
    # true

  else
    echo "NOTICE: Not enabling bind9.service because there was already some DNS service running."
    echo ""

    sudo systemctl restart bind9 2>/dev/null || \
    sudo systemctl restart named 2>/dev/null || \
    true

    sudo systemctl daemon-reload

    # sudo systemctl try-restart bind9 2>/dev/null || \
    # sudo systemctl try-restart named 2>/dev/null || \
    # true

    # sudo systemctl restart systemd-resolved || \
    # true

    # sudo systemctl restart bind9-resolvconf; \
    # sudo systemctl enable bind9-resolvconf || \
    # true
  fi

#   # Set DNS options.
#   if [ -f "/etc/bind/named.conf.options.orig" ]; then \
#     sudo cp -f /etc/bind/named.conf.options /etc/bind/named.conf.options.bak && \
#     sudo cp -f /etc/bind/named.conf.options.orig /etc/bind/named.conf.options && \
#     sudo cp -f /etc/bind/named.conf.options.bak /etc/bind/named.conf.options.bak2; \
#   else \
#     sudo cp -f /etc/bind/named.conf.options /etc/bind/named.conf.options.orig; \
#   fi; \
#   sudo sed -i '$i\
# \
#         version "not currently available";\
#         querylog yes;\
# ' \
#   /etc/bind/named.conf.options; \

  # Activate new bind DNS config.
  sudo systemctl restart bind9 2>/dev/null || \
  sudo systemctl restart named 2>/dev/null || \
  true; \

  sudo systemctl daemon-reload

  # res=$?
  echo ""

  return 0
  # return $res
}

discover_git_server_dns_install_main $@
