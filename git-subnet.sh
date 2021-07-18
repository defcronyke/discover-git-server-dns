#!/bin/bash

ip route ls | grep "`ip route ls | grep default | head -n 1 | sed 's/^.* dev \(.*\) proto .*$/\1/g'`" | tail -n +2 | head -n 1 | awk '{print $1}'

