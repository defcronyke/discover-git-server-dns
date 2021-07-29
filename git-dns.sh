#!/usr/bin/env bash

for i in `./git-subnet.sh`; do
	outfile="hosts-$(date +%s.%N).txt"; nmap --unprivileged --open -nPn -oG "$outfile" --disable-arp-ping --discovery-ignore-rst $i -p 53 >/dev/null 2>&1; cat "$outfile" 2>/dev/null | grep "open" | tail -n +2 | awk '{print $2}' 2>/dev/null | sort | uniq; rm "$outfile" 2>/dev/null
done
