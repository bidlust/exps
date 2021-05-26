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

[ `whoami` != "root" ] && {
	send_error "the role execute this script must be root!"
	exit
}

lockFile="/tmp/initLock"

send_info "#############################################################"
send_info "############# Init Your CentOS Operation System #############"
send_info "#############################################################"

sleep 5

[ -e ${lockFile} ] && {
	send_info "lock file found, stop to execute... ${lockFile}"
}

echo "" > ${lockFile}
echo "# created at `date +"%Y-%m-%d %H:%M:%S"`" >> ${lockFile}





