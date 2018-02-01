#!/bin/bash

docker exec -t zabbix_mysql mysql -uroot -pmysql -e "create database zabbix character set utf8;"
docker exec -t zabbix_mysql mysql -uroot -pmysql -e "grant all on zabbix.* to 'zabbix'@'%' identified by 'zabbix';"
