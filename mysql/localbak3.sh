#!/bin/bash

CONTAINER_NAME="***"
DIR=`date +%Y%m%d`
BACKDIR="/data/bak/"
USER='***'
PASSWD='***'
LOG="/data/bak/backup.log"
IP="***"
TIME1=`date +%Y%m%d_%R`

>$LOG
echo "${IP}" >> $LOG

p=(***)
for DBNAME in ${p[@]}
do
    docker exec  ${CONTAINER_NAME} mysql -u$USER -p$PASSWD -e "use ${DBNAME} ;flush logs;"
    docker exec  ${CONTAINER_NAME} mysqldump  -u$USER -p$PASSWD  $DBNAME > $BACKDIR/mysql_${DBNAME}_${TIME1}.sql
    if [ $? -eq  0 ];then
        TIME2=`date +%Y%m%d_%R`
       # echo "${IP}" >> $LOG
        echo "name：${DBNAME}" >> $LOG
        echo "state：successful" >> $LOG
        echo "time：from ${TIME1} to ${TIME2}" >> $LOG
        echo "position：${BACKDIR}" >> $LOG
        echo "" >> $LOG
    else
        TIME2=`date +%Y%m%d_%R`
#        echo "${IP}" >> $LOG
        echo "name：${DBNAME}" >> $LOG
        echo "state：failed" >> $LOG
        echo "time：from ${TIME1} to ${TIME2}" >> $LOG
        errlog=$(docker logs -f mysql_core | tail -n 10)
        echo "failed reason:${errlog}" >> ${LOG}
        echo "" >>LOG
    fi
done


    content1=$(cat $LOG)
    echo "${content1}" | mail -s "五大物种备份情况"  wangteng@gooalgene.com

find $BACKDIR -type f -mtime +15 -exec rm -rf {} \;
