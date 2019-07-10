#!/bin/bash

set -ex

# wait for "mstat fe" command
yes=
while [ "$yes" != "yes" ]
do
	read -p "Enter yes to start tpcc test: " yes
done


cd tpcc-mysql/

partitions=$1

# (
# 	cd blktrace
# 	exec blktrace -d /dev/nvme0n1 -a write -b 4096 -w $((60 * 60 * 8 + 60))
# ) &

# blktrace_pid=$!


{
	for i in $(seq 1 $partitions)
	do
		echo $((10000 + i))
	done
} | xargs -I{} -n1 -P0 --verbose ./tpcc_start -h127.0.0.1 -P{} -dtpcc1000 -uroot -p1234 -w4000 -c4 -r5 -l$((60 * 60 * 24))

# kill $blktrace_pid || true
wait

