# 使用本地挂载作为存储时，初始启动需要复制容器中的初始数据到本地目录
docker run --rm -v $PWD:/tmp percona/pmm-server:1 cp -ra /var/lib/mysql /tmp
docker run --rm -v $PWD:/tmp percona/pmm-server:1 cp -ra /var/lib/grafana /tmp 
#docker run --rm -v $PWD:/tmp percona/pmm-server:1 cp -ra /srv/nginx /tmp
