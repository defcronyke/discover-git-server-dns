#!/bin/bash

ip route ls | grep default | head -n 1 | sed 's/^.* dev \(.*\) proto .*$/\1/g'

