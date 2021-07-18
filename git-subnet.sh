#!/bin/bash

for i in `./git-nic.sh`; do
	ip route ls | grep "$i" | grep "proto" | awk '{print $1}' | grep -v "default"
done

