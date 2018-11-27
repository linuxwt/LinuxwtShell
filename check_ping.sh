#!/bin/bash

network_card="$1"
num1="$2"
num2="$3"
>state.txt
>result.txt
# 假如改脚本所在的服务器处在172.168.1.0网段，我们监控的网段也是该网段服务器
ip1=$(ip addr | grep inet | grep ${network_card} | awk '{print $2}')
ip2=${ip1:0:10} 

for i in `seq ${num1} ${num2}`
do
ping -c 3 ${ip2}${i} >> /dev/null 2>&1
if [ $? -eq 0 ];then
    echo "The server ${ip2}${i} is ok!" >> state.txt
else
    echo "The server ${ip2}${i} is done" >> state.txt
fi
done
prog=$(cat state.txt | grep  done | wc -l)
if [ ${prog} -eq 0 ];then
    echo  "all servers are ok!" > result.txt
    echo -e "`cat result.txt`" | mail -s "all servers"  邮箱名
else
    result=$(cat state.txt | grep  done)
    echo "${result}" | mail -s "${ip2}"  邮箱名
fi
