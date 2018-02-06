FROM test.cn/library/centos-jdk8
MAINTAINER <song-liangliang@qq.com>
LABEL Description="tomcat8.5"

ENV CATALINA_BASE=/usr/local/tomcat \
    CATALINA_HOME=/usr/local/tomcat \
    CATALINA_TMPDIR=/usr/local/tomcat/temp \
    JRE_HOME=/usr \
    CLASSPATH=/usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar \
	PATH=$PATH:/usr/local/tomcat/bin

COPY ./apache-tomcat-8.5.27.tar.gz /tomcat.tar.gz
RUN mkdir -p /usr/local/tomcat && \
    tar -zxf "tomcat.tar.gz" -C /usr/local/tomcat --strip-components 1 && \
    rm -rf "tomcat.tar.gz"

WORKDIR $CATALINA_HOME
EXPOSE 8080
CMD ["catalina.sh", "run"]
