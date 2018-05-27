#!/bin/bash
##抓取mysql的查询
tshark -n -i eth1 -R 'mysql.query' -T fields -e "ip.src" -e "mysql.query"

#另一种方法
#tshark -i eth1 port 3307  -d tcp.port==3307,mysql -z "proto,colinfo,mysql.query,mysql.query"