#!/bin/bash

for i in "`./git-web.sh`"; do
	last="$i"

	res=`curl -sL $i 2>/dev/null | grep -Po '>\K.*\.git?(?=<)' | sed 's/^.*>\(.*\.git\)$/\1/g'`
	res_res=$?
	#if [ $? -ne 0 ]; then
	#	continue
	#else

		for repo in ${res[@]}; do
	#for repo in `curl -sL $i 2>/dev/null | grep -Po '>\K.*\.git?(?=<)' | sed 's/^.*>\(.*\.git\)$/\1/g' 1>/dev/null`; do

			if [ $res_res -ne 0 ]; then
            		    continue
		        else

			out="`echo "$repo" | grep "\.git"`"
	
			echo "out= $out"
	
			if [ ! -z "$out" ]; then
				echo "${last}${out}"
			fi
		
			#if [ $? -ne 0 ]; then
			#	continue
			#fi

			#echo "${last}${repo}"

			fi
		done
	#fi
done

