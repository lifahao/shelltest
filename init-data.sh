#!/bin/bash

set -ex
#创建docker容器smartio
#-name 容器名字
#-p 端口映射 10000映射到3306
#-e 配置root登录密码
docker create --name smartio -p 10000:3306 -e MYSQL_ROOT_PASSWORD=1234 -v /mnt/data/mysql:/var/lib/mysql mysql:5.7
#启动smartio容器
docker start smartio

sleep 80

(
cd tpcc-mysql
#启动mysql，运行在docker容器smartio上
mysql -h 127.0.0.1 --port 10000 -uroot -p1234 -e '
        create database tpcc;
        use tpcc;
        source create_table.sql;
        source add_fkey_idx.sql;
'
)
echo "./load.sh start"
./load.sh

