FROM centos-jdk8
MAINTAINER <1107179995@qq.com>
LABEL Description="tomcat8.5"

## 伪终端，tomcat变量，字符变量
ENV TERM=xterm \
    CATALINA_BASE=/usr/local/tomcat \
    CATALINA_HOME=/usr/local/tomcat \
    CATALINA_TMPDIR=/usr/local/tomcat/temp \
    CLASSPATH=/usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar \
    PATH=$PATH:/usr/local/tomcat/bin \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

## 添加tomcat
ADD ./apache-tomcat-8.5.27 /usr/local/tomcat

##添加日志切割
RUN yum install -y logrotate \
    echo "0 1 * * * /usr/sbin/logrotate --force /etc/logrotate.d/tomcat" >> /var/spool/cron/root
ADD ./conf/tomcat /etc/logrotate.d/


WORKDIR $CATALINA_HOME
EXPOSE 8080
#CMD ["catalina.sh","run"]
##修改catalina.sh,日志输出到本地
CMD ["startup.sh"]

