#！/bin/bash
##
##vsftp 的一键配置脚本,环境centos6.7_x64
##
##sonliang
##

##用户名，密码，ftp路径 ,路径为web更目录时，需要注意改脚本中57行的权限
read -p "Please input a ftp username:" username
read -p "Please input a ftp user passwd:" passwd
read -p "Please input a ftp root dir:" ftproot
#username=ftpuser
#passwd=123456
ftp_pwd=/home/virftp/$ftproot

##关闭seliux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
selinux_s=`getenforce`
if [ $selinux_s == "Enforcing" ]
then
    setenforce 0
fi

##安装vsftpd
yum install -y vsftpd db4-utils

##创建虚拟用户
useradd virftp -s /sbin/nologin

##创建登录文件
touch /etc/vsftpd/vsftpd_login
echo $username > /etc/vsftpd/vsftpd_login
echo $passwd >> /etc/vsftpd/vsftpd_login

##更改权限
chmod 600 /etc/vsftpd/vsftpd_login

##生成登录库文件
db_load -T -t hash -f /etc/vsftpd/vsftpd_login /etc/vsftpd/vsftpd_login.db

##建立配置文件
mkdir  /etc/vsftpd/vsftpd_user_conf
cd   /etc/vsftpd/vsftpd_user_conf 
touch ftpuser
cat >>  ftpuser <<EOF
local_root=$ftp_pwd
anonymous_enable=NO
write_enable=YES
local_umask=022
anon_upload_enable=NO
anon_mkdir_write_enable=NO
idle_session_timeout=600
data_connection_timeout=120
max_clients=10
max_per_ip=5
local_max_rate=50000
EOF

[ -f $ftp_pwd ] || mkdir $ftp_pwd
chown -R virftp:virftp ${ftp_pwd%/*}

##修改/etc/pam.d/vsftpd，添加参数_  x64下
sed -i '1i\auth sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/vsftpd_login' /etc/pam.d/vsftpd
sed -i '2i\account sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/vsftpd_login' /etc/pam.d/vsftpd

sed -i 's/anonymous_enable=YES/anonymous_enable=NO/' /etc/vsftpd/vsftpd.conf					##禁止匿名访问
sed -i 's/#anon_upload_enable=YES/anon_upload_enable=NO/' /etc/vsftpd/vsftpd.conf				##禁止匿名上传文件
sed -i 's/#anon_mkdir_write_enable=YES/anon_mkdir_write_enable=NO/' /etc/vsftpd/vsftpd.conf		##禁止匿名创建文件

cat >> /etc/vsftpd/vsftpd.conf <<EOF
chroot_local_user=YES
guest_enable=YES
guest_username=virftp
virtual_use_local_privs=YES
user_config_dir=/etc/vsftpd/vsftpd_user_conf
#pasv_min_port=30001
#pasv_max_port=31000		##设置被动数据传输端口的一个范围
EOF

##加载ftp模块
cat >> /etc/sysconfig/iptables-config <<EOF
IPTABLES_MODULES="ip_conntrack_ftp"
IPTABLES_MODULES="ip_nat_ftp"
EOF
service iptables restart

##添加iptabes规则
iptables-save > /etc/sysconfig/iptables_`date +%T`
cat /etc/sysconfig/iptables |grep 21|grep ACCEPT
if [ $? != 0 ]
then
iptables -I INPUT -p tcp --dport 21 -j ACCEPT
iptables -I OUTPUT -p tcp --dport 21 -j ACCEPT
if
service iptables save

##启动
chkconfig vsftpd on
/etc/init.d/vsftpd start