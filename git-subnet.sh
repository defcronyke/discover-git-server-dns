#!/bin/bash

ip route ls | grep "`./git-nic.sh`" | tail -n +2 | head -n 1 | awk '{print $1}'

