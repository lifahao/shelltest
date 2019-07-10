#!/bin/bash

set -ex

partitions=$1

for i in $(seq 1 $partitions)
do
	if mountpoint /mnt/data$i
	then
		umount /mnt/data$i
	fi
done
