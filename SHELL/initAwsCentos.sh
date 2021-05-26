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
send_info "############# Init Your CentOS Operation System #############"
send_info "#############################################################"
count_down 5

backupDir="/root/backup"
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
hostname="maxscale"
osVersion="/etc/redhat-release"
lockfile="/tmp/slt-dev"
prof="/etc/profile"
spNum=3
dataDir="/var/data"
yumSource=" /etc/yum.repos.d/CentOS-Base.repo"
baseCommand=("wget" "curl" "lrzsz" "dos2unix" "netstat-tools" "net-tools" "nmap" "makecache" "unzip" "zip" "make" "cmake" "autoconf" "telnet")


[ -f ${lockfile} ] && send_warn "Sorry, This script had ever been executed..." && exit 1

send_info "Check operate account..."
sleep $spNum

[ `whoami` != "root" ] && {
	send_error "the role execute this script must be root!"
	exit
}

# check AWS EC Server 
[ $(dmidecode --string system-uuid | grep ec2 | wc -l) -lt 1 ] && {
	send_error "this function script only fit AWS EC2 Server!"
	exit 
}

# send_info "To check OS Version..."
# [ ! -f osVersion ] && send_error "OS Version Check Error! ${osVersion} not found..." && exit 1
# [ -z `grep "CentOS Linux release 7" ${osVersion}` ] && send_error "Sorry, this script file only fit CentOS Linux release 7！" && exit 1
echo "" > /tmp/slt-dev
echo "# created at `date +"%Y-%m-%d %H:%M:%S"`" >> ${lockfile}

# sleep $spNum

send_info "backup system files..."
[ ! -d ${backupDir} ] && mkdir ${backupDir}
[ -f ${sshCfg} ] && cp ${sshCfg} ${backupDir} && send_info "${sshCfg} copy OK!"
[ -f ${suCfg} ] && cp ${suCfg} ${backupDir} && send_info "${suCfg} copy OK!"
[ -f ${seCfg} ] && cp ${seCfg} ${backupDir} && send_info "${seCfg} copy OK!"
[ -f ${fwCfg} ] && cp ${fwCfg} ${backupDir} && send_info "${fwCfg} copy OK!"
[ -f ${limitCfg} ] && cp ${limitCfg} ${backupDir} && send_info "${limitCfg} copy OK!"
[ -f ${sysCfg} ] && cp ${sysCfg} ${backupDir} && send_info "${sysCfg} copy OK!"
[ -f ${repoCfg} ] && cp ${repoCfg} ${backupDir} && send_info "${repoCfg} copy OK!"
[ -f ${mysqlCfg} ] && cp ${mysqlCfg} ${backupDir} && send_info "${mysqlCfg} copy OK!"
[ -f ${prof} ] && cp ${prof} ${backupDir} && send_info "${prof} copy OK!"
[ -f ${yumSource} ] && cp ${yumSource} ${backupDir} && send_info "${yumSource} copy OK!"


sleep $spNum

send_info "create basic folders..."
[ ! -d /root/download ] && mkdir /root/download && send_success "download directory created OK!"
[ ! -d /root/shell ] && mkdir /root/shell && send_success "shell directory created OK!"
[ ! -d /root/python ] && mkdir /root/python && send_success "python directory created OK!"
[ ! -d /root/php ] && mkdir /root/php  && send_success "php directory created OK!"
[ ! -d /root/mysql ] && mkdir /root/mysql  && send_success "mysql directory created OK!"
[ ! -d /root/nginx ] && mkdir /root/nginx && send_success "nginx directory created OK!"
[ ! -d /root/go ] && mkdir /root/go && send_success "golang directory created OK!"
[ ! -d /root/java ] && mkdir /root/java && send_success "java directory created OK!"

[ ! -d ${dataDir} ] && mkdir ${dataDir} && send_success "${dataDir} directory created OK!"

sleep $spNum

for cmd in ${baseCommand[@]}
do
	[ `rpm -qa | grep $cmd | wc -l` -lt 1 ] && {
		send_info "install $cmd command..."
		yum -y install $cmd 
} || {
	send_info "$cmd command check OK!"
}
done 

