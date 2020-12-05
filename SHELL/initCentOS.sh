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


#Linux 初始化脚本
#适用于Centos系列；

echo "***********************************"
echo "***********************************"
echo "******Do OS Init Work For You******"
echo "***********************************"
echo "***********************************"

sleep 3

#检测当前执行用户名；
if [ $(whoami | tr '[A-Z]' '[a-z']) != 'root' ];then
	echo "[Error] - Please use root accout to execute this script!"
	exit 1
fi 

cd /root
#创建基础目录;
mkdir backup 
mkdir download
mkdir shell 
mkdir python
mkdir php 
mkdir mysql 
mkdir nginx 
mkdir go 
mkdir java 


#设置公共变量
sshPort=51028
sshFile="/etc/ssh/sshd_config"


#1). 将centos中的YUM软件安装源切换为阿里云；
echo "Change Yum Repos Source To Aliyun>>>"
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backupe
wget -O /etc/yum.repo.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache
if [ $? -ne 0 ];then
	echo "[Error] yum source modify failed"
	exit 1
fi 

#2). 执行系统更新
while read -n 1 -p "Do you want to execute system update(yum update) ? [y/n] ";do 
	case $REPLY  in 
	( Y | y)
		send_info "[Info] - OK! Let's begin to update system packages>>>>>>"
		sleep 2 
		yum -y update 
		break 
		;;
	(N | n)
		send_info "You deny update system, so skip..."
		break 
		;;
	(*)
		  send_error "[Info] error choice! ";;
	esac
done 


#3). 安装基础工具包
echo "Install Basic Tool Packages>>>"
yum install gcc gcc-c++ lrzsz* netstat-tools

#4). 配置ssh端口
send_info "Config SSH Port And Privileges>>>"
sleep 1
if [ -f $sshFile ];then
	send_info "backup ssh file>>>" && cp $sshFile ~/backup/
	current_ssh_port=$(grep -E "^Port\s+[0-9]+" $sshFile  | awk '{print $2}')
	if [ -z "$current_ssh_port" ];then
		current_ssh_port=22 
	fi 
	echo "backup ssh file..." && cp $sshFile /root/backup/ && "[SUCCESS] - backup OK!"
	while read -n 1 -p "Your current ssh port is $current_ssh_port , do you want to set another different one? [y/n] ";do 
		case $REPLY  in 
			( Y | y)
				send_info "To reset ssh port >>>"
				#设置ssh端口
				while read -p "Please Input New SSH Port Number: ";do 
					if [ ! -z $REPLY ];then 
						check_length=$(echo "$REPLY" | sed "s/[0-9]\{1,\}//g")
						if [ -z "$check_length" ];then 
							send_info "New SSH Port:[$REPLY]"
							#将已设置的有效Port删除
							sed -i '/^Port[[:space:]]\{1,\}[0-9]\{1,\}/d' $sshFile
							#添加空行
							echo >> $sshFile
							#重设端口号
							sed -i '$aPort '$REPLY $sshFile
							if [ $? -eq 0 ];then 
								send_success "Set ssh port OK!"
							fi 
							break 
						else 
							send_error "You input wrong number!"
						fi 
					fi 
				done 
				break
				;;
			(N | n)
				send_info "[Info] - Skip Setting SSH port and leave it default($current_ssh_port)."
				break
				;;
			(*)
				send_error "error choice";;
		esac
	done 
else 
	echo "[Warn] - file $sshFile not found..."
	echo "We can't change ssh port......"
fi

#5). 是否允许Root登录；
while read -n 1 -p "whether Deny Root Login? [y/n] ? ";do 
	case $REPLY  in 
		( Y | y)
				sed -i '/^PermitRootLogin/d' $sshFile
				echo  >> $sshFile
				sed -i '$aPermitRootLogin no' $sshFile
				if [ $? -eq 0 ];then 
					send_success "PermitRootLogin Set OK!"
				fi 
				break
				;;
		(N | n)
				send_info "[Info] - Skip Setting Root Login Privilege..."
				break
				;;
		(*)
			send_error "error choice";;
	esac
done 


#6). Nginx
send_info "Install Nginx>>>"
sleep 2 
yum install -y install nginx 

#7). Mariadb
send_info "Install Mariadb>>>"
sleep 2 
wget -P /tmp/ https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sh /tmp/mariadb_repo_setup

#8). PHP
send_info "Install PHP7>>>"
sleep 2 

#依赖包；
yum -y install wget vim pcre pcre-devel openssl openssl-devel libicu-devel gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel ncurses ncurses-devel curl curl-devel krb5-devel libidn libidn-devel openldap openldap-devel nss_ldap jemalloc-devel cmake boost-devel bison automake libevent libevent-devel gd gd-devel libtool* libmcrypt libmcrypt-devel mcrypt mhash libxslt libxslt-devel readline readline-devel gmp gmp-devel libcurl libcurl-devel openjpeg-devel

#镜像源;
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

#正式安装
yum -y install php72w php72w-cli php72w-common php72w-devel php72w-embedded php72w-fpm php72w-gd php72w-mbstring php72w-mysqlnd php72w-opcache php72w-pdo php72w-xml php72w-bcmath 


