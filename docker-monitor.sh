#!/bin/bash

>state.txt
container_name=(nginx_soybean586 tomcat_soybean586 mysql_soybean586 mongo_soybean586 redis_soybean586)
for container in ${container_name[@]}
do
docker ps -a | grep ${container} > /dev/null 2>&1
if [ $? -eq 1 ];then
    echo "The container ${container} is not exist." >> state.txt
else 
    echo "The container ${container} is exist." >> state.txt
    prog=$(docker container top ${container} | grep -v PID | wc -l)
    if [ ${prog} -gt 0 ];then
        echo "The container ${container} state is normal." >> state.txt
    else
        echo "The container ${container} state is unnormal." >> state.txt
    fi
fi
done
content=$(cat state.txt | grep -Eh 'not|unnormal')
content_num=$(cat state.txt | grep -Eh 'not|unnormal' | wc -l)
if [ ${content_num} -eq 0  ];then
    exit -1
else 
    echo "${content}" | mail -s "东北农林研究所服务器192.168.5.204" 439757183@qq.com
    echo "${content}" | mail -s "东北农林研究所服务器192.168.5.204" 2847602965@qq.com
fi
