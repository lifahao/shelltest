#!/bin/bash

sudo apt-get install -y make gcc libmysqlclient-dev mysql-client

cd tpcc-mysql/src
make clean
make