#设置hostname
[  ! -z "$hostname" ] && {
	send_info "begin to set hostname.."
	hostnamectl set-hostname $hostname && send_success "set hostname OK! hostname: ${hostname}"
}

send_info "Begin to update system..."
sleep $spNum

yum -y update 

sleep $spNum

# 关闭SELinux;
[ -z `getenforce | tr '[A-Z]' '[a-z]' | grep disabled` ] && [ -f $seCfg ] && {
	send_info "close selinux..."
	sed -i 's/enforcing/disabled/' $seCfg && send_info "close selinux OK!" || send_error "close selinux Failed!"
}

sleep $spNum

# 设置系统最大文件描述符；
echo "# created at `date +"%Y-%m-%d %H:%M:%S"`" > ${limitCfg}
echo "* soft nofile 65535" >>  ${limitCfg}
echo "* hard nofile 65535" >>  ${limitCfg}
echo "* soft nproc 65535" >>  ${limitCfg}
echo "* hard nproc 65535" >>  ${limitCfg}

# 内核优化

echo "# created at `date +"%Y-%m-%d %H:%M:%S"`" > ${sysCfg}
echo "vm.swappiness=0" >> ${sysCfg}
echo "net.core.somaxconn=1024" >> ${sysCfg}
echo "net.ipv4.tcp_max_tw_buckets=5000" >> ${sysCfg}
echo "net.ipv4.tcp_max_syn_backlog=1024" >> ${sysCfg}

cat >> ${sysCfg} << EOF

#决定检查过期多久邻居条目
net.ipv4.neigh.default.gc_stale_time=120
 
#使用arp_announce / arp_ignore解决ARP映射问题
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce=2
net.ipv4.conf.lo.arp_announce=2
 
# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1
 
# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1
 
#关闭路由转发
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
 
#开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
 
#处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
 
#关闭sysrq功能
kernel.sysrq = 0
 
#core文件名中添加pid作为扩展名
kernel.core_uses_pid = 1
 
# 开启SYN洪水攻击保护
net.ipv4.tcp_syncookies = 1
 
#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536
 
#设置最大内存共享段大小bytes
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
 
#timewait的数量，默认180000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
 
#每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 262144
 
#限制仅仅是为了防止简单的DoS 攻击
net.ipv4.tcp_max_orphans = 3276800
 
#未收到客户端确认信息的连接请求的最大值
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
 
#内核放弃建立连接之前发送SYNACK 包的数量
net.ipv4.tcp_synack_retries = 1
 
#内核放弃建立连接之前发送SYN 包的数量
net.ipv4.tcp_syn_retries = 1
 
#启用timewait 快速回收
net.ipv4.tcp_tw_recycle = 1
 
#开启重用。允许将TIME-WAIT sockets 重新用于新的TCP 连接
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
 
#当keepalive 起用的时候，TCP 发送keepalive 消息的频度。缺省是2 小时
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 15
 
#允许系统打开的端口范围
net.ipv4.ip_local_port_range = 1024 65000
 
#修改防火墙表大小，默认：65536 防火墙关闭时，不需要配置此参数。
net.netfilter.nf_conntrack_max=655350
net.netfilter.nf_conntrack_tcp_timeout_established=1200
 
# 确保无人能修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

EOF

sysctl -p

echo "export TMOUT=1200" >> /etc/profile
source /etc/profile

send_info "install firewalld..."
yum -y install firewalld
systemctl start firewalld 
firewall-cmd --add-port=22/tcp --permanent 
firewall-cmd --add-port=51028/tcp --permanent 
firewall-cmd --add-port=80/tcp --permanent 
firewall-cmd --add-port=10050/tcp --permanent 
firewall-cmd --add-port=10051/tcp --permanent 
firewall-cmd --add-port=3306/tcp --permanent 
firewall-cmd --reload

#set datetime 
send_info "setting timezone to Shanghai..."
[ -e /etc/localtime ] && { 
	cp /etc/localtime /etc/localtime.bak 
	rm -rf /etc/localtime
}

[ -e /usr/share/zoneinfo/Asia/Shanghai ] && {
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}
send_success "OS Init OK!"