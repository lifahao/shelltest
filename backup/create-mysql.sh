#!/bin/bash

set -ex

partitions=$1

for i in $(seq 1 $partitions)
do
	mkdir -p /mnt/run$i
	docker create --name data$i -p $((10000 + i)):3306 -e MYSQL_ROOT_PASSWORD=1234 -v /mnt/data$i:/var/lib/mysql mysql:5.7
	docker start data$i
done
