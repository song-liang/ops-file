############################################################
# Dockerfile to build JDK1.8 container images
# docker build -t maven:3.6-jdk-8 .
############################################################

# Set the base image
FROM centos:7

# File Author / Maintainer
MAINTAINER songliangliang <songliangliang@istarfinancial.cn>

ENV TERM=xterm \
    PATH=$PATH:/usr/local/java/bin:/usr/local/java/jre/bin:/usr/local/maven/bin \
    JAVA_HOME=/usr/local/java \
    JAVA_BIN=/usr/local/java/bin \
    JRE_HOME=/usr/local/java/jre \
    CLASSPATH=/usr/local/java/lib:/usr/local/java/lib:/usr/local/java/jre/lib/charsets.jar \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    MAVEN_OPTS="-Xms512m -Xmx1024m"

ADD JDK8_202 /usr/local/java
ADD apache-maven-3.6.0 /usr/local/maven

