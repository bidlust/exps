#!/bin/bash

#https://mariadb.com/kb/en/yum/

echo "check repo config file>>>"
if [ -f /etc/yum.repos.d/MariaDB.repo ];then
	mv /etc/yum.repos.d/MariaDB.repo /etc/yum.repos.d/MariaDB.repo.bak
	echo "[info] /etc/yum.repos.d/MariaDB.repo been removed!"
else
	echo "[info] /etc/yum.repos.d/MariaDB.repo not found!"
fi

sleep 1
echo "to remove system mariadb packages>>>"
if [ $(rpm -qa|grep mariadb | wc -l) gt 1 ];then
	echo "[ $(rpm -qa|grep mariadb) ] found, begin to remove..."
	sleep 1
	rpm -e  --nodepth $(rpm -qa|grep mariadb)
	if [ $? -eq 0 ];then
		echo "[success] - Removed OK!"
	else 
		echo "[Error] - Removed Failed!"
	fi
fi

sleep 1
if [ -f /etc/my.cnf ];then 
	echo "[info] /etc/my.cnf found, begin to remove..."
	mv /etc/my.cnf /etc/my.cnf.bak 
	if [ $? -eq 0 ];then 
		echo "/etc/my.cnf Remove OK!"
	else 
		echo "/etc/my.cnf Remove Failed!"
	fi 
fi

sleep 1
echo "to set up mariadb repos>>>"
echo "[mariadb]" >> /etc/yum.repos.d/MariaDB.repo
echo "name = MariaDB" >> /etc/yum.repos.d/MariaDB.repo
echo "baseurl = http://yum.mariadb.org/10.4/centos7-amd64" >> /etc/yum.repos.d/MariaDB.repo
echo "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/MariaDB.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/MariaDB.repo
rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
yum clean all

sleep 1 
echo "try install mariadb 10.4>>>"
yum install MariaDB-server galera-4 MariaDB-client MariaDB-shared MariaDB-backup MariaDB-common 

sleep 1
echo "to start mariadb service>>>"
systemctl start mariadb.service 

sleep 1
echo "mariadb installation finished!"









