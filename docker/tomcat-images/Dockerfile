FROM centos-jdk8
MAINTAINER <song-liangliang@qq.com>
LABEL Description="tomcat8.5"

ENV CATALINA_BASE=/usr/local/tomcat \
    CATALINA_HOME=/usr/local/tomcat \
    CATALINA_TMPDIR=/usr/local/tomcat/temp \
    CLASSPATH=/usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar \
	PATH=$PATH:/usr/local/tomcat/bin \
	LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

COPY ./apache-tomcat-8.5.27 /usr/local/tomcat

WORKDIR $CATALINA_HOME
EXPOSE 8080
CMD ["catalina.sh", "run"]
