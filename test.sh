#!/bin/bash
set -ex
:<<!
#fio对ssd进行预热，gc到达稳态
echo "开始fio"
#./pre-write-with-stress.sh

#确保输入参数，无参数提示输入规则

#确保/mtn/ssd目录存在
#$1为容器的目录，比如docker0,$2为容器端口，映射到数据库,$3为创建的数据仓库数量
if [ ! -d "/mnt/ssd/$1" ];then 
    if [ ! -d "/mnt/ssd" ];then
        sudo mkdir /mnt/ssd
    fi
    sudo mkdir /mnt/ssd/$1
fi

if  mountpoint /mnt/ssd/$1 ;then
    echo "ssd 挂载到 /mnt/ssd/$1"
    sudo umount /mnt/ssd/$1
	sudo umount /dev/nvme0n1p1
    echo "umount成功"
fi

#格式化磁盘
echo "开始格式化磁盘"
sudo nvme format /dev/nvme0n1
echo "格式化成功"
sleep 10

#对ssd进行分区,输入o,n,w
sudo fdisk /dev/nvme0n1

#对ssd创建文件系统
echo "开始创建文件系统"
mkfs.ext4 -E nodiscard /dev/nvme0n1p1

#挂载
sudo mount /dev/nvme0n1p1 /mnt/ssd/$1
echo "挂载成功！"
#确保安装docker容器
echo "开始创建容器"
!
sudo docker create --name $1 -p $2:3306 -e MYSQL_ROOT_PASSWORD=1234 -v /mnt/ssd/$1:/var/lib/mysql mysql:5.7

#启动容器
echo "启动容器"
sudo docker start $1
#等待容器创建完成
sleep 10
#确保是在安装路径下，如果不在则切换到
cd tpcc-mysql

#连接mysql，运行在docker容器smartio上
#例如mysql_docker0

(
#启动mysql，运行在docker容器smartio上
mysql -h 127.0.0.1 --port $2 -uroot -p1234 -e '
        create database tpcc;
        use tpcc;
        source create_table.sql;
        source add_fkey_idx.sql;
'
)
#确保在tpcc_load程序目录。
#生成多个数据仓库
#./tpcc_load -P $2 -h 127.0.0.1 -d $1 -uroot -p "1234" -w $3 -m 1 -n 10
#多线程运行tpcc_load
DBNAME=tpcc
WH=$3
HOST=127.0.0.1
PORT=$2
STEP=$3/10

# ./tpcc_load [server] [DB] [user] [pass] [warehouse]
sudo mkdir log
time ./tpcc_load -P $PORT -h $HOST -d $DBNAME -uroot -p "1234" -w $WH -l 1 -m 1 -n $WH >> log/1.out &

x=1
#开始制造数据，数据仓库数量为12000
while [ $x -le $WH ]
do
 echo $x $(( $x + $STEP - 1 ))
 #多线程运行：($x + $STEP - 1)=STEP，数据仓库数量，WH/STEP代表启动的线程数量
time ./tpcc_load -P $PORT -h $HOST -d $DBNAME -u root -p "1234" -w $WH -l 2 -m $x -n $(( $x + $STEP - 1 ))  >> log/2_$x.out &
time ./tpcc_load -P $PORT -h $HOST -d $DBNAME -u root -p "1234" -w $WH -l 3 -m $x -n $(( $x + $STEP - 1 ))  >> log/3_$x.out &
time ./tpcc_load -P $PORT -h $HOST -d $DBNAME -u root -p "1234" -w $WH -l 4 -m $x -n $(( $x + $STEP - 1 ))  >> log/4_$x.out &
 x=$(( $x + $STEP ))
done
#等待所有仓库建造成功
#提示：DATA LOADING COMPLETED SUCCESSFULLY.
wait
#运行tpcc
time ./tpcc_start -h127.0.0.1 -P10000 -dtpcc -uroot -p1234 -w12000 -c32 -r10 -l$((60*60*24*10))|tee log/tpcc_start.log
