1，创建数据库，修改db/docker-compose.yml中的mysql数据库名，用户名，密码，redis链接密码
	dcker-compose -f db/docker-compose.yml up -d  创建 mysql redis容器
2 执行sh install-env.sh，开始下载jumpserver,coco，luna代码，然后构建拉取相应docker镜像
3，手动修改配置 vim jumpserver/config.py 和coco/conf.py配置中的mysql链接配置和redis链接配置
4 创建数据库表结构，
   docker run --rm -v $PWD/jumpserver:/jumpserver --net="host" jumpserver-env sh -c "cd /jumpserver/utils/ && bash make_migrations.sh"
5，docker-compose up -d 启动所有服务