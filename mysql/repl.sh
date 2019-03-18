#!/bin/bash

# 监控从节点是否正常
LOG="/data5/slave.txt"
STATE="/data5/state.txt"
>$LOG
>$STATE

docker exec  container_name mysql -uusername -ppassword  -e "show slave status\G" > $LOG
slave_state=$(cat $LOG | grep Slave_IO_State | awk -F ':' '{print $2}')
slave_IO_state=$(cat $LOG | grep Slave_IO_Running | awk -F ':' '{print $2}')
slave_SQL_state=$(cat $LOG | grep Slave_SQL_Running | awk -F ':' '{print $2}')
echo "${slave_state}" >> ${STATE}
echo "${slave_IO_state}" >> ${STATE}
echo "${slave_SQL_state}" >> ${STATE}
content=$(cat ${STATE})
echo "${content}" | mail -s "物种大豆msyql主从备份状态"  wangteng@gooalgene.com  huzhi@gooalgene.com
result=$(grep -Eh 'NO' ${STATE} | wc -l)
if [ ${result} -gt 0 ];then
    echo "主从备份故障" | mail -s "物种大豆msyql主从备份状态" wangteng@gooalgene.com  huzhi@gooalgene.com
fi
