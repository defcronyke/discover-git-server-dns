#!/usr/bin/env bash
# Get all A records for zone "git" from any DNS server
# which responds to broadcast pings on our network.
#
# Run this on the git servers first to enable broadcast response:
#   echo 0 | sudo tee /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

IP_ADDRESSES=("$(IP_ADDRESSES=("$(for i in `ping -b -w1 $(ip route ls | head -n1 | awk '{print $3}' 2>/dev/null | sed 's/\(.*\)\..*$/\1.255/g') 2>/dev/null | awk '{print $4}' 2>/dev/null | head -n -4 | tail -n +2 | sed 's/:$//g' | sort | uniq`; do (dig +timeout=1 +short +nocomments @$i _git._tcp.git SRV | sed 's/;; connection timed out; no servers could be reached//g' | grep -v "^$" ) & done; for job in `jobs -p`; do wait $job; done)"); echo "${IP_ADDRESSES[@]}")"); for i in "${IP_ADDRESSES[@]}"; do echo "$i"; done
