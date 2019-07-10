#!/bin/bash

set -ex

partitions=$1

{

	echo "
	label: gpt
	device: /dev/nvme0n1
	unit: sectors
	first-lba: 256
	"

	for i in $(seq 1 $partitions)
	do
		echo "/dev/nvme0n1p$i : size=130023424"
	done
} | sfdisk /dev/nvme0n1

sync
partprobe /dev/nvme0n1
sync

# wait for /dev/nvme0n1p1 available
sleep 3

# there're some issues with TRIM support on haishen disk
# I don't want it to ease the GC with TRIM either
for i in $(seq 1 $partitions)
do
	mkfs.ext2 -E nodiscard -F /dev/nvme0n1p$i
done

