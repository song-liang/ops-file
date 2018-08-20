#!/bin/bash
##
## songliang 2018.8.16
## redis 安装脚本

#redis_3_2=http://download.redis.io/releases/redis-4.0.11.tar.gz
redis_4=http://download.redis.io/releases/redis-4.0.11.tar.gz
#redis_5=http://download.redis.io/releases/redis-4.0.11.tar.gz

check_ok () {
if [ $? != 0 ]
then
    echo "Error, Check the error log."
    exit 1
fi
}


##函数:编译安装与配置
redis_configure () {
	## 添加用户
    if ! grep '^redis:' /etc/passwd
    then
        useradd -M redis -s /sbin/nologin
    fi
	## 编译
	make MALLOC=libc PREFIX=/usr/local/redis install
	check_ok
	mkdir  /usr/local/redis/etc/ /usr/local/redis/var/
	chown -R redis:redis /usr/local/redis/var/
	cp redis.conf  /usr/local/redis/etc/
	## 开启后台daemon和aof可持久化
	sed -i 's#daemonize no#daemonize yes#g'  /usr/local/redis/etc/redis.conf
	sed -i 's#appendonly no#appendonly yes#g'  /usr/local/redis/etc/redis.conf
}


##选择版本
while :
do
  read -p "Please chose the version of Redis. (3.2|4.0|5.0)" redis_v
  if [ "$redis_v" == "3.2" -o "$redis_v" == "4.0" -o "$redis_v == 5.0" ]
  then
     break
  else
     echo "only (3.2) or (4.0) or (5.0)"
  fi
done


cd /usr/local/src
#选择版本安装
case $redis_v in
 	3.2)
		[ -f ${redis_3##*/} ] || wget $redis_3
		tar zxvf ${redis_3##*/}
		cd `echo ${redis_3##*/}|sed 's/.tar.gz//g'`
		redis_configure
		;; 
	4.0)
		[ -f ${redis_4##*/} ] || wget $redis_4
		tar zxvf ${redis_4##*/}
		cd `echo ${redis_4##*/}|sed 's/.tar.gz//g'`		
		redis_configure
		;;
	5.0)
		[ -f ${redis_5##*/} ] || wget $redis_5
		tar zxvf ${redis_5##*/}
		cd `echo ${redis_5##*/}|sed 's/.tar.gz//g'`
		redis_configure
		;;
	*)
		echo "only (3.2) or (4.0) or (5.0)"
		;;
esac



##配置启动文件
if [ -f /etc/init.d/redis-server ]
then
	/bin/mv /etc/init.d/redis-server  /etc/init.d/redis-server_`date +%Y.%m.%d.%M`
fi

(
cat << "EOF"
#!/bin/sh
#
# redis        init file for starting up the redis daemon
#
# chkconfig:   - 20 80
# description: Starts and stops the redis daemon.
 
# Source function library.
. /etc/rc.d/init.d/functions
 
name="redis-server"
basedir="/usr/local/redis"
exec="$basedir/bin/$name"
pidfile="$basedir/var/redis.pid"
REDIS_CONFIG="$basedir/etc/redis.conf"
 
[ -e /etc/sysconfig/redis ] && . /etc/sysconfig/redis
 
lockfile=/var/lock/subsys/redis
 
start() {
    [ -f $REDIS_CONFIG ] || exit 6
    [ -x $exec ] || exit 5
    echo -n $"Starting $name: "
    daemon --user ${REDIS_USER-redis} "$exec $REDIS_CONFIG"
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}
 
stop() {
    echo -n $"Stopping $name: "
    killproc -p $pidfile $name
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}
 
restart() {
    stop
    start
}
 
reload() {
    false
}
 
rh_status() {
    status -p $pidfile $name
}
 
rh_status_q() {
    rh_status >/dev/null 2>&1
}
 
 
case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        restart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart}"
        exit 2
esac
exit $?
EOF
) > /etc/init.d/redis-server

chmod +x /etc/init.d/redis-server
chkconfig --add redis-server
chkconfig redis-server on

## 消除redis启动时的三个警告
echo "net.core.somaxconn= 1024" >> /etc/sysctl.conf
echo "vm.overcommit_memory=1" >>  /etc/sysctl.conf
sysctl -p 

echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local

#启动
service redis-server start
echo "Please set passwd and restart"

