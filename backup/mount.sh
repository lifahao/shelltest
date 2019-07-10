#!/bin/bash

set -ex

partitions=$1

for i in $(seq 1 $partitions)
do
	mkdir -p /mnt/data$i
	if ! mountpoint /mnt/data$i
	then
		mount /dev/nvme0n1p$i /mnt/data$i
	fi
done
