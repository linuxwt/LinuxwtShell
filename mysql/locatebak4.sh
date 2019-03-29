#!/bin/bash

# 有9个物种，每一个物种含有多条基因，一共有50个基因，现在要求把这些基因数据分库备份，并针对每一个物种的每一条基因建立备份目录，比如将物种1_8-12_server的
# 基因acdb备份在目录/data/mushbak/mushroom/1_8-12_server/acdb下，以此类推

dir=(1_8-12_server 2_14-17_server 3_18-22_server 4_23-27_server 5_28-32_server 6_33-37_server 7_38-42_server 13_43-47_server 48-51_server)

for i in ${dir[@]}
do
    [ -d /data/mushbak/mushroom/$i ] || mkdir -p /data/mushbak/mushroom/$i 
    cd /data/mushbak/mushroom/$i
case $i in
1_8-12_server) mkdir -p  acdb pfdb pcidb pefcdb paddb;;
2_14-17_server) mkdir -p  pmdb lddb sedb ledb psdb;;
3_18-22_server) mkdir -p blackfungusdb wcdb osdb podb tubdb cmdb;;
4_23-27_server) mkdir -p pedb tcdb jadb acydb hcsdb ppudb;; 
5_28-32_server) mkdir -p fvdb pjdb pcddb srdb shdb pgdb;;
6_33-37_server) mkdir -p abdb pndb gfdb gidb cxgdb vvdb;;
7_38-42_server) mkdir -p abwdb tmdb lepdb amdb tfdb fvhdb;;
13_43-47_server) mkdir -p gldb lsdb xqdb scdb hmbdb hmdb;;
48-51_server) mkdir -p hedb mtgsdb ordb gsdb;;
*) exit 1;;
esac
done

updatedb

IP="***"
LOG="/data/bak.log"
TIME1=`date +%Y%m%d_%R`
>$LOG
echo "${IP}" >> $LOG

db=(acdb pfdb pcidb pefcdb paddb pmdb lddb sedb ledb psdb blackfungusdb wcdb osdb podb tubdb cmdb pedb tcdb jadb acydb hcsdb ppudb fvdb pjdb pcddb srdb shdb pgdb abdb pndb gfdb gidb cxgdb vvdb abwdb tmdb lepdb amdb tfdb fvhdb gldb lsdb xqdb scdb hmbdb hmdb hedb mtgsdb ordb gsdb)

for dbname in ${db[@]}
do 
    if [ $dbname == "gsdb" ];then
        dia=$(locate $dbname | grep mushroom | grep mushbak | grep -v mtgsdb)
        for diar in ${dia[@]}
        do
            if [ -d ${diar} ];then
                cd ${diar}
                p=${diar}
                docker exec  mysql_core mysqldump  -u*** -p***  $dbname > ./mysql_${dbname}_${TIME1}.sql
                if [ $? -eq  0 ];then
                    TIME2=`date +%Y%m%d_%R`
                    echo "name：${dbname}" >> $LOG
                    echo "state：successful" >> $LOG
                    echo "time：from ${TIME1} to ${TIME2}" >> $LOG
                    echo "position：$p" >>$LOG
                    echo "" >> $LOG
                else
                    TIME2=`date +%Y%m%d_%R`
                    echo "name：${dbname}" >> $LOG
                    echo "state：failed" >> $LOG
                    echo "time：from ${TIME1} to ${TIME2}" >> $LOG
                    errlog=$(docker logs -f mysql_core | tail -n 10)
                    echo "failed reason:${errlog}" >> ${LOG}
                    echo "" >>LOG
                fi
            fi
        done
    else
        dit=$(locate $dbname | grep mushroom | grep mushbak)
        for ditr in ${dit[@]}
        do
            if [ -d ${ditr} ];then
                cd ${ditr}
                q=${ditr}
                docker exec  mysql_core mysqldump  -u*** -p***  $dbname > ./mysql_${dbname}_${TIME1}.sql
                if [ $? -eq  0 ];then
                    TIME2=`date +%Y%m%d_%R`
                    echo "name：${dbname}" >> $LOG
                    echo "state：successful" >> $LOG
                    echo "time：from ${TIME1} to ${TIME2}" >> $LOG
                    echo "position：$q" >>$LOG
                    echo "" >> $LOG
                else
                    TIME2=`date +%Y%m%d_%R`
                    echo "name：${dbname}" >> $LOG
                    echo "state：failed" >> $LOG
                    echo "time：from ${TIME1} to ${TIME2}" >> $LOG
                    errlog=$(docker logs -f mysql_core | tail -n 10)
                    echo "failed reason:${errlog}" >> ${LOG}
                    echo "" >>LOG
                fi
            fi
        done
    fi
 #   find $dit -type f -mtime +15 -exec rm -rf {} \;
done
    
content1=$(cat $LOG)
echo "${content1}" | mail -s "蘑菇备份备份情况"  wangteng@gooalgene.com
