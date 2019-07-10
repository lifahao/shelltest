#!/bin/bash

# docker run -t -d --name smartio -p 10000:3306 -e MYSQL_ROOT_PASSWORD=1234 -v /mnt/data/mysql:/var/lib/mysql mysql:5.7

DBNAME=tpcc
WH=12000
HOST=127.0.0.1
PORT=10000
STEP=400

set -ex

cd tpcc-mysql

mysql -h $HOST --port $PORT -u root -p1234 -e '
	create database tpcc;
	use tpcc;
	source create_table.sql;
	source add_fkey_idx.sql;
'

./tpcc_load -P $PORT -h $HOST -d $DBNAME -uroot -p "1234" -w $WH -l 1 -m 1 -n $WH >> 1.out &

x=1

while [ $x -le $WH ]
do
 echo $x $(( $x + $STEP - 1 ))
./tpcc_load -P $PORT -h $HOST -d $DBNAME -u root -p "1234" -w $WH -l 2 -m $x -n $(( $x + $STEP - 1 ))  >> 2_$x.out &
./tpcc_load -P $PORT -h $HOST -d $DBNAME -u root -p "1234" -w $WH -l 3 -m $x -n $(( $x + $STEP - 1 ))  >> 3_$x.out &
./tpcc_load -P $PORT -h $HOST -d $DBNAME -u root -p "1234" -w $WH -l 4 -m $x -n $(( $x + $STEP - 1 ))  >> 4_$x.out &
 x=$(( $x + $STEP ))
done

wait

