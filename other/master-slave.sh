#!/bin/bash
# master - slave  开启gtid后

if [ $# -eq 0 ];then
    echo "格式错误，请参考正确格式。"
    echo "正确格式: sh m-s.sh master-host slave-user slave-password"
    echo "Example: sh m-s.sh 192.168.0.10 repl repl"
    exit
fi

echo -e " Make sure you have exe \033[1;33m GRANT REPLICATION SLAVE ON *.* TO '$2'@'%' IDENTIFIED BY '$3'\033[0m on master"
echo -e "\033[1;31m Make sure the iptables is off \033[0m"
read -p "Input 'ok' to continue : " F
if [[ $F =~ 'ok' ]];then
    echo "Ready Go.."
else
    exit
fi

read -p "请输入mysql-master服务器上mysql的root密码: " P
read -p "请输入本地mysql的root密码: " SP

CMD="change master to master_host='$1', master_port=3306, master_user='$2', master_password='$3', master_auto_position=1"
echo $CMD

mysqldump -h$1 -uroot -p$P -A -B -R --single-transaction --master-data=1 > /root/recorver.sql
echo $?
mysql -h 127.0.0.1 -P 3306 -uroot -p$SP -e "stop slave"
echo $?
mysql -h 127.0.0.1 -P 3306 -uroot -p$SP -e "reset slave"
echo $?
mysql -h 127.0.0.1 -P 3306 -uroot -p$SP -e "$CMD"
echo $?
mysql -h 127.0.0.1 -P 3306 -uroot -p$SP -e "source /root/recorver.sql"
echo $?
mysql -h 127.0.0.1 -P 3306 -uroot -p$SP -e "start slave"
echo $?

sleep 5
mysql -h 127.0.0.1 -P 3306 -uroot -p$SP -e "show slave status\G" | egrep "Slave_IO_Running|Slave_SQL_Running"
