#!/bin/bash
##抓取指定类型的MySQL查询 

tshark -n -i eth1 -R 'mysql matches "SELECT|INSERT|DELETE|UPDATE"' -T fields -e "ip.src" -e "mysql.query" 