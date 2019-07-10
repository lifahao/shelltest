#!/bin/bash
set -ex

export PATH="fio:$PATH"
which fio

dev=$1
runtime=600

percentlist="1:5:10:20:30:40:50:60:70:80:90:95:99:99.5:99.9:99.99:99.999:99.9999:99.99999"
log_avg_msec=1000
ramp_time=60

# ##performance test
# ##write 2X disk
fio --direct=1 --thread=1 --ioengine=libaio --name=test --scramble_buffers=1 --userspace_reap --numjobs=1 --iodepth=64 --group_reporting --norandommap --randrepeat=0 --filename=$dev --runtime=3600 --percentile_list=$percentlist --blocksize=128k --rw=write --output=FOB_result/128k_write_tp1
fio --direct=1 --thread=1 --ioengine=libaio --name=test --scramble_buffers=1 --userspace_reap --numjobs=1 --iodepth=64 --group_reporting --norandommap --randrepeat=0 --filename=$dev --runtime=3600 --percentile_list=$percentlist --blocksize=128k --rw=write --output=FOB_result/128k_write_tp2

fio --direct=1 --thread=1 --ioengine=libaio --name=test --scramble_buffers=1 --userspace_reap --numjobs=1 --iodepth=128 --group_reporting --norandommap --randrepeat=0 --filename=$dev --runtime=$runtime --time_based --percentile_list=$percentlist --blocksize=128k --rw=write --ramp_time=$ramp_time --write_bw_log=FOB_result/128kw --write_lat_log=FOB_result/128kw --write_iops_log=FOB_result/128kw --log_avg_msec=$log_avg_msec --output=FOB_result/128k_write_tp

#fio --direct=1 --thread=1 --ioengine=libaio --name=test --scramble_buffers=1 --userspace_reap --numjobs=1 --iodepth=128 --group_reporting --norandommap --randrepeat=0 --filename=$dev --runtime=$runtime --time_based --percentile_list=$percentlist --blocksize=128k --rw=read --ramp_time=$ramp_time --write_bw_log=FOB_result/128kr --write_lat_log=FOB_result/128kr --write_iops_log=FOB_result/128kr --log_avg_msec=$log_avg_msec --output=FOB_result/128k_read_tp

fio --direct=1 --thread=1 --ioengine=libaio --name=test --scramble_buffers=1 --userspace_reap --numjobs=4 --iodepth=64 --group_reporting --norandommap --randrepeat=0 --filename=$dev --runtime=$runtime --time_based --percentile_list=$percentlist --blocksize=8k --rw=randwrite --ramp_time=$ramp_time --write_bw_log=FOB_result/8kfw --write_lat_log=FOB_result/8kfw --write_iops_log=FOB_result/8kfw --log_avg_msec=$log_avg_msec --output=FOB_result/8k_write_iops-FOB

fio --direct=1 --thread=1 --ioengine=libaio --name=test --scramble_buffers=1 --userspace_reap --numjobs=4 --iodepth=64 --group_reporting --norandommap --randrepeat=0 --filename=$dev --runtime=$runtime --time_based --percentile_list=$percentlist --blocksize=4k --rw=randwrite --ramp_time=$ramp_time --write_bw_log=FOB_result/4kfw --write_lat_log=FOB_result/4kfw --write_iops_log=FOB_result/4kfw --log_avg_msec=$log_avg_msec --output=FOB_result/4k_write_iops-FOB
