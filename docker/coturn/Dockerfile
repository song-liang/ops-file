###  build for centos7 
# docker build -t coturn .
FROM centos:7

LABEL maintainer="liang"

ENV TINI_VERSION=v0.19.0 \
    COTURN_VERSION=4.5.1.2 \
    BUILD_PREFIX=/usr/local/src \
    COTURN_HOME=/usr/local/coturn
ENV PATH=$PATH:${COTURN_HOME}/bin


# Install build dependencies
RUN rm -rf /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    echo 'Asia/Shanghai' > /etc/timezone && \
    yum install -y epel-release && \
    yum install -y make gcc gcc-c++ openssl-devel \
    libevent libevent-devel \
    libsqlite3x-devel \
    mysql-devel \
    hiredis-devel \
    postgresql-devel \
    mongo-c-driver-devel libbson && \
    yum clean all

# add simplest init    
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini
# add coturn
ADD https://github.com/coturn/coturn/archive/${COTURN_VERSION}.tar.gz ${BUILD_PREFIX}/

# build
RUN cd ${BUILD_PREFIX}/ && \
    tar zxvf ${COTURN_VERSION}.tar.gz && \
    cd coturn-${COTURN_VERSION} && \
    ./configure --prefix=${COTURN_HOME} && \
    make && make install && \
    cp ${COTURN_HOME}/etc/turnserver.conf.default ${COTURN_HOME}/etc/turnserver.conf && \
    cp -r examples ${COTURN_HOME} && \
    cp examples/etc/turn_server*.pem ${COTURN_HOME}/etc/ && \
    rm -rf ../*


# SUTN/TURN PORTS
EXPOSE 3478 3478/udp
EXPOSE 5349 5349/udp
# WEB-ADMIN
#EXPOSE 8080 8080/udp
# CLI
EXPOSE 5766
# Relay Ports
#EXPOSE 49152-65535 49152-65535/udp


WORKDIR ${COTURN_HOME}
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/coturn/bin/turnserver","-c","/usr/local/coturn/etc/turnserver.conf"]
