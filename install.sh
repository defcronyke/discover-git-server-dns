#!/bin/bash
# Install git server bind DNS-based 
# service discovery features.

discover_git_server_dns_install() {
  echo ""
  echo "Installing and setting up bind DNS server for service discovery purposes if it wasn't installed yet..."
  echo ""

  sudo apt-get update && \
  sudo apt-get install -y bind9 nmap

  # Install zone file: /etc/bind/db.git
  echo ""
  echo "Adding or updating zone file: /etc/bind/db.git"
  echo "Using template file: ./db.git.tmpl"
  echo ""

  cat db.git.tmpl | \
  sed "s/{BIND_DB_GIT_SERIAL}/$(echo "`date +%Y%m%d`0${RANDOM}")/g" | \
  sed "s/{BIND_DB_GIT_HOSTNAME}/$(hostname)/g" | \
  sed "s/{BIND_DB_GIT_IP_ADDR}/$(ip a | grep `ip route ls | head -n 1 | awk '{print $5}'` | grep inet | awk '{print $2}' | sed 's/\/.*//g')/g" | \
  sudo tee /etc/bind/db.git

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

  echo "Enabling systemd service: bind9.service"
  echo ""
  sudo systemctl reenable bind9
  sudo systemctl restart bind9

  res=$?

  sudo systemctl daemon-reload
  echo ""

  return $res
}

discover_git_server_dns_install
