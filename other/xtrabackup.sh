

Host=172.22.14.134
User='root'
Passwd=''
Datebases='wl_mall_v2'
Full_target_Dir='/data/mysql/backup/$DATE'
DATE=$(date +%m%d-%H.%M)

# 全量
xtrabackup -H $Host -P 3306 --user=$User --password=$Passwd  \
	--backup --parallel=2 --databases=$Datebases 
	--target-dir=$Full_target_Dir

# 增量
xtrabackup -H $Host -P 3306 --user=$User --password=$Passwd  \
	--backup --parallel=2 --databases=$Datebases  \
	--incremental-basedir=/data/mysql/backup/databak \
	--target-dir=/data/mysql/backup/databak1 



# 恢复
xtrabackup --prepare --apply-log-only --target-dir=/data/mysql/backup/databak
xtrabackup --prepare --apply-log-only --target-dir=/data/mysql/backup/databak --incremental-dir=/data/xtrabackup1/
xtrabackup --prepare --apply-log-only --target-dir=/data/mysql/backup/databak --incremental-dir=/data/mysql/backup/databak2

xtrabackup --prepare --target-dir=/data/mysql/backup/databak