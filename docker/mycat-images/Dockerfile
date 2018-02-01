FROM java
MAINTAINER <1107179995@qq.com>
LABEL Description="使用mycat做mysql数据库的读写分离"

ENV MYCAT_HOME=/mycat \
	PATH=$PATH:/mycat/bin
USER root
COPY ./Mycat-server-1.6.5-release-20180122220033-linux.tar.gz /Mycat-server.tar.gz
RUN tar -zxf "Mycat-server.tar.gz" && \
	rm -rf "Mycat-server.tar.gz"
	
WORKDIR $MYCAT_HOME/bin
EXPOSE 8066 9066
CMD ["mycat","console"]
