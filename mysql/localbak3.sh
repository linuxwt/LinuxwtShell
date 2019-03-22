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
p=(***)
for DBNAME in ${p[@]}
do
    docker exec  ${CONTAINER_NAME} mysql -u$USER -p$PASSWD -e "use ${DBNAME} ;flush logs;"
    docker exec  ${CONTAINER_NAME} mysqldump  -u$USER -p$PASSWD  $DBNAME > $BACKDIR/mysql_${DBNAME}_${TIME1}.sql
    if [ $? -eq  0 ];then
        TIME2=`date +%Y%m%d_%R`
        echo "${IP}" >> $LOG
        echo "name：${DBNAME}" >> $LOG
        echo "备份是否成功：是" >> $LOG
        echo "备份时间：${TIME1}-${TIME2}" >> $LOG
        echo "备份文件位置：${BACKDIR}" >> $LOG
    else
        TIME2=`date +%Y%m%d_%R`
        echo "${IP}" >> $LOG
        echo "物种名称：${DBNAME}" >> $LOG
        echo "备份是否成功：否" >> $LOG
        echo "备份时间：${TIME1}-${TIME2}" >> $LOG
        errlog=$(docker logs -f mysql_core | tail -n 10)
        echo "失败原因:${errlog}" >> ${LOG}
    fi
done


    content1=$(cat $LOG)
    echo "${content1}" | mail -s "五大物种备份情况"  wangteng@gooalgene.com

find $BACKDIR -type f -mtime +15 -exec rm -rf {} \;
