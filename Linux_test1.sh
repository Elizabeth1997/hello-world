#!/bin/bash
cd /root/temp
i=1
while [ $i -le 30 ]
do
	if [[ $i -le 9 ]]; then
		#-m 表示使用chmod模式
		mkdir temp_$(whoami)_0$i
		chmod 764 temp_$(whoami)_0$i
	else
		mkdir temp_$(whoami)_$i
		chmod 764 temp_$(whoami)_$i
	fi
i=$((i+1))
done