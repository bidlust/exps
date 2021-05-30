#!/bin/bash

set -e 

declare -r SERVICE="prometheus"
declare -r CONFIG="/etc/prometheus.yml"
declare -r LOGFILE="/var/log/prometheus.log"
declare -r DATAPATH="/data/prometheus"
declare -r RETENTION="7d"


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


function init_service(){
	[ ! -e $SERVICE ] && {
		send_error "${SERVICE} not found..."
		exit 
	}
	[ ! -f $LOGFILE ] && {
		touch $LOGFILE
	}
	[ ! -f $CONFIG ] && {
		send_error "ocnfig file ${CONFIG} not found..."
		exit 
	}
	[ ! -d $DATAPATH ] && {
		mkdir -p $DATAPATH
	}
}

function start_service(){
	send_info "<<< begin to start service ${SERVICE} >>>"
	nohup prometheus \
	--config.file="${CONFIG}" \
	--storage.tsdb.path="${DATAPATH}" \
	--storage.tsdb.retention.time="${RETENTION}" \
	--web.enable-lifecycle >> "${LOGFILE}" 2>&1 &
	send_info "<<< start ${SERVICE} process finish >>>"
}

function check_service(){
	send_info "<<< check service ${SERVICE} >>>"
	pid=`ps -ef | grep -v grep | grep ${SERVICE} | awk '{print $2}'`
	if [ "x${pid}" == "x" ]
    then
        echo "${SERVICE} is not running."
        exit 1
    else
        ps -ef | grep -v grep | grep ${SERVICE} 
        echo "${SERVICE} is running now(pid=$pid)."
    fi
}

function stop_service(){
	send_info "<<< stop service ${SERVICE} >>>"
	ps -ef | grep -v grep | grep ${SERVICE} | awk '{print $2}' | while read pid
    do
        echo "[`date '+%Y-%m-%d %H:%M:%S'`] kill -9 $pid"
        kill -9 $pid
    done
}

function main(){

	init_service()
	
    case $1 in
    "start")
        start_service
    ;;
    "stop")
        stop_service
    ;;
    "restart")
        stop_service
        sleep 5
        start_service
    ;;
    "status")
        check_status
    ;;
    "watchdog")
        watchdog
    ;;
    *)
        echo "Usage: ${0} start | stop | restart | status | watchdog"
    ;;
    esac
}


main $@
