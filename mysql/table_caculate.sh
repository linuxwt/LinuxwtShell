#!/bin/bash

# the script is for caculate the datanumber of every table.
# set variables
container_name="$1"
username="$2"
password="$3"
db_name="$4"

table_name=$(docker exec $1 mysql -u$2 -p$3 -e "use $4;show tables;" | grep -v Tables)
echo "${table_name}" > tables.txt
table_array=(${table_name})
for table in ${table_array[@]}
do
table_data=$(docker exec $1 mysql -u$2 -p$3 -e "use $4;select count(*) from ${table};" | grep -v count)
echo "${table_data}" >> ./tabledata.txt
done
paste -d "  " tables.txt tabledata.txt
