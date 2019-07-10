#!/bin/bash
set -ex


sudo docker create --name test0 -p 10001:3306 -e MYSQL_ROOT_PASSWORD=1234 -v /mnt/data/mysql:/var/lib/mysql mysql:5.7

sudo docker start test0
cd tpcc-mysql
#启动mysql，运行在docker容器smartio上
mysql -h 127.0.0.1 --port 10000 -uroot -p1234 -e '
        create database tpcc_test0;
        use tpcc_test0;
        source create_table.sql;
        source add_fkey_idx.sql;
'

./tpcc_load -P 10001 -h 127.0.0.1 -d tpcc_test0 -uroot -p "1234" -w 10 -l 10 -m 1 -n 10

./tpcc_start -h127.0.0.1 -P10001 -dtpcc_test0 -uroot -p1234 -w10 
