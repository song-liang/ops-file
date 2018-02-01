############################################################
# Dockerfile to build JDK1.8 container images
#
############################################################

# Set the base image
FROM centos

# File Author / Maintainer
MAINTAINER songliangliang <songliangliang@istarfinancial.cn>

ADD jdk-8u144-linux-x64.rpm jdk-8u144-linux-x64.rpm \
	/etc/localtime /etc/localtime \
	/etc/timezone /etc/timezone
RUN rpm -vih jdk-8u144-linux-x64.rpm \
	rm -rf jdk-8u144-linux-x64.rpm

