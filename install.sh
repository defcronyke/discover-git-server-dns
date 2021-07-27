#!/bin/bash
# Install git server bind DNS-based 
# service discovery features.

discover_git_server_dns_install() {
  echo ""
  echo "Updating bind DNS server for service discovery installer..."
  echo ""

  git pull origin master

  ./install-main.sh $@

  return $res
}

discover_git_server_dns_install $@
