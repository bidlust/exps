#!/bin/bash

exe_path="/usr/local/prometheus/prometheus"
cfgfile="/usr/local/prometheus/prometheus.yml"

[ `echo $USER | tr '[A-Z]' '[a-z]' | grep root` != 'root' ] && {
	echo  "[Error] - Please use root account login and operate!"
	exit 1
}

[ ! -x $exe_path ] && {
	echo "[Error] - $exe_path not exist!"
	exit 1
}

[ ! -f $cfgfile ] && {
	echo "[Error] - $cfgfile not exist!"
	exit 1
}

proId=$(ps -ef|grep prometheus | grep -v grep | awk '{print $2}')
proId=${proId:=0}

[ $proId -gt 1 ] && {
	echo "[Info] - Find prometheus process and kill it..."
	sleep 2
	kill $proId
	[ $? -eq 0 ] && { 
		echo "######## [SUCCESS] - prometheus process killed! ########" 
		sleep 2
	} || {
		echo "######## [Error] - process kill failed, exit... ########"
		sleep 2
		exit 1
	}
} || {
	echo "######## [Info] - OK, prometheus process not found... ########"
	sleep 2
}

/usr/local/prometheus/prometheus --config.file="/usr/local/prometheus/prometheus.yml" >> /usr/local/prometheus/prometheus.out 2>&1 &
[ $? -eq 0 ] && { 
	echo "######## [SUCCESS] - prometheus start OK ########" 
	exit 0
} || { 
	echo "######## [Error] - process start failed, exit... ########" 
	exit 1 
}