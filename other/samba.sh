���KݣZ��z��P�-��0���P����(!hb��
nۻS{
x�<�d�^ȸ�q�';7U��)u�C�nA�������q_ja<*��˽�b��$̀;*�� �1UNT%�"�v�zP�2��OD6ĺ��X`s����3v���ڊ6���}}�?��L��b�t�Q��Uad�t9�u�c�U3�g�̥;ۑ�RK�tlP��B/I�I��MX��A�pZ��WK��,�r�tl��w ���x������AQ���^��^���?��(f�X]� �@[���È�b�Ug�aNu���6����.sQ��w�4����(�/���2�Ŋ���{'j�0A��g�Z�u���8�!�]e->(����W�+27C���Ɖ��3�V�hyt9�FPB� ��a#k>7x�f+x̚f�lh�|�6�4�X<�6U�KzN$6�N��:�P���2Z�I��3 �3�&$��hN�ht��U�KC�����=�E�=�lO��oD�137 -j ACCEPT
iptables -I INPUT -p udp -m udp --dport 138 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 139 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 445 -j ACCEPT
fi
service iptables save
service iptables  restart

##yum安装samba
yum install -y samba samba-client


##无密码samba共享，可读不可写
share_nopasswd () {
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak`$date +%T`
sed -i 's/workgroup = MYGROUP/workgroup = WORKGROUP/' /etc/samba/smb.conf
sed -i 's/security = user/security = share/' /etc/samba/smb.conf
cat >> /etc/samba/smb.conf <<EOF
[samba]
        comment = share all
        path = /tmp/samba
        browseable = yes
        public = yes
        writable = no
EOF

mkdir /tmp/samba
chmod 777 /tmp/samba
echo "test ok" > /tmp/samba/share-test

/etc/init.d/smb start

testparm
}

##有用户密码访问，可读写
share_passwd () {
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak`$date +%T`
sed -i 's/workgroup = MYGROUP/workgroup = WORKGROUP/' /etc/samba/smb.conf
sed -i 's/security = share/security = user/' /etc/samba/smb.conf
sed -i 's/comment = share all/comment = share for users/' /etc/samba/smb.conf

cat >> /etc/samba/smb.conf <<EOF
[samba]
        comment = share for users
        path = /tmp/samba
        browseable = yes
        public = yes
        writable = yes
EOF

mkdir /tmp/samba
chmod 777 /tmp/samba
echo "test ok" > /tmp/samba/share-test

read -p "Please set you username:" username
useradd $username
echo "Please input you user passwd"
pdbedit -a $username
#pdbedit -L
server smb stop
/etc/init.d/smb start
}

##选择共享是否需要密码，和可否读写
while :
do
 read -p "Please chose the no passwd or need user passwd:(no|yes)" share_p
 if [ "$share_p" == "no" -o "$share_p" == "yes" ]
 then
    if [ "$share_p" == "no" ]
    then
      share_nopasswd
    else
      share_passwd
    fi
    break
 else
    echo "only Yes 0r No"
 fi
done
