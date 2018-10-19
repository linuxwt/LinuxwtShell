#!/bin/bash

# 本脚本用于容器部署的mysql备份
CONTAINER_NAME="mysql_bgi"
DIR=`date +%Y%m%d`
BACKDIR="/data/bak/"
USER='bgi'
PASSWD='Bgi@gooalgene333'
DBNAME='bgi'
LOG="/data/bak/backup.log"
TIME1=`date +%Y%m%d_%R`
#MONGODIR="/data/gooal/mongo/mongo"
>$LOG

docker exec  ${CONTAINER_NAME} mysql -u$USER -p$PASSWD -e'use bgi;flush logs';
docker exec  ${CONTAINER_NAME} mysqldump  -u$USER -p$PASSWD  $DBNAME > $BACKDIR/mysql_bgi_${TIME1}.sql

if [ $? -eq  0 ];then
    TIME2=`date +%Y%m%d_%R`

    echo " ${TIME1} start to backup.   Mysql database backup Success at ${TIME2} " >> $LOG
else
    TIME2=`date +%Y%m%d_%R`
    echo " ${TIME1} start to backup.   Mysql database backup Fail.Please check it. time: ${TIME2} " >>$LOG
    exit 1;
fi

find $BACKDIR -type f -mtime +30 -exec rm -rf {} \;
