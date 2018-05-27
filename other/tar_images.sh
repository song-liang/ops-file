#!/bin/bash

##打包没有/的镜像
docker images|grep -v '/'|awk '{print $3}'|grep -v IMAGE > 1.txt

for i in `cat 1.txt`
do 
	echo $i
	imag_name=`docker images|grep $i|awk '{print $1}'`
	tag=`docker images|grep $i|awk '{print $2}'`
	docker save -o $imag_name.$tag.tar $imag_name:$tag 
done
 
## 打包有/的镜像
docker images|grep '/'|awk '{print $3}'|grep -v IMAGE > 2.txt 

for a in `cat 2.txt`
do 
	echo $a
	imag_name=`docker images|grep $a|awk '{print $1}'`
	tag=`docker images|grep $a|awk '{print $2}'`
	tar_name=`echo $imag_name|sed s#\/#_#g`
	docker save -o $tar_name.$tag.tar $imag_name:$tag 
done

#
#for i in `ls .`;do echo $i;docker load --input $i;done