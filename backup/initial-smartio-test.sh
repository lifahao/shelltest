#!/bin/bash

set -ex

# 1. format
sfdisk /dev/nvme0n1 < ./memblaze-partitions.txt

sync
partprobe /dev/nvme0n1
sync

# wait for /dev/nvme0n1p1 available
sleep 3

mkfs.ext2 -F /dev/nvme0n1p1
mkfs.ext2 -F /dev/nvme0n1p2
mkfs.ext2 -F /dev/nvme0n1p3

# 2. mount
./mount.sh

rm -fr '/mnt/data1/lost+found'
rm -fr '/mnt/data2/lost+found'
rm -fr '/mnt/data3/lost+found'

./1-create-mysql.sh
docker start data1

sleep 10

(
cd tpcc-mysql
mysql -h 127.0.0.1 --port 10001 -u root -p1234 -e '
	create database tpcc1000;
	use tpcc1000;
	source create_table.sql;
	source add_fkey_idx.sql;
'
)

./load.sh

docker stop data1
cp -r /mnt/data1/. data/
