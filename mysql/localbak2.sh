#!/bin/bash

# 本脚本用于容器部署的mysql备份
CONTAINER_NAME="***"
DIR=`date +%Y%m%d`
BACKDIR="/data/bak/"
USER='***'
PASSWD='***'
DBNAME='***'
LOG="/data/bak/backup.log"
SPECIE="genome"
IP="***"
TIME1=`date +%Y%m%d_%R`
>$LOG

docker exec  ${CONTAINER_NAME} mysql -u$USER -p$PASSWD -e "use ${DBNAME} ;flush logs;"
docker exec  ${CONTAINER_NAME} mysqldump  -u$USER -p$PASSWD  $DBNAME > $BACKDIR/mysql_${DBNAME}_${TIME1}.sql

if [ $? -eq  0 ];then
    TIME2=`date +%Y%m%d_%R`

    echo "${IP}" >> $LOG
    echo "物种名称：${SPECIE}" >> $LOG
    echo "备份是否成功：是" >> $LOG
    echo "备份时间：${TIME1}-${TIME2}" >> $LOG
    echo "备份文件位置：${BACKDIR}" >> $LOG
    content1=$(cat $LOG)
    echo "${content1}" | mail -s "物种genome备份成功"  group_devops@gooalgene.com
else
    TIME2=`date +%Y%m%d_%R`

    echo "${IP}" >> $LOG
    echo "物种名称：${SPECIE}" >> $LOG
    echo "备份是否成功：否" >> $LOG
    echo "备份时间：${TIME1}-${TIME2}" >> $LOG
    errlog=$(docker logs -f ${mysql_import} | tail -n 10)
    echo "失败原因:${errlog}" >> ${LOG}
    content2=$(cat $LOG)
    echo "${content2}" | mail -s "物种genome备份失败"  group_devops@gooalgene.com
    exit 1;
fi


find $BACKDIR -type f -mtime +15 -exec rm -rf {} \;
