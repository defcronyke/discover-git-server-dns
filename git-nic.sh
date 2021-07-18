#!/bin/bash

ip route ls | head -n 1 | sed -E 's/^.*\s+dev\s+([^[:space:]]+)\s*.*$/\1/g'

