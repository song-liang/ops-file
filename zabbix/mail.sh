#!/bin/bash
##
##zabbix邮件报警脚本
export zabbixemailto="$1"
export zabbixsubject="$2"
export zabbixbody="$3"

subject=`echo $2`
body=`echo $3| tr '\r\n' '\n'`

echo "$body" | sendmail -s "$subject" $1


