#!/bin/bash

# the script is for caculate the datanumber of every database.
# set variables
container_name="$1"
username="$2"
password="$3"

database_name=$(docker exec $1 mysql -u$2 -p$3 -e "show databases;" | grep -v Database)
echo "${database_name}" > database.txt
database_array=(${database_name})
for database in ${database_array[@]}
do
database_data=$(docker exec $1 mysql -u$2 -p$3 -e "use information_schema;select concat(round(sum(data_length/1024/1024),2),'MB') as data from tables where table_schema='${database}';" | grep -v data)
echo "${database_data}" >> ./data.txt
done
paste -d "  " database.txt data.txt
