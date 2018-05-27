FROM java
MAINTAINER <1107179995@qq.com>
LABEL Description="使用mycat做mysql数据库的读写分离"

ENV MYCAT_HOME=/mycat \
	PATH=$PATH:/mycat/bin
USER root
COPY ./mycat /mycat

WORKDIR $MYCAT_HOME/bin
EXPOSE 8066 9066
CMD ["mycat","console"]
