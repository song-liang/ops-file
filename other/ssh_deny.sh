#! /bin/bash
#排查log的失败记录，预设一定次数就扔进host.deny里~
#代码:想修改失败次数可以直接修改下面的define=20的那个数字

cat /var/log/secure|awk '/Failed/{print $(NF-3)}'|sort|uniq -c|awk '{print $2"="$1;}' > /dev/black.txt
DEFINE="5"
for i in `cat /dev/black.txt`
do
        IP=`echo $i |awk -F= '{print $1}'`
        NUM=`echo $i|awk -F= '{print $2}'`
        if [ $NUM -gt $DEFINE ];
        then
                grep $IP /etc/hosts.deny > /dev/null
                if [ $? -gt 0 ];
                then
                        echo "sshd:$IP" >> /etc/hosts.deny
                fi
        fi
done