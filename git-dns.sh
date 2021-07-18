#!/bin/bash

outfile="hosts-$(date +%s.%N).txt"; nmap --unprivileged --open -nPn -oG "$outfile" --disable-arp-ping --discovery-ignore-rst $(./git-subnet.sh) -e $(./git-nic.sh) -p 53 >/dev/null 2>&1; cat "$outfile" | grep "open" | tail -n +2 | awk '{print $2}' | sort | uniq; rm "$outfile"

