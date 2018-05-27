#!/bin/bash

DATE=$(date +%Y-%m-%d)
DES=/data/mysql_bak
MYSQL_U="root"
MYSQL_P="mysql"
MYSQL_H="127.0.0.1"

if [ ! -d "$DES" ] ; then
	mkdir -p "$DES"
fi

#获取数据库名称列表
DB=$(mysql -u$MYSQL_U -h$MYSQL_H -p$MYSQL_P -Bse 'show databases')

#循环执行备份所有的msyql数据库
for database in $DB
do
	if [ ! $database == "information_schema" ];then
		mysqldump -u$MYSQL_U -h$MYSQL_H -p$MYSQL_P $database  > "$DES/$database-${DATE}.sql"
	fi
done