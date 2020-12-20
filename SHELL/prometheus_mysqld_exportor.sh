#!/bin/bash

exe_path="/usr/local/prometheus/mysqld_exporter"
cfg_file="/usr/local/prometheus/.my.cnf"
out="/usr/local/prometheus/mysqld_exporter.out"

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
proId=$(ps -ef|grep mysqld_exporter | grep -v grep | awk '{print $2}')
proId=${proId:=0}

[ $proId -gt 1 ] && {
	echo "[Info] - Find mysqld_exporter process and kill it..."
	sleep 2
	kill $proId
	[ $? -eq 0 ] && { 
		echo "######## [SUCCESS] - mysqld_exporter process killed! ########" 
		sleep 2
	} || {
		echo "######## [Error] - process kill failed, exit... ########"
		sleep 2
		exit 1
	}
} || {
	echo "######## [Info] - OK, mysqld_exporter process not found... ########"
	sleep 2
}

 $exe_path  --web.listen-address=0.0.0.0:9104 \
  --config.my-cnf="$cfg_file" \
  --collect.slave_status \
  --collect.slave_hosts \
  --log.level=error \
  --collect.info_schema.processlist \
  --collect.info_schema.innodb_metrics \
  --collect.info_schema.innodb_tablespaces \
  --collect.info_schema.innodb_cmp \
  --collect.info_schema.innodb_cmpmem  >>  $out 2>&1 &
  
# $exe_path --config.my-cnf="$cfg_file" >>  $out 2>&1 &

[ $? -eq 0 ] && { 
	echo "######## [SUCCESS] - mysqld_exporter start OK ########" 
	exit 0
} || { 
	echo "######## [Error] - process start failed, exit... ########" 
	exit 1 
}