#!/bin/bash

DBNAME=tpcc
WH=12000
HOST=127.0.0.1
PORT=10000
STEP=400

set -ex

cd tpcc-mysql
# ./tpcc_load [server] [DB] [user] [pass] [warehouse]
# ./tpcc_load -dtpcc1000 -utpcc -p1234 -w1000
#Usage: tpcc_load -h server_host -P port -d database_name -u mysql_user -p mysql_password -w warehouses -l part -m min_wh -n max_wh
# ./tpcc_load -P 10000 -h 127.0.0.1 -d tpcc -uroot -p "1234" -w 12000 -l 1 -m 1 -n 12000 > 1.out &
#1.out是log文件
./tpcc_load -P $PORT -h $HOST -d $DBNAME -uroot -p "1234" -w $WH -l 1 -m 1 -n $WH 

x=1
#开始制造数据，数据仓库数量为12000
:<<!
while [ $x -le $WH ]
do
 echo $x $(( $x + $STEP - 1 ))
./tpcc_load -P $PORT -h $HOST -d $DBNAME -u root -p "1234" -w $WH -l 2 -m $x -n $(( $x + $STEP - 1 ))  > 2_$x.out &
./tpcc_load -P $PORT -h $HOST -d $DBNAME -u root -p "1234" -w $WH -l 3 -m $x -n $(( $x + $STEP - 1 ))  > 3_$x.out &
./tpcc_load -P $PORT -h $HOST -d $DBNAME -u root -p "1234" -w $WH -l 4 -m $x -n $(( $x + $STEP - 1 ))  > 4_$x.out &
 x=$(( $x + $STEP ))
done
!
#等待所有仓库建造成功
#提示：DATA LOADING COMPLETED SUCCESSFULLY.
wait

