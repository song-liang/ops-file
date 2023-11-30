# ops-file
## 日常运维中为了方便快速部署与服务测试，将所有编排文件收集在一起方面查找

## 目录
```text
├── docker  docker-compose启动配置
│      ├── apollo                   # 携程apollo 配置中心compose文件
│      ├── coturn                   # webRTC 内网穿透服务
│      ├── drone                    # 轻量级云原生CI/CD
│      ├── etcdkeeper               # etcd webUI
│      ├── frp                      # frp Dockerfile and compose yaml
│      ├── elk                      # ELK官方镜像docker-compose
│      ├── gerrit                   # git代码审查
│      ├── gitlab                   # gitlab 仓库官方镜像docker-compose
│      ├── gogs                     # 官方镜像docker-compose
│      ├── jdk-images               # java jdk镜像构建
│      ├── jenkins                  # jenkins
│      ├── kafka                    # kafka kraft模式集群，kraft模式单节点，zookeeper模式
│         ├── kafka-ui              # kafka ui管理界面
|         └── zookeeper             # zookeeper 集群
│      ├── keycloak                 # 单点登录认证
│      ├── kong                     # kong 官方镜像 + 第三方 UI docker-compose
│      ├── ldap                     # ldap统一账号管理
│      ├── loki                     # grafana 轻量级日志采集分析
│      ├── minio                    # minio对象存储
│      ├── mongodb                  # mongo mongo-express 官方镜像docker-compose
│      ├── mycat-images             # mycat 镜像构建
│      ├── mysql_master             # mysql 主从docker-compose
│      ├── mysql_slave              # mysql 主从docker-compose
│      ├── nginx-php                # nginx php-fpm 官方镜像构建docker-compose
│      ├── nexus                    # 私有仓库，代理缓存仓库
│      ├── pmm                      # pmm 数据库监控，官方镜像 docker-compose
│      ├── powerdns                 # 带web管理的DNS服务器 
│      ├── portainer                # docker 管理UI服务
│      ├── prometheus               # prometheus + grafana 官方镜像docker-compose
|         └── doraemon              # 360 prometheus告警系统，官方镜像docker-compose
│      ├── rabbitmq                 # rabbitmq 官方镜像开启UI docker-compose
│      ├── redis                    # redis 官方镜像docker-compose.包含哨兵，和集群
│      ├── seafile                  # 文件共享私有网盘
│      ├── skywalking               # skywalking hub.docker 镜像+ es docker-compose
│      ├── svn-server               # svn 镜像构建
│      ├── tomcat-images            # tomcat 镜像构建
│      ├── wordpress                # WordPress 博客建站
│      └── zabbix-docker            # zabbix 利用官方镜像docker-compose
├── k8s	    kubernetes 下的服务yaml配置文件,ingress 使用的kongingress
│      ├── ELK
│      ├── grafana
│      ├── jenkins
│      ├── kong-ingress
│      ├── skywalking
│      ├── traefix
│      ├── zipkin
├── lanmp
│      ├── apache.sh                # httpd 编译安装脚本
│      ├── lanmp1.1.sh              # lanmp 一键编译安装脚本
│      ├── mysql-二进制.sh          # mysql 二进制安装脚本
│      ├── nginx.sh                 # nginx 编译安装脚本
│      └── php-phpfpm.sh            # php编 译安装脚本
├── other                           # 其他的一些脚本
├── tomcat
├── tshark
├── windows

```
