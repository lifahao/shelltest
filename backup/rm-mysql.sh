#!/bin/bash

set -ex

partitions=$1

for i in $(seq 1 $partitions)
do
	docker stop data$i || true
	docker rm data$i || true
done
