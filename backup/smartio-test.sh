#!/bin/bash

set -ex


sectors=$(fdisk -l /dev/nvme0n1 | head -n 1 | grep -oP '\b(\d+)(?=\s+sectors)')
partitions=$(((sectors - 256) / 130023424))

./partitions.sh $partitions

./mount.sh $partitions

./copy-data.sh $partitions

./create-mysql.sh $partitions

# waiting for mysql fully available
sleep 15

./build-tpcc-mysql.sh

./tpcc-start.sh $partitions

./rm-mysql.sh $partitions

./umount.sh $partitions

