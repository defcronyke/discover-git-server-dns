#!/usr/bin/env bash

# top priority route
ip route ls | grep "tun" | sed -E 's/^.*\s+dev\s+([^[:space:]]+)\s*.*$/\1/g' | sort | uniq

# default route
ip route ls | grep "default" | sed -E 's/^.*\s+dev\s+([^[:space:]]+)\s*.*$/\1/g' | sort | uniq
