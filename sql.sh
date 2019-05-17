#!/bin/bash

# 该脚本主要是用来自动插入数据
# 在运行该脚本的时候请现在对应的数据库sinobridge上建立表test
while true
do
for ((i=1;i<=12;i++))
do
num=$(echo $RANDOM|cut -c 1-2) # 随机产生一个二位数
docker exec  mysql_linuxwt mysql -uroot -psinobridge -e "use sinobridge;insert into test(personalid,lastname,firstname,address,city)values($num,'da','peng','tj','hebeai');"
sleep 5
done
done
