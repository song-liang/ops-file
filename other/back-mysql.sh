#!/bin/bash

DATE=$(date +%Y-%m-%d)
backdir=/home/backup/mysql_bak
MYSQL_U="root"
MYSQL_P="123456"
MYSQL_H="127.0.0.1"

if [ ! -d "$backdir" ] ; then
        mkdir -p "$backdir"
fi

# 逻辑备份
#获取数据库名称列表
DB=$(mysql -u$MYSQL_U -h$MYSQL_H -p$MYSQL_P -Bse 'show databases')

#循环执行备份所有的msyql数据库
mkdir -p "$backdir/$DATE"
for database in $DB
do
        if [ ! $database == "information_schema" ];then
                /usr/local/mysql/bin/mysqldump -u$MYSQL_U -h$MYSQL_H -p$MYSQL_P $database  > $backdir/$DATE/$database-${DATE}.sql
        fi
done

cd $backdir
tar zcvf $DATE.tar.gz $DATE --remove-files

# xtrabackup物理全量备份
#xtrabackup --user=$MYSQL_U --password=$MYSQL_P --socket=/tmp/mysql.sock --datadir=/data/mysql/ --backup --parallel=2 --stream=tar --target-dir=/home/backup/tmp | gzip - > /home/backup/xtrabackup-$DATE.tar.gz


find $backdir  -mtime +7 -name "*.gz" -exec rm -f {} \;