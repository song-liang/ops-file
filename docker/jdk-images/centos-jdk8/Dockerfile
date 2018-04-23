############################################################
# Dockerfile to build JDK1.8 container images
#
############################################################

# Set the base image
FROM centos

# File Author / Maintainer
MAINTAINER songliangliang <songliangliang@istarfinancial.cn>

ENV JAVA_HOME=/usr/local/java \
    JAVA_BIN=/usr/local/java/bin \
    JRE_HOME=/usr/local/java/jre \
    PATH=$PATH:/usr/local/java/bin:/usr/local/java/jre/bin \
    CLASSPATH=/usr/local/java/lib:/usr/local/java/lib:/usr/local/java/jre/lib/charsets.jar \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

ADD jdk1.8.0_144 /usr/local/java


