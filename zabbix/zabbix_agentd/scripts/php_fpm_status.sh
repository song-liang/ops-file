#!/bin/bash
# 检测 php-fpm 状态

HostURL="http://192.168.0.213/php_fpm_status?auto"

ping(){                           #检测php-fpm进程是否存在
    /sbin/pidof php-fpm | wc -l
}

listen_queue(){
        wget --quiet -O - $HostURL |grep "listen queue:"|grep -vE "len|max"|awk '{print$3}'
}

listen_queue_len(){
        wget --quiet -O - $HostURL |grep "listen queue len" |awk '{print$4}'
}

idle_processes(){
        wget --quiet -O - $HostURL |grep "idle processes" |awk '{print$3}'
}
active_processes(){
        wget --quiet -O - $HostURL |grep "active" |awk '{print$3}'|grep -v "process"
}
total_processes(){
        wget --quiet -O - $HostURL |grep "total processes" |awk '{print$3}'
}

max_active_processese(){
        wget --quiet -O - $HostURL |grep "max active processes:" |awk '{print$4}'
}

start_since(){
        wget --quiet -O - $HostURL |grep "start since: " |awk '{print$3}'
}

accepted_conn(){
        wget --quiet -O - $HostURL |grep "accepted conn" |awk '{print$3}'
}

max_children_reached(){
        wget --quiet -O - $HostURL |grep "max children reached" |awk '{print$4}'
}
slow_requests(){
        wget --quiet -O - $HostURL |grep "slow requests" |awk '{print$3}'
}
# 执行function
$1

