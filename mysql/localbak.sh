#!/bin/bash

####本脚本用于容器部署的mysql本地备份###
CONTAINER_NAME="容器名"
DIR=`date +%Y%m%d`
BACKDIR="/data/bak/"
USER='username'
PASSWD='password'
DBNAME='dbname'
LOG="/data/bak/backup.log"
TIME1=`date +%Y%m%d_%R`
>$LOG

docker exec  ${CONTAINER_NAME} mysql -u$USER -p$PASSWD -e "use ${DBNAME} ;flush logs;"
docker exec  ${CONTAINER_NAME} mysqldump  -u$USER -p$PASSWD  $DBNAME > $BACKDIR/mysql_${DBNAME}_${TIME1}.sql

if [ $? -eq  0 ];then
    TIME2=`date +%Y%m%d_%R`

    echo " ${TIME1} start to backup specie ${DBNAME}.   Mysql database backup Success at ${TIME2} " >> $LOG
else
    TIME2=`date +%Y%m%d_%R`
    echo " ${TIME1} start to backup specie ${DBNAME}.   Mysql database backup Fail.Please check it. time: ${TIME2} " >>$LOG
    exit 1;
fi

content=$(cat ${LOG} | grep -Eh 'Success')
content_num=$(cat ${LOG} | grep -Eh 'Success' | wc -l)
if [ ${content_num} -eq 0  ];then
    echo "${content}" | mail -s "物种${DBNAME}备份失败"  wangteng@qq.com 
else
    echo "${content}" | mail -s "物种${DBNAME}备份成功"  wangteng@qq.com 
fi

find $BACKDIR -type f -mtime +15 -exec rm -rf {} \;
