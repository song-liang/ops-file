# frps and frpc

FROM alpine:latest

RUN \
    echo "http://mirrors.aliyun.com/alpine/latest-stable/main" > /etc/apk/repositories && \
    echo "http://mirrors.aliyun.com/alpine/latest-stable/community" >> /etc/apk/repositories && \
    apk update upgrade && \
    apk add --no-cache procps curl bash tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

ADD ./frp /frp

ENV SERVICE=frps

# server port
EXPOSE 7000
# server dashboard
EXPOSE 7500
# client dashboard
EXPOSE 7400


WORKDIR /frp

ENTRYPOINT ["sh","-c","/frp/${SERVICE} -c /frp/${SERVICE}.ini"]
