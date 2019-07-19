#!/bin/bash

# 2019.7.19 songliang

# xtrabackup 备份mysql, 例子为备份单库，备份全库时请删除下方xtrabackup  --databases 参数

HOST=192.168.1.120
PORT=3307
USER='root'
PASSWRD='ROOT123'
DATABASES='mall'			# 指定备份的库，
DATA_DIR=/data/db/mysql/data		#  datadir 数据目录

DIR_BACKUP=/data/db/mysql/backup						# 备份主目录
DIR_DAILY_FULL_BAK=$DIR_BACKUP/$(date +%Y-%m-%d)/full				# 全量备份目录
DIR_Hour_IN_BAK=$DIR_BACKUP/$(date +%Y-%m-%d)/$(date +%Y-%-m-%d-%H-%M)          # 增量备份目录


# 全量备份
full_bak () {

		# 创建当日全量备份目录
		mkdir -p $DIR_DAILY_FULL_BAK

		# 执行备份
		xtrabackup -H  $HOST -P $PORT --user=$USER --password=$PASSWRD \
		--backup --parallel=2 \
		--databases=$DATABASES \
		--datadir=$DATA_DIR \
		--target-dir=$DIR_DAILY_FULL_BAK
}

# 增量备份
incremental_bak() {
		# 创建增量备份目录
		mkdir -p $DIR_Hour_IN_BAK

		xtrabackup -H  $HOST -P $PORT --user=$USER --password=$PASSWRD \
		--backup --parallel=2 \
		--databases=$DATABASES \
		--datadir=$DATA_DIR \
		--incremental-basedir=$DIR_DAILY_FULL_BAK \
		--target-dir=$DIR_Hour_IN_BAK
}

tar_clean() {
		#压缩一天前的备份,删除目录文件，删除7天前的备份文件
		cd $DIR_BACKUP
		if [ -d $(date  -d '1 days ago' +%Y-%m-%d) ];then
		    tar zcvf full_(date  -d '1 days ago' +%Y-%m-%d).tar.gz  $(date  -d '1 days ago' +%Y-%m-%d)  --remove-files
		    rm -rf `find . -name '*.tar.gz' -mtime 7`
		else
		    echo "没有一天前的备份目录"
		fi
}

case $1  in
 	full)
		echo "开始全量备份"
		full_bak
		tar_clean
		;;
		
	incremental)
		if [ ! -d $DIR_DAILY_FULL_BAK ]; 
		then
		   echo "没有全量备份目录，执行全量备份"
		   full_bak
		   tar_clean
		else
		   echo "增量备份"
		   incremental_bak
		fi
		;;

	 *)
		echo -e "\033[36mPlease select: \033[0m"
		echo -e "\033[31m full : 全量备份 \033[0m"
		echo -e "\033[31m incremental : 增量备份 \033[0m"
		echo -e "\033[33m example:\n./xtrabackup.sh full \033[0m"
		;;

esac
