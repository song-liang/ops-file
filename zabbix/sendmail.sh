#!/bin/bash
#
#messages=`echo $3 | tr '\r\n' '\n'`
#subject=`echo $2 | tr '\r\n' '\n'`
#echo "${messages}" | mail -s "${subject}" $1 >> /tmp/sendmail.log 2>&1

to=$1
subject=$2
body=$3
/usr/local/bin/sendEmail -f 1107179995@qq.com -t "$to" -s smtp.qq.com -u "$subject" -o message-content-type=html -o message-charset=utf8 -xu 1107179995@qq.com -xp wpqejgvlgsjtbabg  -m "$body" 2>>/tmp/22.log
