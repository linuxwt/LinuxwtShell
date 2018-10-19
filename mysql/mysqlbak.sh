#!/bin/bash

# 本脚本用于容器部署的mysql备份
CONTAINER_NAME="mysql_linuxwt"
DIR=`date +%Y%m%d`
BACKDIR="/data/bak/"
USER='username'
PASSWD='password'
DBNAME='dbname'
LOG="/data/bak/backup.log"
TIME1=`date +%Y%m%d_%R`
>$LOG

docker exec  ${CONTAINER_NAME} mysql -u$USER -p$PASSWD -e'use dbname;flush logs';
docker exec  ${CONTAINER_NAME} mysqldump  -u$USER -p$PASSWD  $DBNAME > $BACKDIR/mysql_dbname_${TIME1}.sql

if [ $? -eq  0 ];then
    TIME2=`date +%Y%m%d_%R`

    echo " ${TIME1} start to backup.   Mysql database backup Success at ${TIME2} " >> $LOG
else
    TIME2=`date +%Y%m%d_%R`
    echo " ${TIME1} start to backup.   Mysql database backup Fail.Please check it. time: ${TIME2} " >>$LOG
    exit 1;
fi

find $BACKDIR -type f -mtime +30 -exec rm -rf {} \;
