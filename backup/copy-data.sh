#!/bin/bash

set -ex

partitions=$1

# copy data
cp -r data/. /mnt/data1/
chown -R 999:docker /mnt/data1
for i in $(seq 2 $partitions)
do
	cp -r /mnt/data1/. /mnt/data$i/
	chown -R 999:docker /mnt/data$i
done

