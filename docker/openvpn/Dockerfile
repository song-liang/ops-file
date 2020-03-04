# 根据pritunl官方yum源安装 VPN
FROM centos:7

MAINTAINER song-liang <song-liangliang@qq.com>

# 添加yum源
RUN  \
    curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo && \
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
    # 添加pritunl repo
    echo "[pritunl]" > /etc/yum.repos.d/pritunl.repo && \
    echo "name=Pritunl Repository" >> /etc/yum.repos.d/pritunl.repo && \
    echo "baseurl=https://repo.pritunl.com/stable/yum/centos/7/" >> /etc/yum.repos.d/pritunl.repo && \
    echo "gpgcheck=1" >> /etc/yum.repos.d/pritunl.repo && \
    echo "enabled=1" >> /etc/yum.repos.d/pritunl.repo && \
    gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A && \
    gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A > key.tmp; rpm --import key.tmp; rm -f key.tmp && \
    # 时区
    rm -rf /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone

RUN yum makecache && yum install -y deltarpm pritunl && yum clean all


EXPOSE 80
EXPOSE 443
EXPOSE 1194
EXPOSE 1194/udp

ENTRYPOINT ["/usr/lib/pritunl/bin/pritunl","start"]

#CMD ["/usr/bin/tail", "-f","/var/log/pritunl.log"]

