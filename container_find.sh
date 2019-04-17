#!/bin/bash

if [ $# -eq 1 ];then
rpm -qa |grep mlocate &>/dev/null || yum install -y mlocate &>/dev/null
# locate all docker-compose.yml
locate docker-compose.yml >locate.txt
for i in $(cat locate.txt)
do
	cat $i |grep $1 &>/dev/null && echo $i
done	

else
	echo "Usage: $0 container_name"
fi
