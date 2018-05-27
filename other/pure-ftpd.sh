#!/bin/bash
##
## pure-ftpd一键安装，centos6.8_x64下修改，其他版本未验证，
##
##Songliang 2016.7.24

##将要建立的ftp根目录，新建一个账户身份登录FTP，FTP登录用户名，密码，写入下面变量中
ftp_pwd=/data/ftp
user=FTP
username=ftpuser

##下载链接
pureftp=https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.42.tar.bz2

##检查过程是否有错误
check_ok () {
if [ $? != 0 ]
then
    	echo "Error, Check the error log."
    	exit 1
fi
}

yum install -y openssl-devel

##解压，编译安装
cd /usr/local/src
[ -f ${pureftp##*/} ] || wget $pureftp
tar jxvf ${pureftp##*/} && cd `echo ${pureftp##*/}|sed 's/.tar.bz2//g'`

check_ok

./configure \
--prefix=/usr/local/pureftpd \
--without-inetd \
--with-altlog \
--with-puredb \
--with-throttling \
--with-peruserlimits \
--with-tls

check_ok
make && make install 
check_ok

##复制配置文件
cd configuration-file 
mkdir -p /usr/local/pureftpd/etc/  
cp pure-ftpd.conf /usr/local/pureftpd/etc/pure-ftpd.conf 
cp pure-config.pl /usr/local/pureftpd/sbin/pure-config.pl 
chmod 755 /usr/local/pureftpd/sbin/pure-config.pl 

cat >> /usr/local/pureftpd/etc/pure-ftpd.conf  <<EOF
ChrootEveryone                yes        # 限制所有用户在其主目录中
BrokenClientsCompatibility    no         #兼容ie等比较非正规化的ftp客户端
MaxClientsNumber              50         # 服务器总共允许同时连接的最大用户数
Daemonize                     yes        #做为守护(doemon)进程运行(Fork in background)
MaxClientsPerIP               8          #同一IP允许同时连接的用户数（Maximum number of sim clients with the same IP address）
VerboseLog                    no         #如果你要记录所有的客户命令，设置这个指令为 "yes"
DisplayDotFiles               yes        #即使客户端没有发送 '-a' 选项也列出隐藏文件( dot-files 
AnonymousOnly                 no         #不允许认证用户 - 仅作为一个公共的匿名FTP
NoAnonymous                   yes         #不允许匿名连接，仅允许认证用户使用
SyslogFacility                ftp        #缺省的功能( facility 是 "ftp"。 "none" 将禁止日志
DontResolve                   yes        #在日志文件中不解析主机名。日志没那么详细的话，就使用更少的带宽。在一个访问量很大的站点中，设置这个指令为 "yes" ，如果你没有一个能工作的DNS的话
MaxIdleTime                   15         #客户端允许的最大的空闲时间（分钟，缺省15分钟）
PureDB                        /usr/local/pureftpd/etc/pureftpd.pdb          #PureDB 用户数据库
LimitRecursion                3136 8     #'ls' 命令的递归限制。第一个参数给出文件显示的最大数目。第二个参数给出最大的子目录深度
AnonymousCanCreateDirs        no         #允许匿名用户创建新目录？
MaxLoad                       4          #如果系统被 loaded 超过下面的值，匿名用户会被禁止下载
AntiWarez                     yes        #不接受所有者为 "ftp" 的文件的下载。例如：那些匿名用户上传后未被本地管理员验证的文件
Umask                         133:022    #新建目录及文件的属性掩码值
MinUID                        100        #认证用户允许登陆的最小组ID（UID）
AllowUserFXP                  no         #仅允许认证用户进行 FXP 传输
AllowAnonymousFXP             no         #对匿名用户和非匿名用户允许进行匿名 FXP 传输
ProhibitDotFilesWrite         no         #用户不能删除和写点文件（文件名以 '.' 开头的文件），即使用户是文件的所有者也不行
ProhibitDotFilesRead          no         #禁止读点文件（文件名以 '.' 开头的文件） (.history, .ssh...) 
AutoRename                    no
AnonymousCantUpload           no         #不接受匿名用户上传新文件( no = 允许上传)
PIDFile                       /usr/local/pureftpd/var/run/pure-ftpd.pid
MaxDiskUsage                  99         #当 /var/ftp 在 /var 里时，需要保留一定磁盘空间来保护日志文件。当所在磁盘分区使用超过百分之 X 时，将不在接受新的上传。 
CustomerProof                 yes
EOF

echo "##############Installation is complete#####################"
echo -e "To create a FTP account.\nPlease input FTP root directory,For example:/data/ftproot/ftpuser"

##创建ftp服务的根目录
read -p "Please input FTP root directory(/data/ftp):" ftp_pwd
mkdir -p $ftp_pwd
                        			
##创建以系统账号登录ftp的身份
read -p "need create a system user for login FTP:" user
useradd $user                            			

cd ${ftp_pwd%/*}
chown -R $user:$user ${ftp_pwd##*/}

##建立虚拟账号，即FTP帐号
read -p "Please input a ftpusername:" username
echo "Please set yourftp password:"
/usr/local/pureftpd/bin/pure-pw useradd $username  -u$user -d $ftp_pwd  

##创建密码数据文件
/usr/local/pureftpd/bin/pure-pw mkdb

##列出用户及目录
echo "FTP usernme and root directory"
/usr/local/pureftpd/bin/pure-pw list
sleep 2
# /usr/local/pureftpd/bin/pure-pw userdel test1    	##删除账号

##加载ftp模块
cat >> /etc/sysconfig/iptables-config <<EOF
IPTABLES_MODULES="ip_conntrack_ftp"
IPTABLES_MODULES="ip_nat_ftp"
EOF
service iptables restart
##添加iptabes规则
iptables -I INPUT -p tcp --dport 21 -j ACCEPT
iptables -I OUTPUT -p tcp --dport 21 -j ACCEPT
service iptables save

##启动pure-ftpd服务的命令
/usr/local/pureftpd/sbin/pure-config.pl /usr/local/pureftpd/etc/pure-ftpd.conf
