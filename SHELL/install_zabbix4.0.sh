#!/bin/bash



function get_current_time_stamp()
{
echo `date "+%Y/%m/%d %H:%M:%S"`
}

function send_error()
{
echo -e "\e[1;45m [ Error ] `get_current_time_stamp` - $1 -\e[0m\n"
}

function send_success()
{
echo -e "\e[1;32m [ Success ] `get_current_time_stamp` - $1 -\e[0m\n"
}

function send_info()
{
echo -e "\e[1;34m [ Info ] `get_current_time_stamp` - $1 -\e[0m\n"
}

function send_warn()
{
echo -e "\e[1;33m [ Warn ] `get_current_time_stamp` - $1 -\e[0m\n"
}

sleepNum=1

# check AWS EC Server 
[ $(dmidecode --string system-uuid | grep ec2 | wc -l) -lt 1 ] && {
	send_error "this function script only fit AWS EC2 Server!"
	exit 
}
 
sleep $sleepNum

send_info "install denpendencies..."
yum -y install gcc libxml2-devel net-snmp net-snmp-devel libevent-devel curl curl-devel pcre* libevent libevent-devel libssh2-devel

sleep $sleepNum
send_info "install php7.4..."
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum-config-manager --enable remi-php74
yum install php  php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-ldap

sleep $sleepNum

send_info "create system user for zabbix..."
[ ! -d /usr/lib/zabbix ] && {
	mkdir /usr/lib/zabbix
}
groupadd --system zabbix
useradd --system -g zabbix -d /usr/lib/zabbix -s /sbin/nologin -c "Zabbix Monitoring System" zabbix

./configure --enable-server --enable-agent --enable-proxy --with-ssh2 --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2  


ln -s /usr/local/mysql5.7/lib/libmysqlclient.so.20  /usr/lib64/libmysqlclient.so.20
mkdir /var/lib/mysql
ln -s /tmp/mysql.sock /var/lib/mysql/mysql.sock

