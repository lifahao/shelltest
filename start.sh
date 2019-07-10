#!/bin/bash

set -xe
#./tpcc_start -h server_host -P port -d database_name -u mysql_user -p mysql_password -w warehouse 
#-c connections -r warmup_time -I running_time -i report-interval -f report-file -l test-time
cd tpcc-mysql
#test-time is 10 days
time ./tpcc_start -h127.0.0.1 -P10000 -dtpcc -uroot -p1234 -w12000 -c32 -r10 -l$((60*60*24*10))

