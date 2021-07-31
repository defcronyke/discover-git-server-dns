#!/usr/bin/env bash
#
#-----------------------------
#
# WARNING: THIS SCRIPT WILL DESTROY YOUR BIND DNS CONFIG FILES
# LOCATED IN THE FOLDER: /etc/bind
# 
# It won't ask first if you're sure that you want to destroy 
# the config! It's only meant to be used as a convenience for 
# developers.
#
# DON'T RUN THIS SCRIPT UNLESS YOU WANT TO DESTROY YOUR
# BIND /etc/bind CONFIG FILES!!
#
# YOU HAVE BEEN WARNED.
#
#-----------------------------
#

discover_git_server_dns_util_remove_bind_config() {

  current_dir_before_bind_cleanup="$PWD"

  cd /etc/bind || return 1

  sudo systemctl disable bind9 2>/dev/null; sudo systemctl stop bind9 2>/dev/null; sudo rm -rf .git 2>/dev/null; sudo rm db.git 2>/dev/null; echo "" | sudo tee named.conf.local 2>/dev/null; sudo rm -rf ~/git/etc/bind.git 2>/dev/null

  cd "$current_dir_before_bind_cleanup"

  return 0
}

discover_git_server_dns_util_remove_bind_config $@
