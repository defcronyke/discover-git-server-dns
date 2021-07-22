#!/bin/bash

for i in "`./git-srv.sh`"; do
	echo "$i" | sed 's/\.$//g' | awk '{print "http://"$NF":"$(NF-1)"/"}' 2>/dev/null
done
