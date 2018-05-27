#!/bin/bash
##统计日志中访问最多的的十个IP
#awk '{print $1"  "$18}' /tmp/nginx_log/access.log |grep -v yunjiankong|sort|uniq -c|sort -n|tail
awk '{print $1"  "$18}' /tmp/nginx_log/access.log |sort|uniq -c|sort -n|tail -15
