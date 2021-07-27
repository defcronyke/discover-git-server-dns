#!/bin/bash
# Install git server bind DNS-based 
# service discovery features.

discover_git_server_dns_install() {
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

  sudo ls /etc/bind/db.git >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo ""
    echo "NOTICE: Installing new DNS zone file: /etc/bind/db.git"
    echo ""

    cat db.git.tmpl | sudo tee /etc/bind/db.git

    count=1
    for i in "$(cat /etc/resolv.conf | grep "nameserver" | awk '{print $NF}')"; do
      echo "@       IN      NS      ns${count}" | sudo tee -a /etc/bind/db.git
      ((count++))
    done

    echo "@       IN      NS      ns${count}" | sudo tee -a /etc/bind/db.git
    
    echo "@       IN      AAAA    ::1" | sudo tee -a /etc/bind/db.git
    
    count=1
    for i in "$(cat /etc/resolv.conf | grep "nameserver" | awk '{print $NF}')"; do
      echo "ns${count}       IN      A      $i" | sudo tee -a /etc/bind/db.git
      ((count++))
    done

    echo "ns${count}       IN      A      {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git
    
    echo "{BIND_DB_GIT_HOSTNAME}.       IN      A       {BIND_DB_GIT_IP_ADDR}" | sudo tee -a /etc/bind/db.git
    
    echo "_git._tcp  IN      SRV     5 10 1234 {BIND_DB_GIT_HOSTNAME}." | sudo tee -a /etc/bind/db.git

    cat /etc/bind/db.git | \
    sed "s/{BIND_DB_GIT_SERIAL}/$(echo "`date +%Y%m%d`$(echo $RANDOM | tail -c 3)")/g" | \
    sed "s/{BIND_DB_GIT_HOSTNAME}/$(hostname)/g" | \
    sed "s/{BIND_DB_GIT_IP_ADDR}/$(ip a | grep `ip route ls | head -n 1 | awk '{print $5}'` | grep inet | awk '{print $2}' | sed 's/\/.*//g')/g" | \
    sudo tee -a /etc/bind/db.git

  else
    echo ""
    echo "NOTICE: Not installing new DNS zone file because it was already installed: /etc/bind/db.git"
    echo ""
  fi

  # Activate the "db.git" zone file by including it 
  # in bind config file, if it's not activated yet: 
  # /etc/bind/named.conf.local
  echo ""
  echo "Activating \"/etc/bind/db.git\" zone file if necessary,"
  echo "by including it in bind config file: /etc/bind/named.conf.local"
  echo ""

  sudo grep /etc/bind/named.conf.local -e "zone \"git\"" >/dev/null
  if [ $? -ne 0 ]; then
    echo ""
    cat named.conf.local.tmpl | sudo tee -a /etc/bind/named.conf.local
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
  else
    echo "NOTICE: Not enabling bind9.service because there was already some DNS service running."
    echo ""

    sudo systemctl try-restart bind9 2>/dev/null || \
    sudo systemctl try-restart named 2>/dev/null || \
    true
  fi

  res=$?

  sudo systemctl daemon-reload
  echo ""

  return $res
}

discover_git_server_dns_install
