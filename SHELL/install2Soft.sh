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


function count_down()
{
	[ $1 -gt 1 ] && {
		for i in `seq $1 -1 1`
		do
			echo  -en "\e[1;34m [ Info ] Waiting ${i}s To Execute... -\e[0m"
			echo -en "\r\r"  # echo -e 处理特殊字符  \r 光标移至行首，但不换行
			sleep 1
		done
		echo -e "\n"
	} || {
		echo -e "count down func skip..."
	}
}



send_info "#############################################################"
send_info "############# Install Common Develop Soft For Centos7 #############"
send_info "#############################################################"
count_down 3

adm="admin"
pwd="Abc87113447!@"
sshPort=51028
mysqlPort=3306
httpPort=80
sshCfg="/etc/ssh/sshd_config"
seCfg="/etc/selinux/config"
suCfg="/etc/sudoers"
fwCfg="/etc/firewalld/zones/public.xml"
limitCfg="/etc/security/limits.conf"
sysCfg="/etc/sysctl.conf"
repoCfg="/etc/yum.repos.d/CentOS-Base.repo"
mysqlCfg="/etc/my.cnf"
hostname="slt-dev"
osVersion="/etc/redhat-release"
lockfile="/tmp/slt-dev"
prof="/etc/profile"
mgrepo="/etc/yum.repos.d/mongodb-org-3.4.repo"
spNum=3
pysoft="https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tar.xz"

[ `echo $USER | tr '[A-Z]' '[a-z]' | grep root` != 'root' ] && {
	send_error "Please use root account login and operate!"
	exit 1
}

[ ! -f ${lockfile} ] && send_error "Please first init your os!" && exit 1 

# 安装nginx
send_info "Install Nginx>>>"
sleep $spNum
yum install -y zlib zlib-devel openssl openssl-devel pcre pcre-devel 
yum install -y install nginx 

send_info "Install Mariadb>>>"
sleep $spNum
[ ! -d /var/log/mysql ] && mkdir /var/log/mysql && send_success "mysql log folder created OK!"
[ ! -z `rpm -qa|grep maria` ] && {
	send_info "remove mariadb packages..."
	rpm -e --nodeps `rpm -qa|grep maria` && send_success "mariadb packages removed OK!" || send_error "mariadb packages removed Failed!"
}
send_info "download mariadb init shell script..."
wget -P /tmp/ https://downloads.mariadb.com/MariaDB/mariadb_repo_setup && send_success "mariadb install script download OK!" || send_error "script download Failed!"
[ -f /tmp/mariadb_repo_setup ] && {
	sh /tmp/mariadb_repo_setup && yum install -y MariaDB-server MariaDB-client
}
echo "# created at `date +"%Y-%m-%d %H:%M:%S"`" > ${mysqlCfg}
cat >> ${mysqlCfg} << EOF
[client]
port = 3306
socket = /tmp/mysql.sock  
default-character-set=utf8mb4 
[mysqld]
server-id = 1
port = 3306
bind-address = 0.0.0.0
user = mysql 
basedir = /var/lib/mysql
datadir =  /var/lib/mysql
tmpdir = /tmp 
#skip-name-resolve
pid-file = /var/lib/mysql/mysql.pid
socket = /tmp/mysql.sock 
default_storage_engine = InnoDB
default_tmp_storage_engine = InnoDB
character-set-server = utf8mb4
collation_server=utf8mb4_general_ci
init_connect='SET NAMES utf8mb4'
lower_case_table_names = 1
max_connections = 10240
max_connect_errors = 10000
open_files_limit = 65535
interactive_timeout = 1800 
wait_timeout = 1800 
back_log = 900
max_allowed_packet = 128M
tmp_table_size = 16M
max_heap_table_size = 16M
query_cache_type = 1
query_cache_size = 128M 
query_cache_limit = 2M
sort_buffer_size = 2M
join_buffer_size = 2M

general_log = 0
general_log_file = /var/log/mysql/general.log
log-error = /var/log/mysql/error.log 
slow_query_log = 1
long_query_time = 2
log_throttle_queries_not_using_indexes = 0
slow_query_log_file = /var/log/mysql/slow.log 
log-queries-not-using-indexes = 1

#log_bin = /var/log/mysql/mysql-bin.log


[mysqldump]
quick
max_allowed_packet = 512M

[mysql]
auto-rehash
socket = /tmp/mysql.sock
default-character-set=utf8mb4

EOF

send_info "set mysql config file auth..."
[ -z `grep mysql /etc/passwd` ] && groupadd mysql && useradd -g mysql mysql -M -s /sbin/nologin
chown mysql:mysql /etc/my.cnf 

sleep $spNum

send_info "To start mariadb..."
systemctl start mariadb.service 


send_info "Install PHP7>>>"
sleep $spNum
yum -y install wget vim pcre pcre-devel openssl openssl-devel libicu-devel gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel ncurses ncurses-devel curl curl-devel krb5-devel libidn libidn-devel openldap openldap-devel nss_ldap jemalloc-devel cmake boost-devel bison automake libevent libevent-devel gd gd-devel libtool* libmcrypt libmcrypt-devel mcrypt mhash libxslt libxslt-devel readline readline-devel gmp gmp-devel libcurl libcurl-devel openjpeg-devel
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum -y install php72w php72w-cli php72w-common php72w-devel php72w-embedded php72w-fpm php72w-gd php72w-mbstring php72w-mysqlnd php72w-opcache php72w-pdo php72w-xml php72w-bcmath 

sleep $spNum

send_info "Install Python3..."
yum -y groupinstall "Development tools"
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel
yum install -y libffi-devel zlib1g-dev
yum install zlib* -y
wget $pysoft
tar -xvJf  Python-3.7.2.tar.xz
cd Python-3.7.2
./configure --prefix=/usr/local/python3 --enable-optimizations --with-ssl 
make && make install
echo "export \$PATH=\$PATH:/usr/local/python3" >> ${prof}
source ${prof}
python3 -V
pip3 -V 

sleep $spNum 

send_info "Install Redis..."
yum install -y redis 
systemctl start redis.service 

send_info "Install mongodb..."
cat >> ${mgrepo} << EOF
[mongodb-org-3.4]  
name=MongoDB Repository  
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/  
gpgcheck=1  
enabled=1  
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc  
EOF

yum install -y mongodb-org
systemctl start mongod.service



