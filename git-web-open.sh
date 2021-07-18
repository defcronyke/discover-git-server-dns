#!/bin/bash

for i in `./git-web.sh`; do
	echo "$i"
	xdg-open "$i" 2>/dev/null
done

