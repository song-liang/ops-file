#!/bin/bash

# 创建grafana 本地目录，修改权限,容器中grafana 用户权ID为472
mkdir -p  grafana/data  grafana/log
chown -R 472:472  grafana/data  grafana/log

# 创建 prometheus 本地数据目录 修改权限，容器中prometheus 用户ID为65534
mkdir -p prometheus/data
chown -R 65534:65534 prometheus/data