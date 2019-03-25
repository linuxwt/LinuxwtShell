#!/bin/bash

# 本脚本用于容器部署的mysql备份
DIR=`date +%Y%m%d`
BACKDIR="/data/bak/"
USER='***'
PASSWD='***'
PORT=***
DBNAME='***'
LOG="/data/bak/backup.log"
SPECIE="***"
IP="***"
TIME1=`date +%Y%m%d_%R`
>$LOG

#docker exec  ${CONTAINER_NAME} mysql -u$USER -p$PASSWD -e "use ${DBNAME} ;flush logs;"
#docker exec  ${CONTAINER_NAME} mysqldump  -u$USER -p$PASSWD  $DBNAME > $BACKDIR/mysql_${DBNAME}_${TIME1}.sql
mysqldump -u$USER -p$PASSWD -h $IP -P $PORT $DBNAME > $BACKDIR/mysql_${DBNAME}_${TIME1}.sql
if [ $? -eq  0 ];then
    TIME2=`date +%Y%m%d_%R`

    echo "${IP}" >> $LOG
    echo "name：${SPECIE}" >> $LOG
    echo "state：successful" >> $LOG
    echo "time：from ${TIME1} to ${TIME2}" >> $LOG
    echo "postion：${BACKDIR}" >> $LOG
    content1=$(cat $LOG)
    echo "${content1}" | mail -s "物种genome备份成功"  group_devops@gooalgene.com
else
    TIME2=`date +%Y%m%d_%R`

    echo "${IP}" >> $LOG
    echo "name：${SPECIE}" >> $LOG
    echo "state：failed" >> $LOG
    echo "time：from ${TIME1} to ${TIME2}" >> $LOG
    echo "failed:${errlog}" >> ${LOG}
    content2=$(cat $LOG)
    echo "${content2}" | mail -s "物种genome备份失败"  group_devops@gooalgene.com
    exit 1;
fi
